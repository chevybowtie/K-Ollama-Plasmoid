/*
    SPDX-FileCopyrightText: 2025 Paul <paul.sturm@cotton-software.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

// Qt modules
import QtQuick

// KDE modules
import org.kde.kcmutils as KCM

/**
 * Base configuration page component with all shared property definitions
 * 
 * KDE's configuration system automatically tries to assign every property from main.xml
 * to all KCM pages, including both the main property and its "Default" variant.
 * This base component defines all these properties to prevent assignment errors.
 * 
 * Usage: Extend this component instead of KCM.SimpleKCM directly
 */
KCM.SimpleKCM {
    id: configBase

    // === ICON CONFIGURATION PROPERTIES ===
    property bool cfg_useFilledIcon: false
    property bool cfg_useOutlinedIcon: false
    property bool cfg_useFilledLightIcon: false
    property bool cfg_useFilledDarkIcon: false
    property bool cfg_useOutlinedLightIcon: false
    property bool cfg_useOutlinedDarkIcon: false
    property string cfg_icon: ""

    // === SERVER CONFIGURATION PROPERTIES ===
    property string cfg_ollamaServerUrl: ""
    property real cfg_ollamaTemperature: 0.7

    // === BEHAVIOR CONFIGURATION PROPERTIES ===
    property bool cfg_pin: false
    property string cfg_selectedModel: ""
    property bool cfg_enterToSend: false
    property bool cfg_completionSound: false
    property bool cfg_debugLogs: false
    property bool cfg_enableMarkdown: false

    // === "DEFAULT" VARIANTS ===
    // KDE automatically tries to assign these for every configuration property
    // These prevent property assignment errors during KCM initialization
    property bool cfg_useFilledIconDefault: false
    property bool cfg_useOutlinedIconDefault: false
    property bool cfg_useFilledLightIconDefault: false
    property bool cfg_useFilledDarkIconDefault: false
    property bool cfg_useOutlinedLightIconDefault: false
    property bool cfg_useOutlinedDarkIconDefault: false
    property string cfg_iconDefault: ""
    property string cfg_ollamaServerUrlDefault: ""
    property real cfg_ollamaTemperatureDefault: 0.7
    property bool cfg_pinDefault: false
    property string cfg_selectedModelDefault: ""
    property bool cfg_enterToSendDefault: false
    property bool cfg_completionSoundDefault: false
    property bool cfg_debugLogsDefault: false
    property bool cfg_enableMarkdownDefault: false

    // === SYSTEM PROPERTIES ===
    // Special system properties that KDE tries to assign
    property var cfg_toJSON: undefined
}