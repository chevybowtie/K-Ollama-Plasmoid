import QtQuick 2.15
import QtTest 1.3
import "../contents/js/utils.js" as Utils

TestCase {
    id: testCase
    name: "PerformanceTests"
    width: 400
    height: 300
    
    property var performanceComponent
    property var startTime
    property var endTime
    property int iterations: 1000
    
    function init() {
        startTime = 0
        endTime = 0
        gc() // Force garbage collection before each test
    }
    
    function cleanup() {
        if (performanceComponent) {
            performanceComponent.destroy()
            performanceComponent = null
        }
        gc() // Clean up after each test
    }
    
    function startTimer() {
        startTime = new Date().getTime()
    }
    
    function endTimer() {
        endTime = new Date().getTime()
        return endTime - startTime
    }
    
    Component {
        id: messageListComponent
        
        ListView {
            id: listView
            width: 300
            height: 200
            
            property alias listModel: listModel
            
            model: ListModel {
                id: listModel
            }
            
            delegate: Item {
                width: listView.width
                height: 50
                
                Text {
                    text: model.content || ""
                    wrapMode: Text.Wrap
                    anchors.fill: parent
                }
            }
            
            function addMessage(content) {
                listModel.append({
                    "content": content,
                    "timestamp": new Date().toISOString(),
                    "sender": "test"
                })
            }
            
            function clear() {
                listModel.clear()
            }
        }
    }
    
    Component {
        id: configComponent
        
        Item {
            property var configs: ({})
            
            function updateConfig(key, value) {
                var newConfigs = configs
                newConfigs[key] = value
                configs = newConfigs
            }
            
            function getConfig(key, defaultValue) {
                return configs.hasOwnProperty(key) ? configs[key] : defaultValue
            }
        }
    }
    
    function test_message_list_performance() {
        performanceComponent = messageListComponent.createObject(testCase)
        verify(performanceComponent)
        
        // Test adding many messages
        startTimer()
        
        for (var i = 0; i < 100; i++) {
            performanceComponent.addMessage("Test message " + i + " with some content to simulate real usage")
        }
        
        var addTime = endTimer()
        
        // Should add 100 messages reasonably quickly (under 1 second)
        verify(addTime < 1000, "Adding 100 messages took " + addTime + "ms (should be < 1000ms)")
        
        // Verify all messages were added
        compare(performanceComponent.listModel.count, 100)
        
        // Test clearing performance
        startTimer()
        performanceComponent.clear()
        var clearTime = endTimer()
        
        // Should clear quickly (under 100ms)
        verify(clearTime < 100, "Clearing 100 messages took " + clearTime + "ms (should be < 100ms)")
        
        // Verify list is empty
        compare(performanceComponent.listModel.count, 0)
    }
    
    function test_utility_function_performance() {
        // Test caretIsOnFirstLine performance
        var testText = "Line 1\nLine 2\nLine 3\nLine 4\nLine 5"
        
        startTimer()
        for (var i = 0; i < iterations; i++) {
            Utils.caretIsOnFirstLine(testText, 5)
        }
        var caretTime = endTimer()
        
        // Should execute 1000 iterations quickly (under 100ms)
        verify(caretTime < 100, "caretIsOnFirstLine " + iterations + " iterations took " + caretTime + "ms (should be < 100ms)")
        
        // Test getServerUrl performance
        startTimer()
        for (var j = 0; j < iterations; j++) {
            Utils.getServerUrl("http://127.0.0.1:11434", "/api/tags")
        }
        var urlTime = endTimer()
        
        verify(urlTime < 100, "getServerUrl " + iterations + " iterations took " + urlTime + "ms (should be < 100ms)")
        
        // Test parseTextToComboBox performance
        var parseTestText = "Some text with (parentheses) and - dashes"
        startTimer()
        for (var k = 0; k < iterations; k++) {
            Utils.parseTextToComboBox(parseTestText)
        }
        var parseTime = endTimer()
        
        verify(parseTime < 200, "parseTextToComboBox " + iterations + " iterations took " + parseTime + "ms (should be < 200ms)")
    }
    
    function test_configuration_performance() {
        performanceComponent = configComponent.createObject(testCase)
        verify(performanceComponent)
        
        // Test rapid configuration updates
        startTimer()
        
        for (var i = 0; i < 100; i++) {
            performanceComponent.updateConfig("server_url", "http://localhost:" + (11434 + i))
            performanceComponent.updateConfig("temperature", 0.1 + (i * 0.01))
            performanceComponent.updateConfig("model", "model_" + i)
        }
        
        var configTime = endTimer()
        
        // Should handle 300 config updates quickly (under 200ms)
        verify(configTime < 200, "300 config updates took " + configTime + "ms (should be < 200ms)")
        
        // Verify final values
        compare(performanceComponent.getConfig("server_url"), "http://localhost:11533")
        compare(performanceComponent.getConfig("temperature"), 1.09)
        compare(performanceComponent.getConfig("model"), "model_99")
    }
    
    function test_memory_cleanup() {
        var initialObjects = []
        var createdObjects = []
        
        // Create baseline objects
        for (var i = 0; i < 10; i++) {
            initialObjects.push(configComponent.createObject(testCase))
        }
        
        // Create many objects
        for (var j = 0; j < 50; j++) {
            var obj = messageListComponent.createObject(testCase)
            obj.addMessage("Test message " + j)
            createdObjects.push(obj)
        }
        
        // Verify objects exist
        compare(createdObjects.length, 50)
        
        // Destroy objects
        for (var k = 0; k < createdObjects.length; k++) {
            createdObjects[k].destroy()
        }
        createdObjects = []
        
        // Force garbage collection
        gc()
        wait(100) // Give time for cleanup
        gc()
        
        // Baseline objects should still exist
        compare(initialObjects.length, 10)
        for (var l = 0; l < initialObjects.length; l++) {
            verify(initialObjects[l] !== null)
            initialObjects[l].destroy()
        }
    }
    
    function test_string_processing_performance() {
        var longText = ""
        for (var i = 0; i < 1000; i++) {
            longText += "This is a test message with some content. "
        }
        
        // Test large text processing
        startTimer()
        for (var j = 0; j < 10; j++) {
            Utils.parseTextToComboBox(longText)
        }
        var longTextTime = endTimer()
        
        // Should handle large text reasonably (under 500ms)
        verify(longTextTime < 500, "Processing large text 10 times took " + longTextTime + "ms (should be < 500ms)")
        
        // Test caret position with long text
        startTimer()
        for (var k = 0; k < 100; k++) {
            Utils.caretIsOnFirstLine(longText, 500)
        }
        var caretLongTime = endTimer()
        
        verify(caretLongTime < 200, "Caret checking with long text 100 times took " + caretLongTime + "ms (should be < 200ms)")
    }
    
    function test_rapid_ui_updates() {
        performanceComponent = messageListComponent.createObject(testCase)
        verify(performanceComponent)
        
        // Test rapid UI updates
        startTimer()
        
        for (var i = 0; i < 50; i++) {
            performanceComponent.addMessage("Rapid message " + i)
            
            // Simulate processing time
            if (i % 10 === 0) {
                wait(1) // Small delay every 10 messages
            }
        }
        
        var rapidTime = endTimer()
        
        // Should handle rapid updates efficiently (under 500ms)
        verify(rapidTime < 500, "50 rapid UI updates took " + rapidTime + "ms (should be < 500ms)")
        
        // Verify all messages were added
        compare(performanceComponent.listModel.count, 50)
    }
    
    function test_component_creation_performance() {
        var components = []
        
        // Test creating many components quickly
        startTimer()
        
        for (var i = 0; i < 20; i++) {
            var comp = configComponent.createObject(testCase)
            comp.updateConfig("test", "value" + i)
            components.push(comp)
        }
        
        var creationTime = endTimer()
        
        // Should create components efficiently (under 200ms)
        verify(creationTime < 200, "Creating 20 components took " + creationTime + "ms (should be < 200ms)")
        
        // Test destroying components
        startTimer()
        
        for (var j = 0; j < components.length; j++) {
            components[j].destroy()
        }
        
        var destructionTime = endTimer()
        
        // Should destroy components quickly (under 100ms)
        verify(destructionTime < 100, "Destroying 20 components took " + destructionTime + "ms (should be < 100ms)")
    }
    
    function test_debug_logging_performance() {
        // Test debug logging performance when disabled (default state)
        startTimer()
        
        for (var i = 0; i < iterations; i++) {
            Utils.debugLog('debug', "Test debug message", i)
            Utils.debugLog('info', "Test info message", i)
        }
        
        var disabledTime = endTimer()
        
        // Disabled logging should be very fast (under 50ms)
        verify(disabledTime < 50, "Disabled logging " + iterations + " times took " + disabledTime + "ms (should be < 50ms)")
        
        // Test warning/error logging (always enabled)
        startTimer()
        
        for (var j = 0; j < 100; j++) {
            Utils.debugLog('warn', "Test warning", j)
            Utils.debugLog('error', "Test error", j)
        }
        
        var enabledTime = endTimer()
        
        // Enabled logging should still be reasonable (under 200ms)
        verify(enabledTime < 200, "Enabled logging 200 times took " + enabledTime + "ms (should be < 200ms)")
    }
}