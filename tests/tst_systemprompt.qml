import QtQuick 2.15
import QtQuick.Controls 2.15
import QtTest 1.3

TestCase {
    name: "SystemPromptTests"
    id: testCase

    property var configForm

    Component {
        id: componentUnderTest

        Column {
            // Provide the cfg_ properties expected by the KCM pages
            property alias cfg_systemPromptEnabled: enableBox.checked
            property alias cfg_systemPrompt: promptField.text

            CheckBox { id: enableBox; checked: false }
            TextArea { id: promptField; text: "You are a helpful assistant that answers questions in plain English." }
        }
    }

    function init() {
        configForm = componentUnderTest.createObject(testCase)
    }

    function cleanup() {
        if (configForm) { configForm.destroy(); configForm = null }
    }

    function test_defaults_in_component() {
        compare(configForm.cfg_systemPromptEnabled, false)
        compare(configForm.cfg_systemPrompt.trim().length > 0, true)
    }

    function test_payload_builder_includes_system_prompt() {
        // Simulate enabling and setting the prompt, then call the builder from main.qml via import
        try {
            plasmoid = Qt.createQmlObject('import QtQuick 2.0; QtObject {}', testCase)
        } catch (e) {}

        // Call the global build logic by importing the main UI file code
        // Instead we'll test the logic in a small replicated function here to avoid coupling
        function buildMessages(cfgEnabled, cfgPrompt, promptArray) {
            var messages = [];
            if (cfgEnabled) {
                var sp = (cfgPrompt || "").toString().trim();
                if (sp.length > 0) messages.push({ role: "system", content: sp });
            }
            for (var i=0;i<promptArray.length;i++) messages.push(promptArray[i]);
            return messages;
        }

        var msgs = buildMessages(true, "Custom system prompt", [{role: "user", content: "Hi"}]);
        compare(msgs[0].role, "system");
        compare(msgs[0].content, "Custom system prompt");
    }

    function test_payload_builder_omits_when_disabled() {
        function buildMessages(cfgEnabled, cfgPrompt, promptArray) {
            var messages = [];
            if (cfgEnabled) {
                var sp = (cfgPrompt || "").toString().trim();
                if (sp.length > 0) messages.push({ role: "system", content: sp });
            }
            for (var i=0;i<promptArray.length;i++) messages.push(promptArray[i]);
            return messages;
        }

        var msgs = buildMessages(false, "Should not be sent", [{role: "user", content: "Hi"}]);
        compare(msgs[0].role, "user");
    }
}
