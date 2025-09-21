import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".."

TableView {
    id: table
    clip: true
    columnSpacing: Theme.spacingSmall
    rowSpacing: Theme.spacingSmall
    alternatingRowColors: true
    boundsBehavior: Flickable.StopAtBounds
    reuseItems: true

    property alias columns: table.columns

    delegate: Rectangle {
        implicitHeight: 36
        color: styleData.selected ? Theme.color("accent") : Theme.color("surface")
        border.color: Theme.color("border")
        radius: Theme.radiusSmall

        Text {
            anchors.fill: parent
            anchors.margins: Theme.spacingSmall
            text: styleData.value
            color: styleData.selected ? Theme.color("accentText") : Theme.color("text")
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    ScrollBar.vertical: ScrollBar { }
    ScrollBar.horizontal: ScrollBar { }
}
