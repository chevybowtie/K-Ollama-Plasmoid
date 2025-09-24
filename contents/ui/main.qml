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
import Qt.labs.settings 1.0

PlasmoidItem {
    id: root

    // Control popup behavior based on pin state
    hideOnWindowDeactivate: !Plasmoid.configuration.pin

    property string parentMessageId: ''
    property string modelsComboboxCurrentValue: '';    
    property var listModelController;
    property var promptArray: [];
    property var modelsArray: [];
    property bool isLoading: false
    property bool hasLocalModel: false;
    property bool disableAutoScroll: false;

    // Typing sound effect for AI responses
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
            console.log("Server URL changed to:", Plasmoid.configuration.ollamaServerUrl);
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

    function getServerUrl(endpoint) {
        const baseUrl = Plasmoid.configuration.ollamaServerUrl || 'http://127.0.0.1:11434';
        return baseUrl + '/api/' + endpoint;
    }

    function parseTextToComboBox(text) {
        return text
            .replace(/-/g, ' ')
            .replace(/:(.+)/, ' ($1)')
            .split(' ')
            .map(word => {
                if (word.startsWith('(')) {
                    return word.charAt(0) + word.charAt(1).toUpperCase() + word.slice(2);
                }
                return word.charAt(0).toUpperCase() + word.slice(1);
            })
            .join(' ');
    }

    function request(messageField, listModel, scrollView, prompt) {
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
                    console.warn('Failed to parse JSON object:', object, 'Error:', e.message);
                    return; // Skip malformed JSON
                }
            });

            // Batch UI updates to reduce frequency
            if (text.length > 0) {
                // Play typing sound if enabled and we have new content
                if (Plasmoid.configuration.completionSound && newObjects.some(obj => obj.trim() !== '')) {
                    typingSound.play();
                }
                
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
            const lastValue = listModel.get(oldLength);

            isLoading = false;

            promptArray.push({ "role": "assistant", "content": lastValue.number, "images": [] });
        };

        xhr.send(data);
    }

    function getModels() {
        const url = getServerUrl('tags');
        console.log("Fetching models from:", url);

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
                        console.log("Successfully loaded", models.length, "models");
                    } else {
                        hasLocalModel = false;
                        console.log("No models found on server");
                    }
                } else {
                    hasLocalModel = false;
                    console.error('Error fetching models:', xhr.status, xhr.statusText, 'from', url);
                }
            }
        };

        xhr.onerror = function() {
            hasLocalModel = false;
            console.error('Network error when fetching models from:', url);
        };

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
                    PlasmaComponents.ToolTip.visible: (hoverArea && hoverArea.hovered) ? true : false
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
                        implicitHeight: textMessage.implicitHeight + 16
                        
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

                        PlasmaComponents.Button {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.margins: 4
                            z: 10 // Ensure button stays on top

                            icon.name: "edit-copy-symbolic"
                            text: i18n("Copy")
                            display: PlasmaComponents.AbstractButton.IconOnly
                            visible: cardHoverHandler.hovered
                            
                            onClicked: {
                                textMessage.selectAll();
                                textMessage.copy();
                                textMessage.deselect();
                            }

                            PlasmaComponents.ToolTip.text: text
                            PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                            PlasmaComponents.ToolTip.visible: hovered
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

                Keys.onReturnPressed: function(event) {
                    if (Plasmoid.configuration.enterToSend) {
                        // New behavior: Enter sends, Ctrl+Enter adds new line
                        if (event.modifiers & Qt.ControlModifier) {
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
                        if (event.modifiers & Qt.ControlModifier) {
                            // Ctrl+Enter: send message
                            if (messageField.text.trim().length > 0) {
                                request(messageField, listModel, scrollView, messageField.text);
                                event.accepted = true;
                            } else {
                                event.accepted = false;
                            }
                        } else {
                            // Enter: add new line
                            event.accepted = false;
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

        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            
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

        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            
            text: i18n("Refresh models list")
            visible: !hasLocalModel
            
            onClicked: getModels()
        }
    }
}
