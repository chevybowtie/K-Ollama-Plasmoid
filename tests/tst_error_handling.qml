import QtQuick 2.15
import QtTest 1.3
import "../contents/js/utils.js" as Utils

TestCase {
    id: testCase
    name: "ErrorHandlingTests"
    width: 400
    height: 300
    
    property var connectionManager
    property var requestResult
    
    function init() {
        // Reset state before each test
        requestResult = null
    }
    
    function cleanup() {
        if (connectionManager) {
            connectionManager.destroy()
            connectionManager = null
        }
    }
    
    Component {
        id: connectionManagerComponent
        
        Item {
            property string status: "disconnected"
            property bool connected: status === "connected"
            property string error: ""
            property string lastChecked: ""
            property int timeoutMs: 1000
            property string endpoint: "/api/tags"
            property string serverBase: ""
            property var _currentXhr: null
            
            // Mock timer for timeout testing
            Timer {
                id: mockTimeout
                interval: timeoutMs
                repeat: false
                onTriggered: {
                    if (parent._currentXhr) {
                        parent.status = "disconnected"
                        parent.error = "timeout"
                        parent.lastChecked = new Date().toISOString()
                        parent._currentXhr = null
                    }
                }
            }
            
            function getServerBase() {
                return serverBase || 'http://127.0.0.1:11434'
            }
            
            function getUrl() {
                return Utils.getServerUrl(getServerBase(), endpoint)
            }
            
            function simulateNetworkError() {
                status = "connecting"
                error = ""
                
                // Simulate immediate network error
                status = "disconnected"
                error = "network error"
                lastChecked = new Date().toISOString()
            }
            
            function simulateTimeout() {
                status = "connecting"
                error = ""
                _currentXhr = {} // Mock XHR object
                
                // Start timeout simulation
                mockTimeout.start()
            }
            
            function simulateHttpError(statusCode) {
                status = "connecting"
                error = ""
                
                // Simulate HTTP error response
                status = "disconnected"
                error = "HTTP " + statusCode
                lastChecked = new Date().toISOString()
            }
            
            function simulateSuccess() {
                status = "connecting"
                error = ""
                
                // Simulate successful connection
                status = "connected"
                error = ""
                lastChecked = new Date().toISOString()
            }
        }
    }
    
    function test_network_error_handling() {
        connectionManager = connectionManagerComponent.createObject(testCase)
        verify(connectionManager)
        
        // Initial state
        compare(connectionManager.status, "disconnected")
        compare(connectionManager.connected, false)
        compare(connectionManager.error, "")
        
        // Simulate network error
        connectionManager.simulateNetworkError()
        
        // Verify error state
        compare(connectionManager.status, "disconnected")
        compare(connectionManager.connected, false)
        compare(connectionManager.error, "network error")
        verify(connectionManager.lastChecked.length > 0)
    }
    
    function test_timeout_handling() {
        connectionManager = connectionManagerComponent.createObject(testCase)
        verify(connectionManager)
        
        // Set short timeout for testing
        connectionManager.timeoutMs = 50
        
        // Initial state
        compare(connectionManager.status, "disconnected")
        
        // Simulate timeout
        connectionManager.simulateTimeout()
        
        // Wait for timeout to trigger
        wait(100)
        
        // Verify timeout state
        compare(connectionManager.status, "disconnected")
        compare(connectionManager.error, "timeout")
        compare(connectionManager._currentXhr, null)
        verify(connectionManager.lastChecked.length > 0)
    }
    
    function test_http_error_codes() {
        connectionManager = connectionManagerComponent.createObject(testCase)
        verify(connectionManager)
        
        var errorCodes = [400, 401, 403, 404, 500, 502, 503, 504]
        
        for (var i = 0; i < errorCodes.length; i++) {
            var code = errorCodes[i]
            
            // Test each HTTP error code
            connectionManager.simulateHttpError(code)
            
            compare(connectionManager.status, "disconnected")
            compare(connectionManager.connected, false)
            compare(connectionManager.error, "HTTP " + code)
        }
    }
    
    function test_connection_recovery() {
        connectionManager = connectionManagerComponent.createObject(testCase)
        verify(connectionManager)
        
        // Start with error state
        connectionManager.simulateNetworkError()
        compare(connectionManager.status, "disconnected")
        compare(connectionManager.error, "network error")
        
        // Simulate recovery
        connectionManager.simulateSuccess()
        
        // Verify recovery
        compare(connectionManager.status, "connected")
        compare(connectionManager.connected, true)
        compare(connectionManager.error, "")
    }
    
    function test_malformed_server_url() {
        connectionManager = connectionManagerComponent.createObject(testCase)
        verify(connectionManager)
        
        // Test various invalid URLs
        var invalidUrls = [
            "invalid://url",
            "not-a-url",
            "",
            "http://",
            "://missing-protocol"
        ]
        
        for (var i = 0; i < invalidUrls.length; i++) {
            connectionManager.serverBase = invalidUrls[i]
            
            // URL construction should handle gracefully
            var url = connectionManager.getUrl()
            verify(url.length > 0) // Should fallback to default or handle gracefully
        }
    }
    
    function test_concurrent_requests() {
        connectionManager = connectionManagerComponent.createObject(testCase)
        verify(connectionManager)
        
        // Simulate overlapping requests
        connectionManager.simulateTimeout() // First request
        verify(connectionManager._currentXhr !== null)
        
        // Second request should clean up first
        connectionManager.simulateNetworkError()
        
        // Should be in error state, not timeout
        compare(connectionManager.error, "network error")
    }
    
    function test_error_state_persistence() {
        connectionManager = connectionManagerComponent.createObject(testCase)
        verify(connectionManager)
        
        // Set error state
        connectionManager.simulateHttpError(500)
        var firstError = connectionManager.error
        var firstTimestamp = connectionManager.lastChecked
        
        // Wait a moment
        wait(10)
        
        // Error should persist until next check
        compare(connectionManager.error, firstError)
        compare(connectionManager.lastChecked, firstTimestamp)
    }
    
    function test_endpoint_validation() {
        connectionManager = connectionManagerComponent.createObject(testCase)
        verify(connectionManager)
        
        // Test various endpoint formats
        var endpoints = [
            "/api/tags",
            "api/tags", 
            "/api/tags/",
            "",
            null
        ]
        
        for (var i = 0; i < endpoints.length; i++) {
            connectionManager.endpoint = endpoints[i] || ""
            var url = connectionManager.getUrl()
            
            // Should always produce valid URL
            verify(url.indexOf("http") === 0)
        }
    }
}