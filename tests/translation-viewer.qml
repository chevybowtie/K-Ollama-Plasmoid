import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.i18n 1.0

// Simple translation test viewer
ApplicationWindow {
    id: translationTest
    width: 500
    height: 400
    title: "K-Ollama Spanish Translation Viewer"
    visible: true
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 10
        
        ColumnLayout {
            spacing: 10
            
            Label {
                text: "Spanish Translation Test"
                font.bold: true
                font.pointSize: 16
            }
            
            // Test each translation string
            Grid {
                columns: 2
                columnSpacing: 20
                rowSpacing: 5
                
                Label { text: "English:"; font.bold: true }
                Label { text: "Spanish:"; font.bold: true }
                
                Label { text: "Server URL:" }
                Label { text: i18nc("@label:textbox", "Server URL:") }
                
                Label { text: "Model:" }
                Label { text: i18nc("@label:textbox", "Model:") }
                
                Label { text: "System Prompt:" }
                Label { text: i18nc("@label:textbox", "System Prompt:") }
                
                Label { text: "Apply" }
                Label { text: i18nc("@action:button", "Apply") }
                
                Label { text: "Send" }
                Label { text: i18nc("@action:button", "Send") }
                
                Label { text: "Clear Chat" }
                Label { text: i18nc("@action:button", "Clear Chat") }
                
                Label { text: "Stop Generation" }
                Label { text: i18nc("@action:button", "Stop Generation") }
                
                Label { text: "Connection Status:" }
                Label { text: i18nc("@label", "Connection Status:") }
                
                Label { text: "Connected" }
                Label { text: i18nc("@info:status", "Connected") }
                
                Label { text: "Connecting..." }
                Label { text: i18nc("@info:status", "Connecting...") }
                
                Label { text: "Connection failed" }
                Label { text: i18nc("@info:status", "Connection failed") }
                
                Label { text: "Error connecting to server" }
                Label { text: i18nc("@info", "Error connecting to server") }
            }
        }
    }
}