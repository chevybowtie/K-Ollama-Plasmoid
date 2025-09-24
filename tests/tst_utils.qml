import QtQuick 2.15
import QtTest 1.3
import "../contents/js/utils.js" as Utils

TestCase {
    name: "UtilsTests"

    function initTestCase() {
        // No-op
    }

    function test_caretIsOnFirstLine_emptyText() {
        compare(Utils.caretIsOnFirstLine("", 0), true);
    }

    function test_caretIsOnFirstLine_atStart() {
        compare(Utils.caretIsOnFirstLine("hello", 0), true);
    }

    function test_caretIsOnFirstLine_middleNoNewline() {
        compare(Utils.caretIsOnFirstLine("hello world", 5), true);
    }

    function test_caretIsOnFirstLine_afterNewline() {
        compare(Utils.caretIsOnFirstLine("line1\nline2", 6), false);
    }

    function test_caretIsOnFirstLine_beforeNewline() {
        compare(Utils.caretIsOnFirstLine("line1\nline2", 5), true);
    }
}
