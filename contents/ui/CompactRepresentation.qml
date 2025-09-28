import QtQuick
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
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