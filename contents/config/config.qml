/*
 *  SPDX-FileCopyrightText: 2020 Sora Steenvoort <sora@dillbox.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import org.kde.plasma.configuration
import org.kde.kirigami as Kirigami

ConfigModel {
    ConfigCategory {
         name: i18nc("@title", "Server")
         icon: "computer"
         source: "ConfigServer.qml"
    }
    ConfigCategory {
         name: i18nc("@title", "Appearance")
         icon: "preferences-desktop-color"
         source: "ConfigAppearance.qml"
    }
    ConfigCategory {
         name: i18nc("@title", "Behavior")
         icon: "preferences-system"
         source: "ConfigBehavior.qml"
    }
}
