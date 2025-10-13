import QtQuick 2.15
import QtTest 1.3
import "../contents/js/utils.js" as Utils

TestCase {
    name: "ParseTextTests"

    function test_simple() {
        compare(Utils.parseTextToComboBox('gpt-4o:latest'), 'Gpt 4o (Latest)');
    }

    function test_hyphen() {
        compare(Utils.parseTextToComboBox('my-model-v1'), 'My Model V1');
    }

    function test_parentheses() {
        compare(Utils.parseTextToComboBox('model:(alpha)'), 'Model (Alpha)');
    }
}
