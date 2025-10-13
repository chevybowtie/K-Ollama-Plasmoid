import QtQuick 2.15
import QtTest 1.3
import "../contents/js/utils.js" as Utils

TestCase {
    name: "DebugLogTests"

    function initTestCase() {
        // Use the test config API to avoid writing to the protected global `plasmoid` during tests
        Utils.debugLogSetTestConfig({ configuration: { debugLogs: false } });
        // Clear any previous last call recorded by the logger
        Utils.debugLog._lastCall = undefined;
    }

    function cleanup() {
        // Reset after each test
        Utils.debugLog._lastCall = undefined;
        Utils.debugLogSetTestConfig({ configuration: { debugLogs: false } });
    }

    function test_debug_and_info_suppressed_by_default() {
        Utils.debugLogSetTestConfig({ configuration: { debugLogs: false } });
        Utils.debugLog('debug', 'should-not-emit');
        compare(Utils.debugLog._lastCall, undefined);

        Utils.debugLog('info', 'should-not-emit-info');
        compare(Utils.debugLog._lastCall, undefined);
    }

    function test_debug_and_info_emit_when_enabled() {
        Utils.debugLogSetTestConfig({ configuration: { debugLogs: true } });
        Utils.debugLog._lastCall = undefined;
        Utils.debugLog('debug', 'emit-debug', 123);
        compare(Utils.debugLog._lastCall.level, 'debug');
        compare(Utils.debugLog._lastCall.args[0], 'emit-debug');
        compare(Utils.debugLog._lastCall.args[1], 123);

        Utils.debugLog._lastCall = undefined;
        Utils.debugLog('info', 'emit-info');
        compare(Utils.debugLog._lastCall.level, 'info');
    }

    function test_warn_and_error_always_emit() {
    Utils.debugLogSetTestConfig({ configuration: { debugLogs: false } });
        Utils.debugLog._lastCall = undefined;
        Utils.debugLog('warn', 'a-warning');
        compare(Utils.debugLog._lastCall.level, 'warn');

        Utils.debugLog._lastCall = undefined;
        Utils.debugLog('error', 'an-error');
        compare(Utils.debugLog._lastCall.level, 'error');
    }
}
