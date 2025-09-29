import QtQuick 2.15
import QtTest 1.3
import QtQuick.Controls 2.15
import "../contents/ui" as UI

TestCase {
    id: testCase
    name: "ConnectionManagerUITests"
    width: 200
    height: 100
    
    property var connectionManager
    
    function init() {
        connectionManager = connectionManagerComponent.createObject(testCase)
        wait(50) // Allow component to initialize
    }
    
    function cleanup() {
        if (connectionManager) {
            connectionManager.destroy()
            connectionManager = null
        }
    }
    
    Component {
        id: connectionManagerComponent
        
        UI.ConnectionManager {
            id: connMgr
            running: false // Don't auto-start polling during tests
            serverBase: "http://127.0.0.1:11434"
            timeoutMs: 100 // Fast timeout for testing
        }
    }
    
    function test_initial_state() {
        compare(connectionManager.status, "disconnected")
        verify(!connectionManager.connected)
        compare(connectionManager.error, "")
    }
    
    function test_status_changes_connected_property() {
        // Test disconnected state
        connectionManager.status = "disconnected"
        verify(!connectionManager.connected)
        
        // Test connecting state
        connectionManager.status = "connecting"
        verify(!connectionManager.connected)
        
        // Test connected state
        connectionManager.status = "connected"
        verify(connectionManager.connected)
    }
    
    function test_serverBase_fallback() {
        // When serverBase is empty, should fall back to default
        connectionManager.serverBase = ""
        var url = connectionManager.getUrl()
        verify(url.indexOf("http://127.0.0.1:11434") === 0)
        
        // When serverBase is set, should use it
        connectionManager.serverBase = "http://192.168.1.100:11434"
        url = connectionManager.getUrl()
        verify(url.indexOf("http://192.168.1.100:11434") === 0)
    }
}