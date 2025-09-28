/*
    SPDX-FileCopyrightText: 2023 Denys Madureira <denysmb@zoho.com>
    SPDX-FileCopyrightText: 2025 Paul <paul.sturm@cotton-software.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import QtCore
import "../js/utils.js" as Utils

PlasmoidItem {
    id: root

    // 1. Layout properties
    hideOnWindowDeactivate: !Plasmoid.configuration.pin

    // 2. Public API properties (for component reuse)
    property string modelsComboboxCurrentValue: ''
    property var modelsArray: []
    property bool hasLocalModel: false

    // 3. Internal state properties
    property string parentMessageId: ''
    property var listModelController
    property var promptArray: []
    property string lastUserMessage: '' // Store the last user-entered prompt for quick recall with Up-Arrow
    property bool isLoading: false
    property bool disableAutoScroll: false
    property var currentXhr: null // Track the in-flight XMLHttpRequest so we can abort long-running responses

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

    // Watch for server URL configuration changes
    Connections {
        target: Plasmoid.configuration
        function onOllamaServerUrlChanged() {
            Utils.debugLog('info', "Server URL changed to:", Plasmoid.configuration.ollamaServerUrl);
            hasLocalModel = false;
            modelsArray = [];
            modelsComboboxCurrentValue = '';
            getModels();
        }
    }

    // Persist temperature changes from the settings UI into local Settings
    Connections {
        target: Plasmoid.configuration
        function onOllamaTemperatureChanged() {
            if (Plasmoid.configuration.ollamaTemperature !== undefined && Plasmoid.configuration.ollamaTemperature !== null) {
                appSettings.ollamaTemperature = Number(Plasmoid.configuration.ollamaTemperature);
            }
        }
    }

    // Auto-focus textarea when plasmoid becomes visible
    onVisibleChanged: {
        if (visible && hasLocalModel && !isLoading && messageField) {
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

    function request(messageField, listModel, scrollView, prompt) {
        // Save last user message (trimmed) so Up-Arrow can recall it later
        if (prompt && prompt.toString().trim().length > 0) {
            lastUserMessage = prompt.toString();
        }

        messageField.text = '';

        listModel.append({
            "name": "User",
            "number": prompt
        });

        promptArray.push({ "role": "user", "content": prompt, "images": [] });

        isLoading = true;

        if (!disableAutoScroll && scrollView.ScrollBar) {
            scrollView.ScrollBar.vertical.position = 1;
        }

        const oldLength = listModel.count;
        const url = getServerUrl('chat');
        const data = JSON.stringify({
            "model": modelsComboboxCurrentValue,
            "keep_alive": "5m",
            "options": {
                "temperature": Number(Plasmoid.configuration.ollamaTemperature || 0.7)
            },
            "messages": promptArray
        });
        
    let xhr = new XMLHttpRequest();
    // Record current XHR so UI can abort it via "Stop generating"
    root.currentXhr = xhr;

        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        
        let lastProcessedLength = 0; // Track how much we've already processed
        
        xhr.onreadystatechange = function() {
            // Only process during loading states to avoid unnecessary calls
            if (xhr.readyState !== XMLHttpRequest.LOADING && xhr.readyState !== XMLHttpRequest.DONE) {
                return;
            }
            
            const responseText = xhr.responseText;
            if (responseText.length <= lastProcessedLength) {
                return; // No new data to process
            }
            
            // Only process the new part of the response
            const newText = responseText.substring(lastProcessedLength);
            const newObjects = newText.split('\n');
            
            // Update our tracking
            lastProcessedLength = responseText.length;
            
            let text = '';
            
            // Get existing text if we already have a response
            if (listModel.count > oldLength) {
                const lastValue = listModel.get(oldLength);
                text = lastValue.number;
            }

            newObjects.forEach((object, index) => {
                if (object.trim() === '') return; // Skip empty lines
                
                try {
                    const parsedObject = JSON.parse(object);
                    text = text + parsedObject?.message?.content;
                } catch (e) {
                    Utils.debugLog('warn', 'Failed to parse JSON object:', object, 'Error:', e.message);
                    return; // Skip malformed JSON
                }
            });

            // Batch UI updates to reduce frequency
            if (text.length > 0) {
                if (!disableAutoScroll && scrollView.ScrollBar) {
                    scrollView.ScrollBar.vertical.position = 1 - scrollView.ScrollBar.vertical.size;
                }

                if (listModel.count === oldLength) {
                    listModel.append({
                        "name": "Assistant",
                        "number": text
                    });
                } else {
                    const lastValue = listModel.get(oldLength);
                    lastValue.number = text;
                }
            }
        };

        xhr.onload = function() {
            // Safely read the assistant's final text if it was appended during streaming.
            var assistantText = "";
            try {
                if (listModel.count > oldLength) {
                    var lastValue = listModel.get(oldLength);
                    if (lastValue && typeof lastValue.number !== 'undefined' && lastValue.number !== null) {
                        assistantText = lastValue.number;
                    }
                }
            } catch (e) {
                // defensive: leave assistantText empty
            }

            isLoading = false;
            if (!assistantText || assistantText.length === 0) {
                Utils.debugLog('debug', 'xhr.onload: assistantText missing for request at oldLength=', oldLength, 'listModel.count=', listModel.count);
            } else {
                // Play completion sound when AI response is fully complete
                if (Plasmoid.configuration.completionSound) {
                    typingSound.play();
                }
            }
            promptArray.push({ "role": "assistant", "content": assistantText, "images": [] });
            // Clear currentXhr when complete
            try { root.currentXhr = null; } catch(e) {}
        };

        xhr.onabort = function() {
            // Aborted by user
            isLoading = false;
            try { root.currentXhr = null; } catch(e) {}
        };

        xhr.onerror = function() {
            isLoading = false;
            Utils.debugLog('error', 'Network error during chat request');
            try { root.currentXhr = null; } catch(e) {}
        };

        xhr.ontimeout = function() {
            isLoading = false;
            Utils.debugLog('warn', 'Chat request timeout');
            try { root.currentXhr = null; } catch(e) {}
        };

        xhr.timeout = 30000; // 30 seconds timeout
        xhr.send(data);
    }

    function deleteMessage(index) {
        // Remove from visual list model
        listModelController.remove(index);
        
        // Remove from prompt array (conversation history)
        if (index < promptArray.length) {
            promptArray.splice(index, 1);
        }
    }

    function getModels() {
        const url = getServerUrl('tags');
    Utils.debugLog('debug', "Fetching models from:", url);

        let xhr = new XMLHttpRequest();

        xhr.open('GET', url);
        xhr.setRequestHeader('Content-Type', 'application/json');

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    const objects = JSON.parse(xhr.responseText).models;
                    
                    const models = objects.map(object => object.model);

                    if (models.length) {
                        hasLocalModel = true;
                        // mark connection manager as connected when we successfully retrieved models
                        try { connMgr.status = "connected"; } catch (e) { }

                        // Try to restore the previously selected model, otherwise use first model
                        const savedModel = Plasmoid.configuration.selectedModel;
                        if (savedModel && models.includes(savedModel)) {
                            modelsComboboxCurrentValue = savedModel;
                        } else {
                            modelsComboboxCurrentValue = models[0];
                            // Save the default selection
                            Plasmoid.configuration.selectedModel = models[0];
                        }

                        modelsArray = models.map(model => ({ text: parseTextToComboBox(model), value: model }));
                        Utils.debugLog('info', "Successfully loaded", models.length, "models");
                    } else {
                        hasLocalModel = false;
                        try { connMgr.status = "disconnected"; } catch (e) { }
                        Utils.debugLog('info', "No models found on server");
                    }
                } else {
                    hasLocalModel = false;
                    try { connMgr.status = "disconnected"; } catch (e) { }
                    Utils.debugLog('error', 'Error fetching models:', xhr.status, xhr.statusText, 'from', url);
                }
            }
        };

        xhr.onerror = function() {
            hasLocalModel = false;
            try { connMgr.status = "disconnected"; } catch (e) { }
            Utils.debugLog('error', 'Network error when fetching models from:', url);
        };

        xhr.ontimeout = function() {
            hasLocalModel = false;
            try { connMgr.status = "disconnected"; } catch (e) { }
            Utils.debugLog('warn', 'Timeout when fetching models from:', url);
        };

        xhr.timeout = 10000; // 10 seconds timeout for model fetching
        xhr.send();
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Keep Open")
            icon.name: "window-pin"
            checkable: true
            checked: Plasmoid.configuration.pin
            onTriggered: Plasmoid.configuration.pin = checked
        },
        PlasmaCore.Action {
            text: i18n("Clear chat")
            icon.name: "edit-clear"
            onTriggered: {
                listModelController.clear();
                promptArray = [];
            }
        },
        PlasmaCore.Action {
            text: i18n("Disable auto scroll")
            icon.name: "transform-move-vertical"
            checkable: true
            checked: disableAutoScroll
            onTriggered: disableAutoScroll = !disableAutoScroll
        }
    ]

    compactRepresentation: CompactRepresentation {}

    Component.onCompleted: {
        // Ensure temperature is initialized from persisted settings if the plasmoid config doesn't provide it
        if (Plasmoid.configuration.ollamaTemperature === undefined || Plasmoid.configuration.ollamaTemperature === null) {
            Plasmoid.configuration.ollamaTemperature = appSettings.ollamaTemperature;
        } else {
            appSettings.ollamaTemperature = Number(Plasmoid.configuration.ollamaTemperature);
        }

        getModels();
    }

    fullRepresentation: ColumnLayout {
        Layout.preferredHeight: 400
        Layout.preferredWidth: 350
        Layout.fillWidth: true
        Layout.fillHeight: true

        PlasmaExtras.PlasmoidHeading {
            width: parent.width

            contentItem: RowLayout {
                visible: hasLocalModel
                Layout.fillWidth: true

                PlasmaComponents.Button {
                    id: pinButton
                    checkable: true
                    checked: Plasmoid.configuration.pin
                    onToggled: Plasmoid.configuration.pin = checked
                    icon.name: "window-pin"

                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: i18n("Keep Open")

                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }

                PlasmaComponents.ComboBox {
                    id: modelsCombobox
                    enabled: hasLocalModel && !isLoading
                    hoverEnabled: hasLocalModel && !isLoading

                    Layout.fillWidth: true

                    model: modelsArray.map(model => model.text)

                    onActivated: {
                        modelsComboboxCurrentValue = modelsArray.find(model => model.text === modelsCombobox.currentText).value;
                        // Save selected model to configuration
                        Plasmoid.configuration.selectedModel = modelsComboboxCurrentValue;
                        listModelController.clear();
                    }

                    // Update the current selection when models array changes
                    onModelChanged: {
                        if (modelsArray.length > 0) {
                            if (modelsComboboxCurrentValue) {
                                // Find and set the index of the saved/current model
                                const modelIndex = modelsArray.findIndex(model => model.value === modelsComboboxCurrentValue);
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

                    Component.onCompleted: getModels()
                }

                PlasmaComponents.Button {
                    icon.name: "edit-clear-symbolic"
                    text: i18n("Clear chat")
                    display: PlasmaComponents.AbstractButton.IconOnly
                    enabled: hasLocalModel && !isLoading
                    hoverEnabled: hasLocalModel && !isLoading

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
                    text: i18n("Configure")
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

                // Connection status indicator
                ConnectionManager {
                    id: connMgr
                    interval: 5000
                    timeoutMs: 2500
                    serverBase: Plasmoid.configuration.ollamaServerUrl || ''
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

                    PlasmaComponents.ToolTip.text: connMgr.connected ? i18n("Connected to Ollama") : (connMgr.status === "connecting" ? i18n("Connecting...") : i18n("Disconnected. Click to retry."))
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
                    text: hasLocalModel ? i18n("I am ready...") : i18n("No LLM models found.\n\nPlease check:\n1. Ollama server is running\n2. Server URL is correct in settings\n3. Models are installed on the server\n\nClick 'Refresh models list' to retry.")
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
                        implicitHeight: textMessage.implicitHeight + (cardButtonsLayout ? cardButtonsLayout.implicitHeight : 0) + 16
                        
                        TextEdit {
                            id: textMessage
                            
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8

                            readOnly: true
                            wrapMode: Text.WordWrap
                            text: number
                            color: name === "User" ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
                            selectByMouse: true
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
                                text: i18n("Copy")
                                display: PlasmaComponents.AbstractButton.IconOnly
                                
                                onClicked: {
                                    textMessage.selectAll();
                                    textMessage.copy();
                                    textMessage.deselect();
                                }

                                PlasmaComponents.ToolTip.text: text
                                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                                PlasmaComponents.ToolTip.visible: hovered
                            }

                            PlasmaComponents.Button {
                                icon.name: "edit-delete-symbolic"
                                text: i18n("Delete")
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
            visible: hasLocalModel

            TextArea {
                id: messageField

                Layout.fillWidth: true
                Layout.fillHeight: true

                enabled: hasLocalModel && !isLoading
                hoverEnabled: hasLocalModel && !isLoading
                placeholderText: i18n("Type here what you want to ask...")
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

                        if (isAtFirstLine && lastUserMessage && lastUserMessage.length > 0) {
                            // Repopulate the field and place caret at end
                            messageField.text = lastUserMessage;
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
                                    request(messageField, listModel, scrollView, messageField.text);
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
                    running: isLoading
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

                text: i18n("Send")
                hoverEnabled: hasLocalModel && !isLoading
                enabled: hasLocalModel && !isLoading
                visible: hasLocalModel

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
                visible: hasLocalModel
                enabled: hasLocalModel && isLoading && root.currentXhr !== null

                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Stop")

                onClicked: {
                    if (root.currentXhr) {
                        try { root.currentXhr.abort(); } catch (e) {}
                        root.currentXhr = null;
                    }
                    isLoading = false;
                }
            }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            
            text: i18n("Refresh models list")
            visible: !hasLocalModel
            
            onClicked: getModels()
        }
    }
}
