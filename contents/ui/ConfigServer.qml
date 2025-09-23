import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami
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
    
    // Ignore "Default" variants that the configuration system tries to assign
    property bool cfg_useFilledIconDefault: false
    property bool cfg_useOutlinedIconDefault: false
    property bool cfg_useFilledLightIconDefault: false
    property bool cfg_useFilledDarkIconDefault: false
    property bool cfg_useOutlinedLightIconDefault: false
    property bool cfg_useOutlinedDarkIconDefault: false
    property string cfg_ollamaServerUrlDefault: ""
    property bool cfg_enterToSendDefault: false
    property string cfg_iconDefault: ""
    property bool cfg_pinDefault: false
    property string cfg_selectedModelDefault: ""

    Kirigami.FormLayout {
        QQC2.TextField {
            id: serverUrlField
            
            Kirigami.FormData.label: i18nc("@label:textbox", "Ollama Server URL:")
            placeholderText: i18nc("@info:placeholder", "http://127.0.0.1:11434")
            
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
    }
}