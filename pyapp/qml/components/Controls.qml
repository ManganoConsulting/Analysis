import QtQuick 2.15
import QtQuick.Controls 2.15
import ".."

QtObject {
    id: controls

    property Component primaryButton: Component {
        Button {
            id: primary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            padding: Theme.spacingMedium
            background: Rectangle {
                radius: Theme.radiusMedium
                color: Theme.color("accent")
                border.color: Theme.color("border")
            }
            contentItem: Text {
                text: primary.text
                color: Theme.color("accentText")
                font: primary.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    property Component secondaryButton: Component {
        Button {
            id: secondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            padding: Theme.spacingMedium
            background: Rectangle {
                radius: Theme.radiusMedium
                color: Theme.color("surface")
                border.color: Theme.color("border")
            }
        }
    }

    property Component textField: Component {
        TextField {
            id: input
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBody
            padding: Theme.spacingSmall
            background: Rectangle {
                radius: Theme.radiusSmall
                border.width: 1
                border.color: Theme.color("border")
                color: Theme.color("surface")
            }
        }
    }
}
