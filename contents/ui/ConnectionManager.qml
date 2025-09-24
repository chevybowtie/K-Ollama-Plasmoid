/*
  Simple connection checker for Ollama server.
  Polls the configured server's /api/tags endpoint on a timer and exposes
  `connected`, `status`, and `error` properties for UI binding.
*/
import QtQuick 2.15
import "../js/utils.js" as Utils

Item {
    id: root

    // Public state
    // `connected` is derived from `status` to keep both values consistent
    property string status: "disconnected" // "connected" | "connecting" | "disconnected"
    property bool connected: status === "connected"
    property string error: ""
    property string lastChecked: ""

    // Configuration
    property int interval: 5000          // ms between polls (initial)
    // Adaptive intervals
    property int connectedPollInterval: 30000
    property int disconnectedPollInterval: 5000
    property int timeoutMs: 3000         // ms before aborting a single request
    property string endpoint: "/api/tags"
    property bool running: true
    // Optional server base URL (e.g. "http://127.0.0.1:11434"). If empty, falls back to default.
    property string serverBase: ""

    Timer {
        id: pollTimer
        interval: root.interval
        repeat: true
        running: root.running
        onTriggered: root.check()
    }

    // react to status changes: adjust poll interval
    onStatusChanged: {
        // choose interval based on connection state
        pollTimer.interval = (status === "connected") ? root.connectedPollInterval : root.disconnectedPollInterval;

        // restart the timer so the new interval takes effect immediately
        if (pollTimer.running) {
            pollTimer.stop();
            pollTimer.start();
        }
    }

    // Single-use timer used to abort a single request on timeout
    Timer {
        id: requestTimer
        interval: root.timeoutMs
        repeat: false
        onTriggered: {
            if (root._currentXhr) {
                try { root._currentXhr.abort(); } catch(e) {}
                root._currentXhr = null;
            }
            status = "disconnected";
            error = "timeout";
            lastChecked = new Date().toISOString();
        }
    }

    // hold a reference to an in-flight XMLHttpRequest so the timeout timer can abort it
    property var _currentXhr: null

    function getServerBase() {
        return root.serverBase || 'http://127.0.0.1:11434';
    }

    function getUrl() {
        // Utils.buildServerUrl returns base + endpoint (endpoint may include leading slash)
        return Utils.buildServerUrl(getServerBase(), root.endpoint);
    }

    function check() {
        console.log("ConnectionManager: check() starting. endpoint=", root.endpoint, "serverBase=", root.serverBase);
        status = "connecting";
        error = "";

        var url = getUrl();
        console.log("ConnectionManager: checking URL ->", url);
        var xhr = new XMLHttpRequest();

        // start the request timeout timer and keep reference to xhr so it can be aborted
        root._currentXhr = xhr;
        requestTimer.interval = root.timeoutMs;
        requestTimer.start();

        xhr.open("GET", url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                requestTimer.stop();
                root._currentXhr = null;
                lastChecked = new Date().toISOString();
                    console.log("ConnectionManager: check DONE, status=", xhr.status);
                if (xhr.status === 200) {
                    status = "connected";
                    error = "";
                } else {
                    status = "disconnected";
                    error = "HTTP " + xhr.status;
                }
            }
        };

        xhr.onerror = function() {
            requestTimer.stop();
            root._currentXhr = null;
            console.log("ConnectionManager: network error when checking URL");
            status = "disconnected";
            error = 'network error';
            lastChecked = new Date().toISOString();
        };

        try {
            xhr.send();
        } catch (e) {
            requestTimer.stop();
            root._currentXhr = null;
            status = "disconnected";
            error = e.toString();
            lastChecked = new Date().toISOString();
        }
    }

    Component.onCompleted: {
        // start polling immediately
        console.log("ConnectionManager: Component.onCompleted, running=", root.running, "interval=", pollTimer.interval);
        if (root.running) pollTimer.start();
    }
}
