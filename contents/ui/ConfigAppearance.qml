/*
    SPDX-FileCopyrightText: 2025 Paul <paul.sturm@cotton-software.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

// Qt modules
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

// KDE modules
import org.kde.iconthemes as KIconThemes
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.plasmoid

// Local imports
import "../js/utils.js" as Utils

ConfigDefaults {
    id: root

    property string cfg_icon: Plasmoid.configuration.icon || ""
    property alias cfg_useFilledIcon: useFilledIcon.checked
    property alias cfg_useOutlinedIcon: useOutlinedIcon.checked
    property alias cfg_useFilledLightIcon: useFilledLightIcon.checked
    property alias cfg_useFilledDarkIcon: useFilledDarkIcon.checked
    property alias cfg_useOutlinedLightIcon: useOutlinedLightIcon.checked
    property alias cfg_useOutlinedDarkIcon: useOutlinedDarkIcon.checked

    Kirigami.FormLayout {
        Component.onCompleted: {
            try {
                if ((cfg_icon === undefined || cfg_icon === '') && Plasmoid.configuration.icon) cfg_icon = Plasmoid.configuration.icon;
            } catch (e) {}
            try { if (typeof cfg_useFilledIcon !== 'boolean') cfg_useFilledIcon = !!Plasmoid.configuration.useFilledIcon; } catch (e) {}
            try { if (typeof cfg_useOutlinedIcon !== 'boolean') cfg_useOutlinedIcon = !!Plasmoid.configuration.useOutlinedIcon; } catch (e) {}
            try { if (typeof cfg_useFilledLightIcon !== 'boolean') cfg_useFilledLightIcon = !!Plasmoid.configuration.useFilledLightIcon; } catch (e) {}
            try { if (typeof cfg_useFilledDarkIcon !== 'boolean') cfg_useFilledDarkIcon = !!Plasmoid.configuration.useFilledDarkIcon; } catch (e) {}
            try { if (typeof cfg_useOutlinedLightIcon !== 'boolean') cfg_useOutlinedLightIcon = !!Plasmoid.configuration.useOutlinedLightIcon; } catch (e) {}
            try { if (typeof cfg_useOutlinedDarkIcon !== 'boolean') cfg_useOutlinedDarkIcon = !!Plasmoid.configuration.useOutlinedDarkIcon; } catch (e) {}
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
    }
}
