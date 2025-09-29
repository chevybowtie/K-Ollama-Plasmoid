import QtQuick 2.15
import QtTest 1.3
import QtQuick.Controls 2.15

TestCase {
    id: testCase
    name: "ConfigUITests"
    width: 400
    height: 500
    
    property var configForm
    
    // Mock plasmoid configuration
    property QtObject mockConfig: QtObject {
        property string ollamaServerUrl: "http://127.0.0.1:11434"
        property real ollamaTemperature: 0.7
        property bool debugLogs: false
        property bool enterToSend: false
        property bool completionSound: false
    }
    
    function init() {
        configForm = configComponent.createObject(testCase)
    }
    
    function cleanup() {
        if (configForm) {
            configForm.destroy()
            configForm = null
        }
    }
    
    Component {
        id: configComponent
        
        Column {
            property alias serverUrlField: urlField
            property alias temperatureSlider: tempSlider
            property alias debugLogsCheckbox: debugBox
            property alias enterToSendCheckbox: enterBox
            property alias soundCheckbox: soundBox
            
            // Mock KCM properties that would be provided by the framework
            property alias cfg_ollamaServerUrl: urlField.text
            property alias cfg_ollamaTemperature: tempSlider.value
            property alias cfg_debugLogs: debugBox.checked
            property alias cfg_enterToSend: enterBox.checked
            property alias cfg_completionSound: soundBox.checked
            
            spacing: 10
            width: 350
            
            TextField {
                id: urlField
                placeholderText: "http://127.0.0.1:11434"
                text: mockConfig.ollamaServerUrl
                width: parent.width
            }
            
            Row {
                spacing: 10
                Text { text: "Temperature:" }
                Slider {
                    id: tempSlider
                    from: 0.0
                    to: 2.0
                    stepSize: 0.01
                    value: mockConfig.ollamaTemperature
                    width: 200
                }
                Text { text: tempSlider.value.toFixed(2) }
            }
            
            CheckBox {
                id: debugBox
                text: "Enable debug console logs"
                checked: mockConfig.debugLogs
            }
            
            CheckBox {
                id: enterBox
                text: "Use Enter to send message"
                checked: mockConfig.enterToSend
            }
            
            CheckBox {
                id: soundBox
                text: "Play sound when AI response is complete"
                checked: mockConfig.completionSound
            }
        }
    }
    
    function test_server_url_field_initialization() {
        compare(configForm.serverUrlField.text, "http://127.0.0.1:11434")
        compare(configForm.serverUrlField.placeholderText, "http://127.0.0.1:11434")
    }
    
    function test_server_url_field_binding() {
        // Change the field text
        configForm.serverUrlField.text = "http://192.168.1.100:11434"
        
        // Should update cfg_ property
        compare(configForm.cfg_ollamaServerUrl, "http://192.168.1.100:11434")
    }
    
    function test_temperature_slider_initialization() {
        compare(configForm.temperatureSlider.value, 0.7)
        compare(configForm.temperatureSlider.from, 0.0)
        compare(configForm.temperatureSlider.to, 2.0)
        compare(configForm.temperatureSlider.stepSize, 0.01)
    }
    
    function test_temperature_slider_binding() {
        // Change slider value
        configForm.temperatureSlider.value = 1.5
        
        // Should update cfg_ property
        compare(configForm.cfg_ollamaTemperature, 1.5)
    }
    
    function test_temperature_slider_range() {
        // Test minimum
        configForm.temperatureSlider.value = -0.5
        verify(configForm.temperatureSlider.value >= 0.0)
        
        // Test maximum
        configForm.temperatureSlider.value = 3.0
        verify(configForm.temperatureSlider.value <= 2.0)
    }
    
    function test_debug_logs_checkbox() {
        // Initial state
        compare(configForm.debugLogsCheckbox.checked, false)
        
        // Direct property manipulation (more reliable than key simulation)
        configForm.debugLogsCheckbox.checked = true
        
        // Should be checked and update cfg_ property
        verify(configForm.debugLogsCheckbox.checked)
        verify(configForm.cfg_debugLogs)
    }
    
    function test_enter_to_send_checkbox() {
        // Initial state
        compare(configForm.enterToSendCheckbox.checked, false)
        
        // Direct property manipulation (more reliable than key simulation)
        configForm.enterToSendCheckbox.checked = true
        
        // Should be checked and update cfg_ property
        verify(configForm.enterToSendCheckbox.checked)
        verify(configForm.cfg_enterToSend)
    }
    
    function test_completion_sound_checkbox() {
        // Initial state
        compare(configForm.soundCheckbox.checked, false)
        
        // Direct property manipulation (more reliable than key simulation)
        configForm.soundCheckbox.checked = true
        
        // Should be checked and update cfg_ property
        verify(configForm.soundCheckbox.checked)
        verify(configForm.cfg_completionSound)
    }
    
    function test_all_cfg_properties_exist() {
        // Verify all cfg_ properties are accessible (KCM pattern)
        verify(typeof configForm.cfg_ollamaServerUrl !== "undefined")
        verify(typeof configForm.cfg_ollamaTemperature !== "undefined")
        verify(typeof configForm.cfg_debugLogs !== "undefined")
        verify(typeof configForm.cfg_enterToSend !== "undefined")
        verify(typeof configForm.cfg_completionSound !== "undefined")
    }
}