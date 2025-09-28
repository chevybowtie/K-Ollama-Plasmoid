/*
    SPDX-FileCopyrightText: 2025 Paul <paul.sturm@cotton-software.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.iconthemes as KIconThemes
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.kcmutils as KCM
import "../js/utils.js" as Utils

import org.kde.plasma.core as PlasmaCore

KCM.SimpleKCM {
    id: root
    property string cfg_icon: plasmoid.configuration.icon || ""
    property alias cfg_useFilledIcon: useFilledIcon.checked
    property alias cfg_useOutlinedIcon: useOutlinedIcon.checked
    property alias cfg_useFilledLightIcon: useFilledLightIcon.checked
    property alias cfg_useFilledDarkIcon: useFilledDarkIcon.checked
    property alias cfg_useOutlinedLightIcon: useOutlinedLightIcon.checked
    property alias cfg_useOutlinedDarkIcon: useOutlinedDarkIcon.checked
    property alias cfg_enterToSend: enterToSendCheckbox.checked
    property alias cfg_completionSound: completionSoundCheckbox.checked
    property bool cfg_debugLogs: false
    property bool cfg_debugLogsDefault: false
    onCfg_debugLogsChanged: {
        try { Utils.debugLog('info', 'ConfigAppearance: cfg_debugLogs changed ->', root.cfg_debugLogs); } catch (e) {}
    }
    
    // Ignore server-related properties that get assigned to all config pages
    property string cfg_ollamaServerUrl: ""
    property real cfg_ollamaTemperature: 0.7
    property bool cfg_pin: false
    property string cfg_selectedModel: ""
    
    // Ignore "Default" variants that the configuration system tries to assign
    property bool cfg_useFilledIconDefault: false
    property bool cfg_useOutlinedIconDefault: false
    property bool cfg_useFilledLightIconDefault: false
    property bool cfg_useFilledDarkIconDefault: false
    property bool cfg_useOutlinedLightIconDefault: false
    property bool cfg_useOutlinedDarkIconDefault: false
    property string cfg_ollamaServerUrlDefault: ""
    property real cfg_ollamaTemperatureDefault: 0.0
    property bool cfg_enterToSendDefault: false
    property bool cfg_completionSoundDefault: false
    property string cfg_iconDefault: ""
    property bool cfg_pinDefault: false
    property string cfg_selectedModelDefault: ""

    Kirigami.FormLayout {
        Component.onCompleted: {
            try {
                try { Utils.debugLog('info', 'ConfigAppearance: plasmoid.configuration snapshot ->', JSON.stringify(plasmoid.configuration)); } catch (e) {}
            } catch (e) {
                try { Utils.debugLog('warn', 'ConfigAppearance: failed to stringify plasmoid.configuration', e); } catch (ee) {}
            }
            // Initialize cfg_* properties from Plasmoid.configuration if KCM hasn't provided values
            try {
                if ((cfg_icon === undefined || cfg_icon === '') && plasmoid.configuration.icon) cfg_icon = plasmoid.configuration.icon;
            } catch (e) {}
            try { if (typeof cfg_useFilledIcon !== 'boolean') cfg_useFilledIcon = !!plasmoid.configuration.useFilledIcon; } catch (e) {}
            try { if (typeof cfg_useOutlinedIcon !== 'boolean') cfg_useOutlinedIcon = !!plasmoid.configuration.useOutlinedIcon; } catch (e) {}
            try { if (typeof cfg_useFilledLightIcon !== 'boolean') cfg_useFilledLightIcon = !!plasmoid.configuration.useFilledLightIcon; } catch (e) {}
            try { if (typeof cfg_useFilledDarkIcon !== 'boolean') cfg_useFilledDarkIcon = !!plasmoid.configuration.useFilledDarkIcon; } catch (e) {}
            try { if (typeof cfg_useOutlinedLightIcon !== 'boolean') cfg_useOutlinedLightIcon = !!plasmoid.configuration.useOutlinedLightIcon; } catch (e) {}
            try { if (typeof cfg_useOutlinedDarkIcon !== 'boolean') cfg_useOutlinedDarkIcon = !!plasmoid.configuration.useOutlinedDarkIcon; } catch (e) {}
            try { if (typeof cfg_enterToSend !== 'boolean') cfg_enterToSend = !!plasmoid.configuration.enterToSend; } catch (e) {}
            try { if (typeof cfg_completionSound !== 'boolean') cfg_completionSound = !!plasmoid.configuration.completionSound; } catch (e) {}
            // Initialize cfg_debugLogs from the stored plasmoid configuration if present.
            // Note: cfg_debugLogs is declared as a bool property so typeof checks are unreliable
            // for determining whether the host already provided a value. Check the stored
            // configuration explicitly instead.
            try {
                if (plasmoid && plasmoid.configuration && plasmoid.configuration.debugLogs !== undefined) {
                    root.cfg_debugLogs = !!plasmoid.configuration.debugLogs;
                }
            } catch (e) {
                try { Utils.debugLog('warn', "ConfigAppearance: failed to read plasmoid.configuration.debugLogs:", e); } catch (ee) {}
            }
            try { if (typeof cfg_ollamaTemperature !== 'number') cfg_ollamaTemperature = Number(plasmoid.configuration.ollamaTemperature || 0.7); } catch (e) {}
            try { if (typeof cfg_pin !== 'boolean') cfg_pin = !!plasmoid.configuration.pin; } catch (e) {}
            try { if (!cfg_selectedModel && plasmoid.configuration.selectedModel) cfg_selectedModel = plasmoid.configuration.selectedModel; } catch (e) {}
        }

        QQC2.ButtonGroup {
            id: iconGroup
        }

        QQC2.RadioButton {
            id: useFilledIcon

            Kirigami.FormData.label: i18nc("@title:group", "Icon:")
            text: i18nc("@option:radio", "Filled adaptive icon")

            QQC2.ButtonGroup.group: iconGroup
        }

        QQC2.RadioButton {
            id: useOutlinedIcon

            text: i18nc("@option:radio", "Outlined adaptive icon")

            QQC2.ButtonGroup.group: iconGroup
        }

        QQC2.RadioButton {
            id: useFilledDarkIcon

            text: i18nc("@option:radio", "Filled dark icon")

            QQC2.ButtonGroup.group: iconGroup
        }

        QQC2.RadioButton {
            id: useFilledLightIcon

            text: i18nc("@option:radio", "Filled light icon")

            QQC2.ButtonGroup.group: iconGroup
        }

        QQC2.RadioButton {
            id: useOutlinedDarkIcon

            text: i18nc("@option:radio", "Outlined dark icon")

            QQC2.ButtonGroup.group: iconGroup
        }

        QQC2.RadioButton {
            id: useOutlinedLightIcon

            text: i18nc("@option:radio", "Outlined light icon")

            QQC2.ButtonGroup.group: iconGroup
        }
        
        QQC2.CheckBox {
            id: enterToSendCheckbox
            
            Kirigami.FormData.label: i18nc("@label:checkbox", "Input behavior:")
            text: i18nc("@option:check", "Use Enter to send message")
            
            QQC2.ToolTip.text: i18nc("@info:tooltip", "When enabled: Enter sends message, Ctrl+Enter adds new line.\nWhen disabled: Enter adds new line, use `send` button to submit.")
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: 1000
        }
        
        QQC2.CheckBox {
            id: completionSoundCheckbox
            
            Kirigami.FormData.label: i18nc("@label:checkbox", "Sound effects:")
            text: i18nc("@option:check", "Play sound when AI response is complete")
            
            QQC2.ToolTip.text: i18nc("@info:tooltip", "Play a slight beep sound effect after the response is completed.")
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: 1000
        }

        QQC2.CheckBox {
            id: debugLogsCheckbox

            Kirigami.FormData.label: i18nc("@label:checkbox", "Debug logging:")
            text: i18nc("@option:check", "Enable debug console logs")

            QQC2.ToolTip.text: i18nc("@info:tooltip", "Show debug console.log messages for troubleshooting. This setting is persisted.")
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: 1000

            // Write user changes back into cfg_debugLogs so KCM detects the change
            onCheckedChanged: {
                root.cfg_debugLogs = checked;
            }

            Component.onCompleted: {
                try {
                        if (typeof root.cfg_debugLogs === 'boolean') {
                            // Explicitly reference the checkbox id to avoid accidental global property writes
                            try {
                                if (typeof debugLogsCheckbox !== 'undefined' && debugLogsCheckbox !== null) {
                                    debugLogsCheckbox.checked = !!root.cfg_debugLogs;
                                }
                            } catch (e) {}
                            try { Utils.debugLog('info', 'ConfigAppearance: debugLogsCheckbox initialized checked ->', debugLogsCheckbox && debugLogsCheckbox.checked); } catch (e) {}
                            try { Utils.debugLog('debug', 'ConfigAppearance: plasmoid.configuration.debugLogs ->', plasmoid && plasmoid.configuration && plasmoid.configuration.debugLogs); } catch (e) {}
                        } else {
                            try { Utils.debugLog('debug', 'ConfigAppearance: debugLogsCheckbox initialized but cfg_debugLogs not boolean ->', root.cfg_debugLogs); } catch (e) {}
                        }
                } catch (e) {
                    try { Utils.debugLog('warn', 'ConfigAppearance: failed to initialize debugLogsCheckbox.checked in Component.onCompleted', e); } catch (ee) {}
                }
            }

            // Defensive re-sync after a short delay to avoid a visual flicker caused by
            // the configuration host populating properties after child controls are created.
            Timer {
                interval: 100
                repeat: false
                running: true
                onTriggered: {
                    try {
                        if (typeof root.cfg_debugLogs === 'boolean') {
                            try {
                                if (typeof debugLogsCheckbox !== 'undefined' && debugLogsCheckbox !== null) {
                                    debugLogsCheckbox.checked = !!root.cfg_debugLogs;
                                }
                            } catch (e) {}
                        }
                    } catch (e) {
                        try { Utils.debugLog('warn', 'ConfigAppearance: Timer re-sync failed', e); } catch (ee) {}
                    }
                }
            }

            // When applied by the KCM framework, the top-level plasmoid configuration system will set
            // `cfg_debugLogs` on this component. SimpleKCM will read cfg_* properties when Apply is clicked.
        }
    }
}
