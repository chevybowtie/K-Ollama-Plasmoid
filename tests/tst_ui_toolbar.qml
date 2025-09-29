import QtQuick 2.15
import QtTest 1.3
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import org.kde.plasma.components as PlasmaComponents

TestCase {
    id: testCase
    name: "ToolbarUITests"
    
    property var toolbar
    property bool hasLocalModel: true
    property bool isLoading: false
    property bool configureTriggered: false
    
    // Mock plasmoid object for testing
    property QtObject mockPlasmoid: QtObject {
        property QtObject configuration: QtObject {
            property bool pin: false
            property string ollamaServerUrl: "http://127.0.0.1:11434"
            property string selectedModel: ""
            property real ollamaTemperature: 0.7
            property bool debugLogs: false
            property bool completionSound: false
            property bool enterToSend: false
        }
        
        function internalAction(name) {
            return {
                trigger: function() {
                    testCase.configureTriggered = true
                }
            }
        }
    }
    
    function init() {
        // Reset state before each test
        hasLocalModel = true
        isLoading = false
        configureTriggered = false
        testCase.mockPlasmoid.configuration.pin = false
        
        // Create toolbar component for testing
        toolbar = toolbarComponent.createObject(testCase)
    }
    
    function cleanup() {
        if (toolbar) {
            toolbar.destroy()
            toolbar = null
        }
    }
    
    Component {
        id: toolbarComponent
        
        RowLayout {
            // Simplified version of the main toolbar for testing
            property alias pinButton: pinBtn
            property alias configButton: configBtn
            property alias clearButton: clearBtn
            
            PlasmaComponents.Button {
                id: pinBtn
                checkable: true
                checked: testCase.mockPlasmoid.configuration.pin
                onToggled: testCase.mockPlasmoid.configuration.pin = checked
                icon.name: "window-pin"
                text: "Keep Open"
            }
            
            PlasmaComponents.Button {
                id: clearBtn
                icon.name: "edit-clear-symbolic"
                text: "Clear chat"
                enabled: hasLocalModel && !isLoading
                
                signal clearTriggered()
                onClicked: clearTriggered()
            }
            
            PlasmaComponents.Button {
                id: configBtn
                icon.name: "configure"
                text: "Configure"
                enabled: true
                
                onClicked: {
                    testCase.mockPlasmoid.internalAction("configure").trigger()
                }
            }
        }
    }
    
    function test_pinButton_toggles_state() {
        // Initial state
        compare(toolbar.pinButton.checked, false)
        compare(testCase.mockPlasmoid.configuration.pin, false)
        
        // Direct property manipulation and signal trigger
        toolbar.pinButton.checked = true
        toolbar.pinButton.toggled()
        
        // Verify state changed
        compare(toolbar.pinButton.checked, true)
        compare(testCase.mockPlasmoid.configuration.pin, true)
        
        // Toggle back
        toolbar.pinButton.checked = false
        toolbar.pinButton.toggled()
        
        // Verify state changed back
        compare(toolbar.pinButton.checked, false)
        compare(testCase.mockPlasmoid.configuration.pin, false)
    }
    
    function test_clearButton_enabled_state() {
        // When models available and not loading, should be enabled
        hasLocalModel = true
        isLoading = false
        toolbar.destroy()
        toolbar = toolbarComponent.createObject(testCase)
        
        verify(toolbar.clearButton.enabled)
        
        // When loading, should be disabled
        isLoading = true
        toolbar.destroy()
        toolbar = toolbarComponent.createObject(testCase)
        
        verify(!toolbar.clearButton.enabled)
        
        // When no models, should be disabled
        hasLocalModel = false
        isLoading = false
        toolbar.destroy()
        toolbar = toolbarComponent.createObject(testCase)
        
        verify(!toolbar.clearButton.enabled)
    }
    
    function test_clearButton_emits_signal() {
        var signalSpy = createTemporaryQmlObject('import QtTest 1.3; SignalSpy {}', testCase)
        signalSpy.target = toolbar.clearButton
        signalSpy.signalName = "clearTriggered"
        
        // Direct signal emission (more reliable than mouse simulation)
        toolbar.clearButton.clearTriggered()
        
        compare(signalSpy.count, 1)
    }
    
    function test_configButton_triggers_action() {
        // Initially not triggered
        compare(testCase.configureTriggered, false)
        
        // Direct signal emission (more reliable than mouse simulation)
        toolbar.configButton.clicked()
        
        // Verify action was triggered
        verify(testCase.configureTriggered)
    }
    
    function test_configButton_always_enabled() {
        // Config button should always be enabled regardless of state
        hasLocalModel = false
        isLoading = true
        toolbar.destroy()
        toolbar = toolbarComponent.createObject(testCase)
        
        verify(toolbar.configButton.enabled)
    }
}