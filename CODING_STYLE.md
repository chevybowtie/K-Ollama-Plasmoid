# K-Ollama Plasmoid - Code Style & Patterns Guide

This document outlines the coding conventions, architectural patterns, and best practices used in the K-Ollama Plasmoid codebase. Follow these guidelines to maintain consistency and code quality.

## Project Structure

```
contents/
├── config/          # Configuration schema and UI definitions
│   ├── main.xml     # KConfig schema for persistent settings
│   └── config.qml   # Configuration page structure
├── js/              # Shared JavaScript utilities
│   └── utils.js     # Pure functions for common operations
└── ui/              # QML user interface components
    ├── main.qml                    # Main plasmoid logic and UI
    ├── CompactRepresentation.qml   # Panel icon representation  
    ├── ConfigAppearance.qml        # Appearance settings page
    ├── ConfigServer.qml            # Server settings page
    ├── ConnectionManager.qml       # Network connection handling
    └── assets/                     # Static resources (icons, sounds)
```

## File Organization Principles

### 1. Separation of Concerns
- **`js/utils.js`**: Pure utility functions, no QML dependencies
- **`ui/*.qml`**: UI components and application logic
- **`config/`**: Configuration schema and settings UI
- **`assets/`**: Static resources only

### 2. Import Order Convention
QML files should import modules in this order:
```qml
// 1. Qt Core modules
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 2. Qt Additional modules  
import QtMultimedia
import QtCore

// 3. KDE/Plasma modules
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

// 4. Local imports (always last)
import "../js/utils.js" as Utils
```

## JavaScript Style Guide

### Function Documentation
All utility functions must include JSDoc documentation:

```javascript
/**
 * Brief description of the function's purpose.
 *
 * Detailed explanation of behavior, edge cases, and examples if complex.
 *
 * @param {type} paramName - Parameter description
 * @param {type|undefined} optionalParam - Optional parameter description  
 * @returns {type} Return value description
 */
function functionName(paramName, optionalParam) {
    // Implementation
}
```

### Naming Conventions
- **Functions**: `camelCase` - `getServerUrl()`, `parseTextToComboBox()`
- **Constants**: `UPPER_SNAKE_CASE` (if needed)
- **Variables**: `camelCase` - `serverUrl`, `isConnected`

### Error Handling
Utility functions should be defensive and handle edge cases:
```javascript
function safeFunction(input) {
    // Always validate inputs
    if (!input || typeof input !== 'string') return defaultValue;
    
    // Handle edge cases explicitly
    if (input.length === 0) return '';
    
    // Proceed with main logic
    return processInput(input);
}
```

### Pure Functions
Utility functions should be pure (no side effects):
```javascript
// ✅ Good - Pure function
function formatModelName(rawName) {
    return rawName.replace(/-/g, ' ').toLowerCase();
}

// ❌ Avoid - Side effects
function formatModelName(rawName) {
    console.log('Formatting:', rawName); // Side effect
    return rawName.replace(/-/g, ' ').toLowerCase();
}
```

## QML Style Guide

### Property Declaration Order
Properties should be declared in this order:

```qml
Item {
    id: root
    
    // 1. Layout properties
    width: 400
    height: 300
    
    // 2. Public API properties (for component reuse)
    property string serverUrl: ""
    property bool isConnected: false
    
    // 3. Internal state properties  
    property var currentXhr: null
    property bool isLoading: false
    
    // 4. Signal handlers
    onVisibleChanged: {
        // Handle visibility
    }
    
    // 5. Child components
    SomeChildComponent {
        // ...
    }
}
```

### Configuration Property Patterns

#### Configuration Page Components
Configuration pages use a specific pattern for KDE integration:

```qml
KCM.SimpleKCM {
    // 1. Direct cfg_ bindings for active settings
    property alias cfg_settingName: controlId.checked
    property string cfg_serverUrl: ""
    
    // 2. Ignore irrelevant settings from other config pages  
    property string cfg_otherPageSetting: ""  // Prevents warnings
    
    // 3. Ignore "Default" variants the system auto-creates
    property bool cfg_settingNameDefault: false
    
    // 4. Handle special settings that need custom logic
    property bool cfg_debugLogs: false
    onCfg_debugLogsChanged: {
        Utils.debugLog('info', 'Debug logs toggled:', cfg_debugLogs);
    }
}
```

### Component Communication Patterns

#### Property Binding for State Management
Use declarative property bindings for derived state:
```qml
ConnectionManager {
    id: connectionMgr
    serverBase: Plasmoid.configuration.ollamaServerUrl
}

// Bind UI state to connection manager
Button {
    enabled: connectionMgr.connected && !root.isLoading
    text: connectionMgr.connected ? "Send" : "Connecting..."
}
```

#### Signal-Based Event Handling
Use signals for actions and events:
```qml
Button {
    onClicked: {
        if (validateInput()) {
            sendMessage(inputField.text);
        }
    }
}
```

### Error Handling Patterns

#### XMLHttpRequest Error Handling
Network requests should handle all error scenarios:
```qml
function makeRequest(url, data) {
    var xhr = new XMLHttpRequest();
    
    xhr.onload = function() {
        if (xhr.status >= 200 && xhr.status < 300) {
            handleSuccess(xhr.responseText);
        } else {
            handleError('HTTP Error: ' + xhr.status);
        }
    };
    
    xhr.onerror = function() {
        handleError('Network error occurred');
    };
    
    xhr.ontimeout = function() {
        handleError('Request timeout');
    };
    
    xhr.timeout = 30000; // Always set timeout
    xhr.open('POST', url);
    xhr.send(data);
}
```

### Memory Management

#### Cleanup Patterns
Always clean up resources and connections:
```qml
Component.onDestruction: {
    // Abort any in-flight requests
    if (currentXhr) {
        currentXhr.abort();
        currentXhr = null;
    }
    
    // Stop timers
    if (pollTimer.running) {
        pollTimer.stop();
    }
}
```

#### Avoid Memory Leaks
```qml
// ✅ Good - Clean reference management
property var currentXhr: null

function startRequest() {
    // Clean up previous request
    if (currentXhr) {
        currentXhr.abort();
        currentXhr = null;
    }
    
    currentXhr = new XMLHttpRequest();
    // ... configure request
}

// ❌ Avoid - Accumulating references
property var requests: [] // Don't store arrays of XHR objects
```

## Architectural Patterns

### 1. Utility Module Pattern
Keep pure business logic in `js/utils.js`:
- No QML dependencies  
- Fully unit testable
- Reusable across components

```javascript
// utils.js - Pure functions only
function getServerUrl(baseUrl, endpoint) {
    var base = baseUrl || 'http://127.0.0.1:11434';
    return base.replace(/\/+$/, '') + '/api/' + (endpoint || '').replace(/^\/+/, '');
}
```

### 2. Configuration Manager Pattern
Use KDE's configuration system consistently:
```qml
// Access configuration
Plasmoid.configuration.serverUrl

// React to changes
Connections {
    target: Plasmoid.configuration
    function onServerUrlChanged() {
        refreshConnection();
    }
}
```

### 3. State Management Pattern
Use reactive properties for state:
```qml
PlasmoidItem {
    // Centralized state
    property bool isLoading: false
    property bool hasModels: modelsArray.length > 0
    property bool canSend: hasModels && !isLoading && inputText.length > 0
    
    // UI reacts to state changes
    Button {
        enabled: canSend
        text: isLoading ? "Sending..." : "Send"
    }
}
```

### 4. Component Composition Pattern
Break complex UI into focused components:
```qml
// main.qml - Orchestrates components
PlasmoidItem {
    ConnectionManager {
        id: connectionMgr
        serverBase: Plasmoid.configuration.ollamaServerUrl
    }
    
    MessageList {
        id: messageList  
        model: chatModel
    }
    
    MessageInput {
        id: messageInput
        enabled: connectionMgr.connected
        onMessageSent: sendToOllama(message)
    }
}
```

## Testing Patterns

### Testable Utility Functions
Write utilities to be easily testable:
```javascript
// ✅ Good - Easy to test
function parseModelName(input) {
    if (!input) return "";
    return input.replace(/-/g, ' ').replace(/:/g, ' (') + ')';
}

// ✅ Test case
function test_parseModelName() {
    compare(Utils.parseModelName("gpt-4:latest"), "gpt 4 (latest)");
}
```

### Mock Patterns for QML Tests
Use dependency injection for testable QML:
```qml
// Component accepts dependencies
ConnectionManager {
    property var httpClient: Qt.createQmlObject("import QtQuick 2.15; QtObject { function request() {} }", parent)
}

// Test injects mock
TestCase {
    function test_connection() {
        var mockHttp = createMockHttpClient();
        connectionMgr.httpClient = mockHttp;
        connectionMgr.check();
        // Assert behavior
    }
}
```

## Performance Guidelines

### 1. Minimize Property Bindings
```qml
// ✅ Good - Direct binding
visible: connectionMgr.connected

// ❌ Avoid - Complex expression binding
visible: connectionMgr.status === "connected" && !isLoading && hasModels && inputText.trim().length > 0
```

### 2. Use Appropriate Timers
```qml
// Connected state - poll less frequently  
Timer {
    interval: connectionMgr.connected ? 30000 : 5000
    repeat: true
    onTriggered: checkConnection()
}
```

### 3. Lazy Loading
```qml
Loader {
    active: visible  // Only load when needed
    sourceComponent: ExpensiveComponent {}
}
```

## Error Handling Strategy

### 1. Graceful Degradation
Always provide fallback behavior:
```qml
Text {
    text: hasModels ? "Ready to chat!" : "No models available. Check server connection."
}

Button {
    enabled: hasModels && !isLoading
    text: isLoading ? "Processing..." : "Send"
}
```

### 2. User-Friendly Error Messages
```qml
function handleConnectionError(error) {
    var userMessage;
    if (error.includes("timeout")) {
        userMessage = "Server is not responding. Check if Ollama is running.";
    } else if (error.includes("refused")) {
        userMessage = "Cannot connect to server. Verify server URL in settings.";
    } else {
        userMessage = "Connection error. Please try again.";
    }
    showErrorMessage(userMessage);
}
```

### 3. Debug Logging
Use conditional debug logging:
```javascript
function debugLog(level, message, data) {
    // Only log if debug mode is enabled
    if (Plasmoid.configuration.debugLogs) {
        console[level](message, data || '');
    }
}
```

## Security Considerations

### 1. Input Validation
Always validate user inputs:
```javascript
function validateServerUrl(url) {
    if (!url || typeof url !== 'string') return false;
    try {
        new URL(url); // Will throw if invalid
        return true;
    } catch (e) {
        return false;
    }
}
```

### 2. Safe Property Access
Use defensive property access:
```qml
// ✅ Safe access
text: response && response.message ? response.message.content : "No response"

// ❌ Unsafe - can crash
text: response.message.content
```

## Conclusion

Following these patterns ensures:
- **Maintainable** code that's easy to understand and modify
- **Testable** components with clear dependencies  
- **Robust** error handling and graceful degradation
- **Performant** UI that responds smoothly to user interaction
- **Consistent** codebase that follows KDE/Qt best practices

When in doubt, follow the existing patterns in the codebase and prioritize simplicity and readability over cleverness.