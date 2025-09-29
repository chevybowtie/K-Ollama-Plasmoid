/*
    SPDX-FileCopyrightText: 2025 Paul <paul.sturm@cotton-software.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

// Qt modules
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

// KDE modules
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

ConfigDefaults {
    id: root
    
    // This page's specific configuration bindings
    property alias cfg_ollamaServerUrl: serverUrlField.text
    // Temperature property inherited from base, just use default value of 0.7

    Kirigami.FormLayout {
        Component.onCompleted: {
            // If the KCM host didn't populate cfg_ollamaServerUrl, initialize it from the current plasmoid configuration
            if (!root.cfg_ollamaServerUrl || root.cfg_ollamaServerUrl.length === 0) {
                try {
                    root.cfg_ollamaServerUrl = Plasmoid.configuration.ollamaServerUrl || '';
                } catch (e) {}
            }

            // Also initialize cfg_ollamaTemperature if not set
            if (typeof root.cfg_ollamaTemperature !== 'number' || isNaN(root.cfg_ollamaTemperature)) {
                try {
                    root.cfg_ollamaTemperature = (Plasmoid.configuration.ollamaTemperature !== undefined && Plasmoid.configuration.ollamaTemperature !== null) ? Plasmoid.configuration.ollamaTemperature : root.cfg_ollamaTemperature;
                } catch (e) {}
            }
        }
        QQC2.TextField {
            id: serverUrlField
            
            Kirigami.FormData.label: i18nc("@label:textbox", "Ollama Server URL:")
            placeholderText: i18nc("@info:placeholder", "http://127.0.0.1:11434")
            
            // Bind to cfg_ollamaServerUrl (KCM pattern). Initialize from existing configuration on completed.
            text: root.cfg_ollamaServerUrl
            onTextChanged: root.cfg_ollamaServerUrl = text

            QQC2.ToolTip.text: i18nc("@info:tooltip", "URL of the Ollama server. Use localhost (127.0.0.1) for local server or LAN IP for remote server")
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: 1000
        }
        
        QQC2.Label {
            text: i18nc("@info", "Examples:\n• Local server: http://127.0.0.1:11434\n• Remote server: http://192.168.1.100:11434")
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.7
            Layout.maximumWidth: serverUrlField.width
            wrapMode: Text.WordWrap
        }
        
            // Temperature control
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    text: i18nc("@label", "Temperature")
                    Layout.alignment: Qt.AlignVCenter
                }

                QQC2.Slider {
                    id: tempSlider
                    from: 0.0
                    to: 2.0
                    stepSize: 0.01
                    // initialize from cfg_ollamaTemperature (which the KCM host may populate). If absent, fall back to existing plasmoid configuration.
                    value: (typeof root.cfg_ollamaTemperature === 'number') ? root.cfg_ollamaTemperature : (Plasmoid.configuration.ollamaTemperature !== undefined && Plasmoid.configuration.ollamaTemperature !== null ? Plasmoid.configuration.ollamaTemperature : root.cfg_ollamaTemperature)
                    onValueChanged: {
                        root.cfg_ollamaTemperature = value
                    }
                    Layout.fillWidth: true
                }

                QQC2.Label {
                    text: (typeof tempSlider.value === 'number') ? tempSlider.value.toFixed(2) : tempSlider.value
                    Layout.alignment: Qt.AlignVCenter
                }

                QQC2.ToolTip.text: i18nc("@info", "Lower = more deterministic, higher = more creative (0.0–2.0)")
                QQC2.ToolTip.visible: tempSlider.hovered
            }

            // System prompt controls (Server tab)
            QQC2.CheckBox {
                id: enableSystemPrompt
                Kirigami.FormData.label: i18nc("@label:checkbox", "System prompt")
                text: i18nc("@option", "Enable system prompt")
                checked: root.cfg_systemPromptEnabled
                onCheckedChanged: root.cfg_systemPromptEnabled = checked

                QQC2.ToolTip.text: i18nc("@info", "Prepend a system message to every API request. Do not include secrets.")
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.delay: 1000
            }

            QQC2.TextArea {
                id: systemPromptArea
                visible: enableSystemPrompt.checked
                wrapMode: QQC2.TextArea.Wrap
                placeholderText: i18nc("@info:placeholder", "You are a helpful assistant that answers questions in plain English.")
                text: root.cfg_systemPrompt
                onTextChanged: {
                    // TextArea in some Qt/Controls versions doesn't have maximumLength.
                    // Enforce the 2048-char limit here to stay compatible across environments.
                    if (text && text.length > 2048) {
                        text = text.slice(0, 2048);
                    }
                    root.cfg_systemPrompt = text;
                }
                Layout.fillWidth: true
                Layout.preferredHeight: 100
            }

            RowLayout {
                visible: enableSystemPrompt.checked
                spacing: Kirigami.Units.smallSpacing
                Layout.fillWidth: true

                Text {
                    // Qt.formatNumber is not available in all Qt versions/environments; use a safe JS conversion.
                    text: String(systemPromptArea.text.length) + "/2048"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    color: "gray"
                }

                Text {
                    visible: systemPromptArea.text.length > 1024
                    text: i18nc("@info", "Long prompts may increase request size.")
                    color: "orange"
                }
            }
    }
}