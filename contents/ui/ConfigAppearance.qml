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

import org.kde.plasma.core as PlasmaCore

KCM.SimpleKCM {
    property string cfg_icon: plasmoid.configuration.icon || ""
    property alias cfg_useFilledIcon: useFilledIcon.checked
    property alias cfg_useOutlinedIcon: useOutlinedIcon.checked
    property alias cfg_useFilledLightIcon: useFilledLightIcon.checked
    property alias cfg_useFilledDarkIcon: useFilledDarkIcon.checked
    property alias cfg_useOutlinedLightIcon: useOutlinedLightIcon.checked
    property alias cfg_useOutlinedDarkIcon: useOutlinedDarkIcon.checked
    property alias cfg_enterToSend: enterToSendCheckbox.checked
    property alias cfg_completionSound: completionSoundCheckbox.checked
    property alias cfg_debugLogs: debugLogsCheckbox.checked
    
    // Ignore server-related properties that get assigned to all config pages
    property string cfg_ollamaServerUrl: ""
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
    property bool cfg_enterToSendDefault: false
    property bool cfg_completionSoundDefault: false
    property string cfg_iconDefault: ""
    property bool cfg_pinDefault: false
    property string cfg_selectedModelDefault: ""

    Kirigami.FormLayout {

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

            // Use the KCM pattern: bind to cfg_debugLogs so the Apply button is enabled
            checked: cfg_debugLogs

            // When applied by the KCM framework, the top-level plasmoid configuration system will set
            // `cfg_debugLogs` on this component. We still need to persist the value into plasmoid.configuration
            // when the user applies the KCM changes; SimpleKCM will do that by reading the cfg_* properties.
        }
    }
}
