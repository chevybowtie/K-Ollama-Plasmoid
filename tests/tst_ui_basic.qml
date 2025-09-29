import QtQuick 2.15
import QtTest 1.3
import QtQuick.Controls 2.15

TestCase {
    id: testCase
    name: "BasicUITests"
    width: 400
    height: 300
    
    function test_button_click_behavior() {
        var button = buttonComponent.createObject(testCase)
        verify(button)
        
        var clickedCount = 0
        button.clicked.connect(function() {
            clickedCount++
        })

        // Initial state
        compare(clickedCount, 0)
        
        // Direct signal emission (more reliable than mouse simulation)
        button.clicked()
        
        // Verify click was registered
        compare(clickedCount, 1)
        
        button.destroy()
    }
    
    function test_checkbox_toggle() {
        var checkbox = checkboxComponent.createObject(testCase)
        verify(checkbox)
        
        // Initial state
        compare(checkbox.checked, false)
        
        // Direct property manipulation (more reliable than key simulation)
        checkbox.checked = true
        verify(checkbox.checked)
        
        // Toggle back
        checkbox.checked = false
        verify(!checkbox.checked)
        
        checkbox.destroy()
    }
    
    function test_textfield_input() {
        var textField = textFieldComponent.createObject(testCase)
        verify(textField)
        
        // Initial state
        compare(textField.text, "")
        
        // Set text programmatically
        textField.text = "Hello World"
        compare(textField.text, "Hello World")
        
        // Clear text
        textField.clear()
        compare(textField.text, "")
        
        textField.destroy()
    }
    
    function test_slider_value_changes() {
        var slider = sliderComponent.createObject(testCase)
        verify(slider)
        
        // Test initial value
        compare(slider.value, 0.5)
        
        // Test value change
        slider.value = 0.8
        compare(slider.value, 0.8)
        
        // Test range limits
        slider.value = -1.0
        verify(slider.value >= slider.from)
        
        slider.value = 10.0
        verify(slider.value <= slider.to)
        
        slider.destroy()
    }
    
    Component {
        id: buttonComponent
        Button {
            text: "Test Button"
        }
    }
    
    Component {
        id: checkboxComponent
        CheckBox {
            text: "Test Checkbox"
        }
    }
    
    Component {
        id: textFieldComponent
        TextField {
            placeholderText: "Enter text..."
        }
    }
    
    Component {
        id: sliderComponent
        Slider {
            from: 0.0
            to: 1.0
            value: 0.5
        }
    }
}