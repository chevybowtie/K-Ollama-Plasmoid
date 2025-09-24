/*
    SPDX-FileCopyrightText: 2025 Paul <paul.sturm@cotton-software.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_ollamaServerUrl: serverUrlField.text
    
    // Ignore appearance-related properties that get assigned to all config pages
    property bool cfg_useFilledIcon: false
    property bool cfg_useOutlinedIcon: false
    property bool cfg_useFilledLightIcon: false
    property bool cfg_useFilledDarkIcon: false
    property bool cfg_useOutlinedLightIcon: false
    property bool cfg_useOutlinedDarkIcon: false
    property string cfg_icon: ""
    property bool cfg_pin: false
    property string cfg_selectedModel: ""
    property bool cfg_enterToSend: false
    property bool cfg_completionSound: false
    
    // Ignore "Default" variants that the configuration system tries to assign
    property bool cfg_useFilledIconDefault: false
    property bool cfg_useOutlinedIconDefault: false
    property bool cfg_useFilledLightIconDefault: false
    property bool cfg_useFilledDarkIconDefault: false
    property bool cfg_useOutlinedLightIconDefault: false
    property bool cfg_useOutlinedDarkIconDefault: false
    property string cfg_ollamaServerUrlDefault: ""
    property bool cfg_enterToSendDefault: false
    property bool cfg_completionSoundDefault: false
    property string cfg_iconDefault: ""
    property bool cfg_pinDefault: false
    property string cfg_selectedModelDefault: ""
        // Ollama generation temperature (0.0 - 2.0)
        property real cfg_ollamaTemperature: 0.7
        property real cfg_ollamaTemperatureDefault: 0.7

    Kirigami.FormLayout {
        Component.onCompleted: {
            // If the KCM host didn't populate cfg_ollamaServerUrl, initialize it from the current plasmoid configuration
            if (!cfg_ollamaServerUrl || cfg_ollamaServerUrl.length === 0) {
                try {
                    cfg_ollamaServerUrl = plasmoid.configuration.ollamaServerUrl || '';
                } catch (e) {}
            }

            // Also initialize cfg_ollamaTemperature if not set
            if (typeof cfg_ollamaTemperature !== 'number' || isNaN(cfg_ollamaTemperature)) {
                try {
                    cfg_ollamaTemperature = (plasmoid.configuration.ollamaTemperature !== undefined && plasmoid.configuration.ollamaTemperature !== null) ? plasmoid.configuration.ollamaTemperature : cfg_ollamaTemperature;
                } catch (e) {}
            }
        }
        QQC2.TextField {
            id: serverUrlField
            
            Kirigami.FormData.label: i18nc("@label:textbox", "Ollama Server URL:")
            placeholderText: i18nc("@info:placeholder", "http://127.0.0.1:11434")
            
            // Bind to cfg_ollamaServerUrl (KCM pattern). Initialize from existing configuration on completed.
            text: cfg_ollamaServerUrl
            onTextChanged: cfg_ollamaServerUrl = text

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
                    value: (typeof cfg_ollamaTemperature === 'number') ? cfg_ollamaTemperature : (plasmoid.configuration.ollamaTemperature !== undefined && plasmoid.configuration.ollamaTemperature !== null ? plasmoid.configuration.ollamaTemperature : cfg_ollamaTemperature)
                    onValueChanged: {
                        cfg_ollamaTemperature = value
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
    }
}