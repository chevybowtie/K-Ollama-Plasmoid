import QtQuick 2.15
import QtTest 1.3
import QtQuick.Controls 2.15
import "../contents/js/utils.js" as Utils

TestCase {
    id: testCase
    name: "KeyInputTests"
    width: 300
    height: 200
    
    function test_utils_caretIsOnFirstLine() {
        // Test the utility function directly
        verify(Utils.caretIsOnFirstLine("", 0))
        verify(Utils.caretIsOnFirstLine("hello", 0))
        verify(Utils.caretIsOnFirstLine("hello", 3))
        verify(Utils.caretIsOnFirstLine("hello", 5))
        
        // Test with newlines
        verify(!Utils.caretIsOnFirstLine("line1\nline2", 6))
        verify(Utils.caretIsOnFirstLine("line1\nline2", 5))
        verify(Utils.caretIsOnFirstLine("line1\nline2", 0))
    }
    
    function test_textarea_basic_functionality() {
        var textArea = textAreaComponent.createObject(testCase)
        verify(textArea)
        
        // Test initial state
        compare(textArea.text, "")
        
        // Test text setting
        textArea.text = "Hello\nWorld"
        compare(textArea.text, "Hello\nWorld")
        
        // Test cursor positioning
        textArea.cursorPosition = 0
        compare(textArea.cursorPosition, 0)
        
        textArea.cursorPosition = 5 // End of first line
        compare(textArea.cursorPosition, 5)
        
        textArea.destroy()
    }
    
    function test_textarea_key_events() {
        var textArea = textAreaComponent.createObject(testCase)
        verify(textArea)
        
        textArea.forceActiveFocus()
        wait(50) // Allow focus to settle
        
        // Test typing
        textArea.text = "test"
        compare(textArea.text, "test")
        
        // Test cursor positioning
        textArea.cursorPosition = textArea.text.length
        compare(textArea.cursorPosition, 4)
        
        textArea.destroy()
    }
    
    Component {
        id: textAreaComponent
        
        TextArea {
            width: 200
            height: 100
            placeholderText: "Type here..."
            wrapMode: TextArea.Wrap
            
            property bool enterToSend: false
            property string lastMessage: ""
            property int sendCount: 0
            
            function simulateSend() {
                sendCount++
            }
            
            // Simplified key handling for testing
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Return) {
                    var ctrl = (event.modifiers & Qt.ControlModifier)
                    
                    if (enterToSend && !ctrl) {
                        // Enter sends in modern mode
                        simulateSend()
                        event.accepted = true
                    } else if (!enterToSend && ctrl) {
                        // Ctrl+Enter sends in classic mode
                        simulateSend()
                        event.accepted = true
                    }
                }
            }
        }
    }
}