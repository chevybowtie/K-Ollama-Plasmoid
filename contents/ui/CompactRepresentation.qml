// Qt modules
import QtQuick
import QtQuick.Layouts

// KDE modules
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

// Local imports
import "../js/utils.js" as Utils

Loader {
    property var models;

    TapHandler {
        id: tapHandler
        property bool wasExpanded: false

        acceptedButtons: Qt.LeftButton

        onPressedChanged: if (pressed) {
            tapHandler.wasExpanded = root.expanded;
        }
        onTapped: root.expanded = !tapHandler.wasExpanded
    }

    Kirigami.Icon {
        anchors.fill: parent
        source: Qt.resolvedUrl(Utils.chooseIconPath(Plasmoid.configuration, Utils.getBackgroundColorContrastFromHex(PlasmaCore.Theme.backgroundColor)))
    }
}