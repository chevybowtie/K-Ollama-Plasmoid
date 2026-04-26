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

// Local imports
import "../js/utils.js" as Utils

ConfigDefaults {
    id: root

    property alias cfg_enterToSend: enterToSendCheckbox.checked
    property alias cfg_completionSound: completionSoundCheckbox.checked
    property bool cfg_debugLogs: false
    property bool cfg_enableMarkdown: false
    property int cfg_streamingTimeoutSecs: 0

    onCfg_debugLogsChanged: {
        try { Utils.debugLog('info', 'ConfigBehavior: cfg_debugLogs changed ->', root.cfg_debugLogs); } catch (e) {}
    }
    onCfg_enableMarkdownChanged: {
        try { Utils.debugLog('info', 'ConfigBehavior: cfg_enableMarkdown changed ->', root.cfg_enableMarkdown); } catch (e) {}
    }

    Kirigami.FormLayout {
        Component.onCompleted: {
            try { if (typeof cfg_enterToSend !== 'boolean') cfg_enterToSend = !!Plasmoid.configuration.enterToSend; } catch (e) {}
            try { if (typeof cfg_completionSound !== 'boolean') cfg_completionSound = !!Plasmoid.configuration.completionSound; } catch (e) {}
            try {
                if (Plasmoid && Plasmoid.configuration && Plasmoid.configuration.debugLogs !== undefined) {
                    root.cfg_debugLogs = !!Plasmoid.configuration.debugLogs;
                }
            } catch (e) {}
            try {
                if (Plasmoid && Plasmoid.configuration && Plasmoid.configuration.enableMarkdown !== undefined) {
                    root.cfg_enableMarkdown = !!Plasmoid.configuration.enableMarkdown;
                }
            } catch (e) {}
            try {
                if (Plasmoid && Plasmoid.configuration && Plasmoid.configuration.streamingTimeoutSecs !== undefined) {
                    root.cfg_streamingTimeoutSecs = Plasmoid.configuration.streamingTimeoutSecs;
                    timeoutSpinBox.value = root.cfg_streamingTimeoutSecs;
                }
            } catch (e) {}
        }

        QQC2.CheckBox {
            id: enterToSendCheckbox

            Kirigami.FormData.label: i18nc("@label:checkbox", "Input:")
            text: i18nc("@option:check", "Use Enter to send message")

            QQC2.ToolTip.text: i18nc("@info:tooltip", "When enabled: Enter sends message, Ctrl+Enter adds new line.\nWhen disabled: Enter adds new line, use 'send' button to submit.")
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: 1000
        }

        QQC2.CheckBox {
            id: completionSoundCheckbox

            Kirigami.FormData.label: i18nc("@label:checkbox", "Sound:")
            text: i18nc("@option:check", "Play sound when AI response is complete")

            QQC2.ToolTip.text: i18nc("@info:tooltip", "Play a slight beep sound effect after the response is completed.")
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: 1000
        }

        QQC2.CheckBox {
            id: enableMarkdownCheckbox

            Kirigami.FormData.label: i18nc("@label:checkbox", "Text rendering:")
            text: i18nc("@option:check", "Enable markdown rendering in AI responses")

            QQC2.ToolTip.text: i18nc("@info:tooltip", "Render markdown formatting (bold, italics, code blocks, etc.) in AI responses. When disabled, responses are shown as plain text.")
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: 1000

            onCheckedChanged: root.cfg_enableMarkdown = checked

            Component.onCompleted: {
                try {
                    if (typeof root.cfg_enableMarkdown === 'boolean') {
                        enableMarkdownCheckbox.checked = !!root.cfg_enableMarkdown;
                    }
                } catch (e) {}
            }

            Timer {
                interval: 100
                repeat: false
                running: true
                onTriggered: {
                    try {
                        if (typeof root.cfg_enableMarkdown === 'boolean') {
                            enableMarkdownCheckbox.checked = !!root.cfg_enableMarkdown;
                        }
                    } catch (e) {}
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18nc("@label:spinbox", "Response timeout:")
            spacing: Kirigami.Units.smallSpacing

            QQC2.SpinBox {
                id: timeoutSpinBox
                from: 0
                to: 600
                value: root.cfg_streamingTimeoutSecs
                onValueChanged: root.cfg_streamingTimeoutSecs = value
            }

            QQC2.Label {
                text: timeoutSpinBox.value === 0
                    ? i18nc("@info", "s  (no limit)")
                    : i18nc("@info", "s")
                opacity: 0.7
            }

            QQC2.ToolTip.text: i18nc("@info:tooltip", "Maximum time to wait for a streaming response. Set to 0 to disable the timeout. Increase this for slow models that generate long responses.")
            QQC2.ToolTip.visible: timeoutSpinBox.hovered
            QQC2.ToolTip.delay: 1000
        }

        QQC2.CheckBox {
            id: debugLogsCheckbox

            Kirigami.FormData.label: i18nc("@label:checkbox", "Debug logging:")
            text: i18nc("@option:check", "Enable debug console logs")

            QQC2.ToolTip.text: i18nc("@info:tooltip", "Show debug console.log messages for troubleshooting. This setting is persisted.")
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: 1000

            onCheckedChanged: root.cfg_debugLogs = checked

            Component.onCompleted: {
                try {
                    if (typeof root.cfg_debugLogs === 'boolean') {
                        debugLogsCheckbox.checked = !!root.cfg_debugLogs;
                    }
                } catch (e) {}
            }

            Timer {
                interval: 100
                repeat: false
                running: true
                onTriggered: {
                    try {
                        if (typeof root.cfg_debugLogs === 'boolean') {
                            debugLogsCheckbox.checked = !!root.cfg_debugLogs;
                        }
                    } catch (e) {}
                }
            }
        }
    }
}
