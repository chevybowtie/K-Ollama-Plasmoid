/*
    SPDX-FileCopyrightText: 2023 Denys Madureira <denysmb@zoho.com>
    SPDX-FileCopyrightText: 2025 Paul <paul.sturm@cotton-software.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

// Qt modules
import QtCore
import QtMultimedia
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// KDE modules
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import "../js/utils.js" as Utils

PlasmoidItem {
    id: root

    // 1. Layout properties
    hideOnWindowDeactivate: !Plasmoid.configuration.pin

    // 2. Public API properties (for component reuse)
    property string modelsComboboxCurrentValue: ''
    property var modelsArray: []
    property bool hasLocalModel: false
    
    // Translation function for delegate access
    function translate(text) {
        return i18n(text);
    }

    // 3. Internal state properties
    property string parentMessageId: ''
    property var listModelController
    property var promptArray: []
    property string lastUserMessage: '' // Store the last user-entered prompt for quick recall with Up-Arrow
    property bool isLoading: false
    property bool disableAutoScroll: false
    property var currentXhr: null // Track the in-flight XMLHttpRequest so we can abort long-running responses
    
    // 4. Computed state properties for UI binding
    readonly property bool isReady: hasLocalModel && !isLoading  // UI elements that need both conditions
    readonly property bool canSend: isReady && currentXhr === null  // Additional condition for send button

    // Completion sound effect for AI responses
    SoundEffect {
        id: typingSound
        source: "assets/beep.wav"
        volume: 0.1
        loops: 1
    }

    // Local persistent settings (fallback persistence for temperature)
    Settings {
        id: appSettings
        property real ollamaTemperature: 0.7
    }

    // Configuration Change Handlers
    // These Connections objects listen for configuration changes and update the UI state accordingly
    
    // Monitor server URL changes and reset model state when the server changes
    Connections {
        target: Plasmoid.configuration
        function onOllamaServerUrlChanged() {
            Utils.debugLog('info', "Server URL changed to:", Plasmoid.configuration.ollamaServerUrl);
            // Reset model-related state since we're connecting to a different server
            // This prevents stale model data and forces a fresh model list fetch
            root.hasLocalModel = false;
            modelsArray = [];
            modelsComboboxCurrentValue = '';
            getModels(); // Fetch available models from the new server
        }
    }

    // Synchronize temperature changes from KCM configuration to persistent settings
    // The KCM system provides ollamaTemperature as a configuration property,
    // but we need to persist it in Settings for runtime use across sessions
    Connections {
        target: Plasmoid.configuration
        function onOllamaTemperatureChanged() {
            // Use helper function for consistent temperature validation
            appSettings.ollamaTemperature = getValidTemperature(Plasmoid.configuration.ollamaTemperature);
        }
    }

    // UI Focus Management
    // Automatically focus the message input field when the plasmoid becomes visible
    // This provides immediate keyboard access for user interaction without requiring a click
    onVisibleChanged: {
        if (visible && root.hasLocalModel && !root.isLoading && messageField) {
            // Only auto-focus if we have a model available and aren't in a loading state
            // messageField is defined in the CompactRepresentation component
            messageField.forceActiveFocus();
        }
    }

    // Use Utils.getServerUrl(baseUrl, endpoint) to avoid coupling to Plasmoid internals
    function getServerUrl(endpoint) {
        return Utils.getServerUrl(Plasmoid.configuration.ollamaServerUrl, endpoint);
    }

    function parseTextToComboBox(text) {
        return Utils.parseTextToComboBox(text);
    }

    /**
     * Centralized connection manager status update helper
     * Handles safe status updates with error protection
     * @param status - The status to set ("connected" | "disconnected" | "connecting")
     */
    function setConnectionStatus(status) {
        try { 
            connMgr.status = status; 
        } catch (e) { 
            Utils.debugLog('warn', 'Failed to update connection status:', e.message);
        }
    }

    /**
     * Centralized request cleanup helper function
     * Handles consistent cleanup of XHR state, loading indicators, and logging
     * @param reason - A descriptive reason for the request completion (e.g., "completed", "error", "aborted", "timeout")
     */
    function finishRequest(reason) {
        // State cleanup
        root.isLoading = false;
        
        // XHR cleanup with error protection
        try { 
            root.currentXhr = null; 
        } catch(e) {
            Utils.debugLog('warn', 'Error clearing currentXhr during finishRequest:', e.message);
        }
        
        // Consistent logging for debugging and monitoring
        Utils.debugLog('debug', 'Request finished:', reason);
    }

    /**
     * Temperature configuration validation and conversion helper
     * Handles the null/undefined check pattern used throughout the component
     * @param configValue - The raw configuration value to validate
     * @param fallback - The fallback value to use if configValue is invalid
     * @returns A valid number for temperature
     */
    function getValidTemperature(configValue, fallback = 0.7) {
        return (configValue !== undefined && configValue !== null) ? Number(configValue) : fallback;
    }

    /**
     * Core chat request function that handles the complete conversation flow
     * @param messageField - The input text field to clear after sending
     * @param listModel - The conversation history model to append messages to
     * @param scrollView - The scroll view containing the conversation for auto-scroll behavior
     * @param prompt - The user's message text to send to Ollama
     */
    function request(messageField, listModel, scrollView, prompt) {
        // Message State Management
        // Store the last user message for Up-Arrow recall functionality
        // Only store non-empty messages to prevent recalling empty strings
        if (prompt && prompt.toString().trim().length > 0) {
            root.lastUserMessage = prompt.toString();
        }

        // Clear the input field immediately to provide visual feedback that the message was sent
        messageField.text = '';

        // Update Conversation History
        // Add user message to the visual conversation list (listModel)
        listModel.append({
            "name": "User",
            "number": prompt // 'number' is legacy naming for message content
        });

        // Add user message to the API conversation array for context preservation
        // Ollama requires the full conversation history for context-aware responses
        promptArray.push({ "role": "user", "content": prompt, "images": [] });

        // UI State Updates
        // Set loading state to show progress indicators and disable input
        root.isLoading = true;

        // Auto-scroll to bottom to show the new message and prepare for response
        // Only scroll if auto-scroll hasn't been disabled by user interaction
        if (!root.disableAutoScroll && scrollView && scrollView.contentItem) {
            scrollView.contentItem.positionViewAtEnd();
        }

        // HTTP Request Preparation
        // Track initial conversation length for streaming response insertion
        const oldLength = listModel.count;
        
        // Build Ollama API endpoint URL
        const url = getServerUrl('chat');
        
        // Construct request payload with conversation context and model parameters
        const data = JSON.stringify({
            "model": modelsComboboxCurrentValue, // Currently selected AI model
            "keep_alive": "5m", // Keep model loaded in memory for 5 minutes after request
            "options": {
                // Use helper function for consistent temperature handling
                "temperature": getValidTemperature(Plasmoid.configuration.ollamaTemperature)
            },
            "messages": promptArray // Full conversation history for context
        });
        
        // XMLHttpRequest Setup
        // Create new request instance for this conversation turn
        let xhr = new XMLHttpRequest();
        // Store reference globally so "Stop generating" button can abort mid-stream
        root.currentXhr = xhr;

        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        
        // Streaming Response Processing Setup
        // Track processed content length to avoid reprocessing the same data
        // Ollama streams responses as multiple JSON objects separated by newlines
        let lastProcessedLength = 0;
        
        /**
         * Real-time streaming response handler
         * Processes incoming data incrementally as it arrives from Ollama
         * This enables live text generation display instead of waiting for complete responses
         */
        xhr.onreadystatechange = function() {
            // State Filtering: Only process during active data transfer or completion
            // LOADING = data is actively being received, DONE = transfer complete
            if (xhr.readyState !== XMLHttpRequest.LOADING && xhr.readyState !== XMLHttpRequest.DONE) {
                return;
            }
            
            // Incremental Processing: Only handle new data since last processing cycle
            const responseText = xhr.responseText;
            if (responseText.length <= lastProcessedLength) {
                return; // No new data to process - avoid redundant work
            }
            
            // Extract only the new portion of the response stream
            // This prevents reprocessing already-handled content on each event
            const newText = responseText.substring(lastProcessedLength);
            const newObjects = newText.split('\n'); // Ollama sends one JSON per line
            
            // Update processing checkpoint for next iteration
            lastProcessedLength = responseText.length;
            
            // Response Accumulation: Build complete text from streaming chunks
            let text = '';
            
            // Retrieve existing accumulated text if this is a continuation update
            // Assistant responses are appended at position oldLength in the conversation
            if (listModel.count > oldLength) {
                const lastValue = listModel.get(oldLength);
                text = lastValue.number; // Start with previously accumulated content
            }

            // JSON Stream Processing: Parse each line as a separate JSON object
            // Ollama's streaming format sends one JSON object per line, containing message chunks
            newObjects.forEach((object, index) => {
                if (object.trim() === '') return; // Skip empty lines between JSON objects
                
                try {
                    // Parse JSON chunk and extract content from nested message structure
                    const parsedObject = JSON.parse(object);
                    // Ollama format: { "message": { "content": "text chunk" }, ... }
                    const messageContent = parsedObject && parsedObject.message && parsedObject.message.content ? parsedObject.message.content : '';
                    text = text + messageContent; // Accumulate chunks into complete response
                } catch (e) {
                    // Log malformed JSON but continue processing - don't break the stream
                    Utils.debugLog('warn', 'Failed to parse JSON object:', object, 'Error:', e.message);
                    return; // Skip this malformed chunk and continue with others
                }
            });

            // UI Update Strategy: Batch updates to minimize rendering overhead
            // Only update the UI when we have actual content to display
            if (text.length > 0) {
                // Auto-scroll Management: Keep the latest content visible during generation
                // Use ListView's built-in method for reliable scrolling to the end
                if (!root.disableAutoScroll && scrollView && scrollView.contentItem) {
                    scrollView.contentItem.positionViewAtEnd();
                }

                // Conversation Model Update: Create new entry or update existing one
                if (listModel.count === oldLength) {
                    // First chunk: Create new assistant message entry
                    listModel.append({
                        "name": "Assistant",
                        "number": text // 'number' property holds the message content
                    });
                } else {
                    // Subsequent chunks: Update the existing assistant message with accumulated text
                    const lastValue = listModel.get(oldLength);
                    lastValue.number = text; // Replace content with updated accumulated text
                }
            }
        };

        /**
         * Request Completion Handler
         * Executed when the streaming response is fully complete
         * Handles final cleanup and conversation context management
         */
        xhr.onload = function() {
            // Final Response Text Extraction
            // Safely retrieve the complete assistant response from the conversation model
            var assistantText = "";
            try {
                if (listModel.count > oldLength) {
                    var lastValue = listModel.get(oldLength);
                    if (lastValue && typeof lastValue.number !== 'undefined' && lastValue.number !== null) {
                        assistantText = lastValue.number; // Complete accumulated response text
                    }
                }
            } catch (e) {
                // Defensive programming: Handle potential model access errors gracefully
                // Leave assistantText empty rather than crash the application
                Utils.debugLog('warn', 'Error extracting assistant text:', e.message);
            }

            // Response Validation and Feedback
            if (!assistantText || assistantText.length === 0) {
                // Log missing response for debugging - this shouldn't happen in normal operation
                Utils.debugLog('debug', 'xhr.onload: assistantText missing for request at oldLength=', oldLength, 'listModel.count=', listModel.count);
                finishRequest('completed-empty-response');
            } else {
                // Audio Feedback: Play completion sound when configured by user
                // Provides audible notification that the AI response is complete
                if (Plasmoid.configuration.completionSound) {
                    typingSound.play();
                }
                finishRequest('completed-successfully');
            }
            
            // Conversation Context Preservation
            // Add the assistant's response to the conversation array for future context
            // This maintains conversation history for subsequent requests
            promptArray.push({ "role": "assistant", "content": assistantText, "images": [] });
        };

        /**
         * Request Abort Handler
         * Triggered when user clicks "Stop generating" during an active response
         */
        xhr.onabort = function() {
            finishRequest('aborted-by-user');
        };

        /**
         * Network Error Handler
         * Handles connection failures, server errors, and other network issues
         */
        xhr.onerror = function() {
            Utils.debugLog('error', 'Network error during chat request');
            finishRequest('network-error');
        };

        /**
         * Request Timeout Handler
         * Triggered if the server doesn't respond within the configured timeout period
         */
        xhr.ontimeout = function() {
            Utils.debugLog('warn', 'Chat request timeout');
            finishRequest('timeout');
        };

        xhr.timeout = 30000; // 30 seconds timeout
        xhr.send(data);
    }

    function deleteMessage(index) {
        // Remove from visual list model
        root.listModelController.remove(index);
        
        // Remove from prompt array (conversation history)
        if (index < promptArray.length) {
            promptArray.splice(index, 1);
        }
    }

    /**
     * Model Discovery and State Management Function
     * Fetches available AI models from the Ollama server and updates UI state
     * This function is critical for establishing whether the plasmoid is functional
     */
    function getModels() {
        // API Endpoint Construction
        const url = getServerUrl('tags'); // Ollama's /api/tags endpoint lists available models
        Utils.debugLog('debug', "Fetching models from:", url);

        // HTTP Request Setup
        let xhr = new XMLHttpRequest();
        xhr.open('GET', url);
        xhr.setRequestHeader('Content-Type', 'application/json');

        /**
         * Model Fetch Response Handler
         * Processes the server response and updates the entire UI state based on availability
         */
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    // Response Processing: Extract model names from Ollama API format
                    // Ollama returns: { "models": [{ "name": "model1", "model": "model1", ... }, ...] }
                    const objects = JSON.parse(xhr.responseText).models;
                    const models = objects.map(object => object.model); // Extract just the model names

                    if (models.length) {
                        // Success Path: Models available, enable UI functionality
                        root.hasLocalModel = true;
                        
                        // Connection State Synchronization: Update connection manager status
                        // This provides consistent status across UI components
                        setConnectionStatus("connected");

                        // Model Selection Logic: Restore previous selection or use default
                        // Maintains user preference across application restarts
                        const savedModel = Plasmoid.configuration.selectedModel;
                        if (savedModel && models.includes(savedModel)) {
                            // Restore previously selected model if it still exists on server
                            modelsComboboxCurrentValue = savedModel;
                        } else {
                            // Fall back to first available model and persist this choice
                            modelsComboboxCurrentValue = models[0];
                            Plasmoid.configuration.selectedModel = models[0];
                        }

                        // UI Model Array Construction: Create display-friendly model list
                        // Maps internal model names to human-readable text for the ComboBox
                        root.modelsArray = models.map(model => ({ 
                            text: parseTextToComboBox(model), // Format for display
                            value: model // Keep original name for API calls
                        }));
                        Utils.debugLog('info', "Successfully loaded", models.length, "models");
                    } else {
                        // Empty Response: Server has no models installed
                        root.hasLocalModel = false;
                        setConnectionStatus("disconnected");
                        Utils.debugLog('info', "No models found on server");
                    }
                } else {
                    // Error Response: Server unreachable or API error
                    root.hasLocalModel = false;
                    setConnectionStatus("disconnected");
                    Utils.debugLog('error', 'Error fetching models:', xhr.status, xhr.statusText, 'from', url);
                }
            }
        };

        xhr.onerror = function() {
            root.hasLocalModel = false;
            setConnectionStatus("disconnected");
            Utils.debugLog('error', 'Network error when fetching models from:', url);
        };

        xhr.ontimeout = function() {
            root.hasLocalModel = false;
            setConnectionStatus("disconnected");
            Utils.debugLog('warn', 'Timeout when fetching models from:', url);
        };

        xhr.timeout = 10000; // 10 seconds timeout for model fetching
        xhr.send();
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: root.translate("Keep Open")
            icon.name: "window-pin"
            checkable: true
            checked: Plasmoid.configuration.pin
            onTriggered: Plasmoid.configuration.pin = checked
        },
        PlasmaCore.Action {
            text: root.translate("Clear chat")
            icon.name: "edit-clear"
            onTriggered: {
                listModelController.clear();
                promptArray = [];
            }
        },
        PlasmaCore.Action {
            text: root.translate("Disable auto scroll")
            icon.name: "transform-move-vertical"
            checkable: true
            checked: disableAutoScroll
            onTriggered: disableAutoScroll = !disableAutoScroll
        }
    ]

    compactRepresentation: CompactRepresentation {}

    // Connection status manager - placed at top level for accessibility
    ConnectionManager {
        id: connMgr
        interval: 5000
        timeoutMs: 2500
        serverBase: Plasmoid.configuration.ollamaServerUrl || ''
    }

    Component.onCompleted: {
        // Initialize temperature with bidirectional sync using helper function
        const configTemp = getValidTemperature(Plasmoid.configuration.ollamaTemperature, appSettings.ollamaTemperature);
        if (Plasmoid.configuration.ollamaTemperature === undefined || Plasmoid.configuration.ollamaTemperature === null) {
            Plasmoid.configuration.ollamaTemperature = configTemp;
        }
        appSettings.ollamaTemperature = configTemp;

        getModels();
    }

    Component.onDestruction: {
        // Abort any in-flight requests
        if (currentXhr) {
            try { 
                currentXhr.abort(); 
            } catch(e) {
                Utils.debugLog('debug', 'Error aborting XHR during destruction:', e.message);
            }
            currentXhr = null;
        }
        
        // Clear arrays to prevent memory leaks
        promptArray = [];
        modelsArray = [];
        
        Utils.debugLog('debug', 'Main plasmoid component destroyed and cleaned up');
    }

    fullRepresentation: ColumnLayout {
        Layout.preferredHeight: 400
        Layout.preferredWidth: 350
        Layout.fillWidth: true
        Layout.fillHeight: true

        PlasmaExtras.PlasmoidHeading {
            width: parent.width

            contentItem: RowLayout {
                visible: root.hasLocalModel
                Layout.fillWidth: true

                PlasmaComponents.Button {
                    id: pinButton
                    checkable: true
                    checked: Plasmoid.configuration.pin
                    onToggled: Plasmoid.configuration.pin = checked
                    icon.name: "window-pin"

                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: root.translate("Keep Open")

                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }

                PlasmaComponents.ComboBox {
                    id: modelsCombobox
                    enabled: root.isReady
                    hoverEnabled: root.isReady

                    Layout.fillWidth: true

                    model: root.modelsArray.map(model => model.text)

                    onActivated: {
                        modelsComboboxCurrentValue = root.modelsArray.find(model => model.text === modelsCombobox.currentText).value;
                        // Save selected model to configuration
                        Plasmoid.configuration.selectedModel = modelsComboboxCurrentValue;
                        root.listModelController.clear();
                    }

                    // Update the current selection when models array changes
                    onModelChanged: {
                        if (root.modelsArray.length > 0) {
                            if (modelsComboboxCurrentValue) {
                                // Find and set the index of the saved/current model
                                const modelIndex = root.modelsArray.findIndex(model => model.value === modelsComboboxCurrentValue);
                                if (modelIndex >= 0) {
                                    currentIndex = modelIndex;
                                } else {
                                    // Fallback to first model if saved model not found
                                    currentIndex = 0;
                                    modelsComboboxCurrentValue = modelsArray[0].value;
                                    Plasmoid.configuration.selectedModel = modelsArray[0].value;
                                }
                            } else {
                                // No current model, use first one
                                currentIndex = 0;
                                modelsComboboxCurrentValue = modelsArray[0].value;
                                Plasmoid.configuration.selectedModel = modelsArray[0].value;
                            }
                        }
                    }

                    Component.onCompleted: root.getModels()
                }

                PlasmaComponents.Button {
                    icon.name: "edit-clear-symbolic"
                    text: root.translate("Clear chat")
                    display: PlasmaComponents.AbstractButton.IconOnly
                    enabled: root.isReady
                    hoverEnabled: root.isReady

                    onClicked: {
                        listModelController.clear();
                        promptArray = [];
                    }

                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }

                PlasmaComponents.Button {
                    icon.name: "configure"
                    text: root.translate("Configure")
                    display: PlasmaComponents.AbstractButton.IconOnly
                    enabled: true
                    hoverEnabled: true

                    onClicked: {
                        Plasmoid.internalAction("configure").trigger();
                    }

                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }

                PlasmaComponents.Button {
                    icon.name: "transform-move-vertical"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    checkable: true
                    checked: root.disableAutoScroll
                    enabled: true
                    hoverEnabled: true

                    onToggled: {
                        root.disableAutoScroll = checked
                    }

                    PlasmaComponents.ToolTip.text: root.disableAutoScroll ? 
                        root.translate("Enable auto scroll") : 
                        root.translate("Disable auto scroll")
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }

                // Connection indicator: colored dot only
                Item {
                    id: connStatusItem
                    width: 18
                    height: 18

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        onClicked: connMgr.check()
                        hoverEnabled: true
                    }

                    // small colored dot for consistent at-a-glance state
                    Rectangle {
                        id: stateDot
                        anchors.centerIn: parent
                        width: 12
                        height: 12
                        radius: 6
                        color: connMgr.connected ? "#4CAF50" : (connMgr.status === "connecting" ? "#FFC107" : "#9E9E9E")
                        border.width: 1
                        border.color: Qt.lighter(stateDot.color, 1.2)
                        opacity: connMgr.connected ? 1.0 : (connMgr.status === "connecting" ? 0.95 : 0.8)
                    }

                    PlasmaComponents.ToolTip.text: connMgr.connected ? root.translate("Connected to Ollama") : (connMgr.status === "connecting" ? root.translate("Connecting...") : root.translate("Disconnected. Click to retry."))
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    // Use containsMouse for a more robust hover check
                    PlasmaComponents.ToolTip.visible: hoverArea && hoverArea.containsMouse
                }
            }
        }

        ScrollView {
            id: scrollView

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 150
            clip: true

            ListView {
                id: listView
                spacing: Kirigami.Units.smallSpacing

                Layout.fillWidth: true
                Layout.fillHeight: true

                Kirigami.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - (Kirigami.Units.largeSpacing * 4)
                    visible: listView.count === 0
                    text: root.hasLocalModel ? root.translate("I am ready...") : root.translate("No LLM models found.\n\nPlease check:\n1. Ollama server is running\n2. Server URL is correct in settings\n3. Models are installed on the server\n\nClick 'Refresh models list' to retry.")
                }

                model: ListModel {
                    id: listModel

                    Component.onCompleted: {
                        listModelController = listModel;
                    }
                }

                delegate: Kirigami.AbstractCard {
                    Layout.fillWidth: true

                    contentItem: Item {
                        implicitHeight: textMessageLoader.implicitHeight + (cardButtonsLayout ? cardButtonsLayout.implicitHeight : 0) + 16
                        
                        /**
                         * Dynamic Component Loading System for Message Rendering
                         * Switches between plain text and markdown rendering based on user configuration
                         * This architecture allows runtime switching without restart
                         */
                        Loader {
                            id: textMessageLoader
                            
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8
                            
                            // Height calculation delegation to the loaded component
                            // This ensures proper layout regardless of which component is active
                            readonly property real implicitHeight: textMessageLoader.item ? textMessageLoader.item.implicitHeight : 0
                            
                            // Dynamic Component Selection: Load appropriate renderer based on markdown setting
                            // Configuration changes trigger automatic component reloading
                            sourceComponent: Plasmoid.configuration.enableMarkdown ? markdownComponent : plainTextComponent
                            
                            Component {
                                id: plainTextComponent
                                TextEdit {
                                    id: textMessage
                                    readOnly: true
                                    wrapMode: Text.WordWrap
                                    text: number
                                    color: name === "User" ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
                                    selectByMouse: true
                                    
                                    function selectAll() { textMessage.selectAll() }
                                    function copy() { textMessage.copy() }
                                    function deselect() { textMessage.deselect() }
                                }
                            }
                            
                            Component {
                                id: markdownComponent
                                TextArea {
                                    id: markdownTextArea
                                    readOnly: true
                                    wrapMode: TextArea.Wrap
                                    text: number
                                    textFormat: TextArea.MarkdownText
                                    color: name === "User" ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
                                    selectByMouse: true
                                    background: null
                                    
                                    function selectAll() { markdownTextArea.selectAll() }
                                    function copy() { markdownTextArea.copy() }
                                    function deselect() { markdownTextArea.deselect() }
                                }
                            }
                        }

                        RowLayout {
                            id: cardButtonsLayout
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            spacing: 2
                            visible: cardHoverHandler.hovered

                            PlasmaComponents.Button {
                                icon.name: "edit-copy-symbolic"
                                text: root.translate("Copy")
                                display: PlasmaComponents.AbstractButton.IconOnly
                                
                                onClicked: {
                                    if (textMessageLoader.item) {
                                        textMessageLoader.item.selectAll();
                                        textMessageLoader.item.copy();
                                        textMessageLoader.item.deselect();
                                    }
                                }

                                PlasmaComponents.ToolTip.text: text
                                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                                PlasmaComponents.ToolTip.visible: hovered
                            }

                            PlasmaComponents.Button {
                                icon.name: "edit-delete-symbolic"
                                text: root.translate("Delete")
                                display: PlasmaComponents.AbstractButton.IconOnly
                                
                                onClicked: {
                                    deleteMessage(index);
                                }

                                PlasmaComponents.ToolTip.text: text
                                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                                PlasmaComponents.ToolTip.visible: hovered
                            }
                        }

                        HoverHandler {
                            id: cardHoverHandler
                        }
                    }
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            clip: true
            visible: root.hasLocalModel

            TextArea {
                id: messageField

                Layout.fillWidth: true
                Layout.fillHeight: true

                enabled: root.isReady
                hoverEnabled: root.isReady
                placeholderText: root.translate("Type here what you want to ask...")
                wrapMode: TextArea.Wrap

                Component.onCompleted: {
                    // Auto-focus when component is ready and models are loaded
                    if (hasLocalModel && !isLoading) {
                        forceActiveFocus();
                    }
                }

                // Auto-focus when models become available
                onEnabledChanged: {
                    if (enabled) {
                        forceActiveFocus();
                    }
                }

                Keys.onPressed: function(event) {
                    // If Up arrow pressed, and caret is on the first line, recall lastUserMessage
                    if (event.key === Qt.Key_Up) {
                        // TextArea provides positionToRectangle to determine current cursor row via y coordinate,
                        // but that's heavyweight; instead, inspect the text before the cursor for newlines.
                        var caretPos = messageField.cursorPosition;
                        var isAtFirstLine = Utils.caretIsOnFirstLine(messageField.text, caretPos);

                        if (isAtFirstLine && root.lastUserMessage && root.lastUserMessage.length > 0) {
                            // Repopulate the field and place caret at end
                            messageField.text = root.lastUserMessage;
                            messageField.cursorPosition = messageField.text.length;
                            event.accepted = true;
                            return;
                        } else {
                            // Let default behavior (move caret up) occur
                            event.accepted = false;
                            return;
                        }
                    }
                    // Handle both main Enter (Return) and numpad Enter
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        var ctrl = (event.modifiers & Qt.ControlModifier);
                        if (Plasmoid.configuration.enterToSend) {
                            // New behavior: Enter sends, Ctrl+Enter adds new line
                            if (ctrl) {
                                // Ctrl+Enter: add new line
                                var cursorPosition = messageField.cursorPosition;
                                messageField.insert(cursorPosition, "\n");
                                event.accepted = true;
                            } else {
                                // Enter: send message
                                if (messageField.text.trim().length > 0) {
                                    root.request(messageField, listModel, scrollView, messageField.text);
                                    event.accepted = true;
                                } else {
                                    event.accepted = false;
                                }
                            }
                        } else {
                            // Original behavior: Ctrl+Enter sends, Enter adds new line
                            if (ctrl) {
                                // Ctrl+Enter: send message
                                if (messageField.text.trim().length > 0) {
                                    request(messageField, listModel, scrollView, messageField.text);
                                    event.accepted = true;
                                } else {
                                    event.accepted = false;
                                }
                            } else {
                                // Enter: add new line (let default behavior)
                                event.accepted = false;
                            }
                        }
                    }
                }

                BusyIndicator {
                    id: indicator
                    anchors.centerIn: parent
                    running: root.isLoading
                }
            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            // Wide Send button
            Button {
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                text: root.translate("Send")
                hoverEnabled: root.isReady
                enabled: root.isReady
                visible: root.hasLocalModel

                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: "CTRL+Enter"

                onClicked: {
                    request(messageField, listModel, scrollView, messageField.text);
                }
            }

            // Narrow stop icon button to the right of Send
            ToolButton {
                Layout.alignment: Qt.AlignVCenter
                // Keep the stop button narrow — doesn't expand like the Send button
                Layout.preferredWidth: implicitWidth

                icon.name: "media-playback-stop"
                visible: root.hasLocalModel
                enabled: root.hasLocalModel && root.isLoading && root.currentXhr !== null

                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: root.translate("Stop")

                onClicked: {
                    if (root.currentXhr) {
                        try { 
                            root.currentXhr.abort(); // This will trigger xhr.onabort which calls finishRequest()
                        } catch (e) {
                            // If abort fails, still clean up manually
                            finishRequest('stop-button-abort-failed');
                        }
                    } else {
                        // No XHR but still in loading state - clean up anyway
                        finishRequest('stop-button-no-xhr');
                    }
                }
            }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            
            text: root.translate("Refresh models list")
            visible: !root.hasLocalModel
            
            onClicked: root.getModels()
        }
    }
}
