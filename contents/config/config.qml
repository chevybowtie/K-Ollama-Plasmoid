/*
 *  SPDX-FileCopyrightText: 2020 Sora Steenvoort <sora@dillbox.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: i18nc("@title", "Appearance & Behavior")
         icon: "preferences-desktop-color"
         source: "ConfigAppearance.qml"
    }
    ConfigCategory {
         name: i18nc("@title", "Server")
         icon: "network-server"
         source: "ConfigServer.qml"
    }
}
