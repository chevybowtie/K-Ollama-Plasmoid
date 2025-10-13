import QtQuick 2.15
import QtTest 1.3
import QtQuick.Controls 2.15
import "../contents/js/utils.js" as Utils

TestCase {
    id: testCase
    name: "MessageInputUITests"
    width: 400
    height: 300
    
    property var messageField
    property var listModel
    
    function init() {
        listModel = listModelComponent.createObject(testCase)
        messageField = messageFieldComponent.createObject(testCase)
    }
    
    function cleanup() {
        if (messageField) {
            messageField.destroy()
            messageField = null
        }
        if (listModel) {
            listModel.destroy()
            listModel = null
        }
    }
    
    Component {
        id: listModelComponent
        ListModel {
            id: model
        }
    }
    
    Component {
        id: messageFieldComponent
        
        TextArea {
            property string lastUserMessage: ""
            property bool enterToSend: false
            
            width: 300
            height: 100
            placeholderText: "Type here what you want to ask..."
            
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Up) {
                    var caretPos = cursorPosition
                    var isAtFirstLine = Utils.caretIsOnFirstLine(text, caretPos)
                    
                    if (isAtFirstLine && lastUserMessage && lastUserMessage.length > 0) {
                        text = lastUserMessage
                        cursorPosition = text.length
                        event.accepted = true
                        return
                    } else {
                        event.accepted = false
                        return
                    }
                }
                
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    var ctrl = (event.modifiers & Qt.ControlModifier)
                    if (enterToSend) {
                        if (ctrl) {
                            // Ctrl+Enter: add new line
                            var cursorPos = cursorPosition
                            insert(cursorPos, "\n")
                            event.accepted = true
                        } else {
                            // Enter: send message (simulate)
                            if (text.trim().length > 0) {
                                sendTriggered(text.trim())
                                event.accepted = true
                            } else {
                                event.accepted = false
                            }
                        }
                    } else {
                        if (ctrl) {
                            // Ctrl+Enter: send message (simulate)
                            if (text.trim().length > 0) {
                                sendTriggered(text.trim())
                                event.accepted = true
                            } else {
                                event.accepted = false
                            }
                        } else {
                            // Enter: add new line (let default behavior)
                            event.accepted = false
                        }
                    }
                }
            }
            
            signal sendTriggered(string message)
        }
    }
    
    function test_placeholder_text() {
        compare(messageField.placeholderText, "Type here what you want to ask...")
    }
    
    function test_up_arrow_recalls_last_message() {
        // Set last user message
        messageField.lastUserMessage = "Previous question"
        messageField.text = ""
        messageField.forceActiveFocus()
        
        // Press Up arrow
        keyPress(Qt.Key_Up)
        
        // Should recall last message
        compare(messageField.text, "Previous question")
        compare(messageField.cursorPosition, messageField.text.length)
    }
    
    function test_up_arrow_only_works_on_first_line() {
        messageField.lastUserMessage = "Previous question"
        messageField.text = "Line 1\nLine 2"
        messageField.cursorPosition = messageField.text.length // End of second line
        messageField.forceActiveFocus()
        
        // Press Up arrow - should NOT recall since not on first line
        var originalText = messageField.text
        keyPress(Qt.Key_Up)
        
        // Text should be unchanged (default cursor movement)
        compare(messageField.text, originalText)
    }
    
    function test_enter_behavior_classic_mode() {
        messageField.enterToSend = false
        messageField.text = "Test message"
        messageField.forceActiveFocus()
        
        var sendSpy = createTemporaryQmlObject('import QtTest 1.3; SignalSpy {}', testCase)
        sendSpy.target = messageField
        sendSpy.signalName = "sendTriggered"
        
        // Enter should NOT send in classic mode
        keyPress(Qt.Key_Return)
        compare(sendSpy.count, 0)
        
        // Ctrl+Enter SHOULD send in classic mode
        keyPress(Qt.Key_Return, Qt.ControlModifier)
        compare(sendSpy.count, 1)
        compare(sendSpy.signalArguments[0][0], "Test message")
    }
    
    function test_enter_behavior_modern_mode() {
        messageField.enterToSend = true
        messageField.text = "Test message"
        messageField.forceActiveFocus()
        
        var sendSpy = createTemporaryQmlObject('import QtTest 1.3; SignalSpy {}', testCase)
        sendSpy.target = messageField
        sendSpy.signalName = "sendTriggered"
        
        // Enter SHOULD send in modern mode
        keyPress(Qt.Key_Return)
        compare(sendSpy.count, 1)
        compare(sendSpy.signalArguments[0][0], "Test message")
    }
    
    function test_empty_message_not_sent() {
        messageField.enterToSend = true
        messageField.text = "   " // Only whitespace
        messageField.forceActiveFocus()
        
        var sendSpy = createTemporaryQmlObject('import QtTest 1.3; SignalSpy {}', testCase)
        sendSpy.target = messageField
        sendSpy.signalName = "sendTriggered"
        
        // Should not send empty/whitespace-only message
        keyPress(Qt.Key_Return)
        compare(sendSpy.count, 0)
    }
    
    function test_ctrl_enter_adds_newline_in_modern_mode() {
        messageField.enterToSend = true
        messageField.text = "First line"
        messageField.cursorPosition = messageField.text.length
        messageField.forceActiveFocus()
        
        // Ctrl+Enter should add newline in modern mode
        keyPress(Qt.Key_Return, Qt.ControlModifier)
        
        verify(messageField.text.indexOf("\n") !== -1)
        compare(messageField.text, "First line\n")
    }
}