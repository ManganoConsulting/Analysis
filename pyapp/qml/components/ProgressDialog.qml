import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".."

Popup {
    id: popup
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose
    padding: Theme.spacingLarge
    background: Rectangle {
        color: Theme.color("surface")
        radius: Theme.radiusLarge
        border.color: Theme.color("border")
    }

    property alias text: message.text
    property real progress: 0.0
    signal cancelRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingMedium

        Label {
            id: message
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            color: Theme.color("text")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        ProgressBar {
            value: popup.progress
            from: 0.0
            to: 1.0
            Layout.fillWidth: true
        }

        Button {
            Layout.alignment: Qt.AlignRight
            text: qsTr("Cancel")
            onClicked: popup.cancelRequested()
        }
    }
}
