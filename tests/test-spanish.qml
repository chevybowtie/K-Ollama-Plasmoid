import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami

// Test file to preview Spanish translations
ApplicationWindow {
    id: testWindow
    width: 400
    height: 300
    title: "Spanish Translation Test"
    visible: true
    
    // Force Spanish locale for testing
    Component.onCompleted: {
        // This simulates what would happen with Spanish locale
        console.log("Testing Spanish translations...")
        console.log("Available translations:", Qt.uiLanguages)
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        
        PlasmaComponents3.Label {
            text: "Testing Spanish Translations"
            font.bold: true
        }
        
        // Import your main UI to see translations
        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: "contents/ui/main.qml"
            
            // Override plasmoid object for testing
            property var plasmoid: QtObject {
                property var configuration: QtObject {
                    property string serverUrl: "http://localhost:11434"
                    property string model: "llama3.2"
                    property string systemPrompt: "You are a helpful assistant."
                    property bool showStreaming: true
                    property bool showWordCount: true
                    property bool debugLog: false
                }
                
                property var nativeInterface: QtObject {
                    function action(name) { return null }
                }
                
                function setAction(name, action) {}
                
                signal activated()
            }
        }
    }
}