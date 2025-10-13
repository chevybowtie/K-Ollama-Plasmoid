import QtTest 1.2
import QtQuick 2.15

import "../contents/js/utils.js" as Utils

TestCase {
    name: "KcmDebugLogSmokeTest"

    function test_toggle_and_emit() {
        // Ensure tests start with debug logs disabled
        Utils.debugLogSetTestConfig({ configuration: { debugLogs: false } });
        // Should not emit debug/info when disabled
        Utils.debugLog('debug', 'should-not-appear');
        if (Utils.debugLog._lastCall && Utils.debugLog._lastCall.level === 'debug') {
            throw 'debug emitted when it should be suppressed';
        }

        Utils.debugLog('info', 'should-not-appear-either');
        if (Utils.debugLog._lastCall && Utils.debugLog._lastCall.level === 'info') {
            throw 'info emitted when it should be suppressed';
        }

        // Simulate KCM Apply persisting debugLogs = true
        Utils.debugLogSetTestConfig({ configuration: { debugLogs: true } });

        // Now debug/info should emit
        Utils.debugLog('debug', 'emit-now');
        if (!Utils.debugLog._lastCall || Utils.debugLog._lastCall.level !== 'debug') {
            throw 'debug did not emit when enabled';
        }

        Utils.debugLog('info', 'emit-now-info');
        if (!Utils.debugLog._lastCall || Utils.debugLog._lastCall.level !== 'info') {
            throw 'info did not emit when enabled';
        }

        // Warn/error always emit regardless
        Utils.debugLog('warn', 'a-warning');
        if (!Utils.debugLog._lastCall || Utils.debugLog._lastCall.level !== 'warn') {
            throw 'warn did not emit';
        }

        Utils.debugLog('error', 'an-error');
        if (!Utils.debugLog._lastCall || Utils.debugLog._lastCall.level !== 'error') {
            throw 'error did not emit';
        }
    }
}
