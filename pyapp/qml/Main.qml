import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.15
import Qt.labs.platform 1.1 as Platform
import "."
import "components"
import Analysis 1.0

ApplicationWindow {
    id: window
    width: 1280
    height: 820
    visible: true
    title: qsTr("Stability Control Analysis")

    property string currentModelPath: ""
    property var lastResult: ({})
    property string statusMessage: qsTr("Ready")
    property real progressValue: 0.0

    UiController {
        id: controller
        onThemeChanged: Theme.palette = controller.theme
        onMessageEmitted: statusMessage = message
        onErrorEmitted: {
            statusMessage = message
            notificationDialog.text = message
            notificationDialog.open()
        }
        onSimulationDataReady: result => {
            lastResult = result
            statusMessage = qsTr("Simulation completed")
        }
    }

    Component.onCompleted: Theme.palette = controller.theme

    background: Rectangle {
        color: Theme.color("window")
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Open Model…")
                onTriggered: openDialog.open()
            }
            MenuItem {
                text: qsTr("Run Simulation")
                onTriggered: {
                    var value = Number(stopTimeField.text)
                    if (!value || value <= 0)
                        value = 10
                    controller.runSimulation(currentModelPath, value)
                }
                enabled: currentModelPath.length > 0
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Quit")
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: qsTr("View")
            MenuItem {
                text: controller.theme === "light" ? qsTr("Use Dark Theme") : qsTr("Use Light Theme")
                onTriggered: controller.toggleTheme()
            }
        }
        Menu {
            title: qsTr("Help")
            MenuItem {
                text: qsTr("Open Project Folder")
                onTriggered: controller.openProjectFolder()
            }
        }
    }

    header: ToolBar {
        background: Rectangle { color: Theme.color("surface") }
        RowLayout {
            anchors.fill: parent
            spacing: Theme.spacingMedium
            padding: Theme.spacingMedium

            ToolButton {
                text: qsTr("Open…")
                icon.name: "document-open"
                onClicked: openDialog.open()
            }
            ToolButton {
                text: qsTr("Run")
                icon.name: "media-playback-start"
                enabled: currentModelPath.length > 0
                onClicked: {
                    var value = Number(stopTimeField.text)
                    if (!value || value <= 0)
                        value = 10
                    controller.runSimulation(currentModelPath, value)
                }
            }
            ToolButton {
                text: qsTr("Cancel")
                icon.name: "process-stop"
                enabled: controller.busy
                onClicked: controller.cancelSimulation()
            }
            ToolSeparator { }
            Label {
                text: currentModelPath.length > 0 ? currentModelPath : qsTr("No model selected")
                elide: Text.ElideRight
                Layout.fillWidth: true
                color: Theme.color("text")
            }
            ToolSeparator { }
            Label {
                text: qsTr("Stop Time")
                color: Theme.color("text")
            }
            TextField {
                id: stopTimeField
                text: "10"
                validator: DoubleValidator { bottom: 0.1 }
                implicitWidth: 80
            }
            ToolButton {
                text: controller.theme === "light" ? qsTr("Dark") : qsTr("Light")
                onClicked: controller.toggleTheme()
            }
        }
    }

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: Theme.spacingMedium
            padding: Theme.spacingSmall

            Label {
                text: statusMessage
                Layout.fillWidth: true
                color: Theme.color("text")
            }
            Label {
                text: controller.busy ? qsTr("Running…") : qsTr("Idle")
                color: controller.busy ? Theme.color("accent") : Theme.color("text")
            }
        }
    }

    Platform.FileDialog {
        id: openDialog
        title: qsTr("Select MATLAB Model")
        nameFilters: [qsTr("MATLAB Models (*.slx *.mdl *.m)")]
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        onAccepted: {
            var path = file
            if (path && path.toString) {
                path = path.toString()
            }
            currentModelPath = path || ""
            if (currentModelPath.startsWith("file://")) {
                currentModelPath = currentModelPath.slice(7)
            }
            controller.openModel(currentModelPath)
        }
    }

    Dialog {
        id: notificationDialog
        modal: true
        standardButtons: Dialog.Ok
        title: qsTr("Notification")
        text: ""
    }

    Connections {
        target: controller
        function onProgressChanged(value) {
            progressValue = value
        }
        function onBusyChanged() {
            if (!controller.busy) {
                progressValue = 0
            }
        }
    }

    ProgressDialog {
        id: progressDialog
        parent: window.contentItem
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        progress: Math.min(progressValue, 1.0)
        visible: controller.busy
        text: statusMessage
        onCancelRequested: controller.cancelSimulation()
    }

    RowLayout {
        anchors.fill: parent.contentItem
        anchors.margins: Theme.spacingLarge
        spacing: Theme.spacingLarge

        Frame {
            Layout.preferredWidth: 320
            Layout.fillHeight: true
            background: Rectangle {
                radius: Theme.radiusLarge
                color: Theme.color("surface")
                border.color: Theme.color("border")
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingMedium
                spacing: Theme.spacingMedium

                Label {
                    text: qsTr("Analysis Tasks")
                    font.pixelSize: Theme.fontSizeTitle
                    color: Theme.color("text")
                    Layout.fillWidth: true
                }

                ListView {
                    id: taskList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: controller.stabilityModel
                    delegate: ItemDelegate {
                        width: taskList.width
                        padding: Theme.spacingSmall
                        highlighted: model.selected
                        onClicked: model.selected = !model.selected
                        background: Rectangle {
                            color: highlighted ? Theme.color("surfaceAlt") : Theme.color("surface")
                            radius: Theme.radiusSmall
                            border.color: Theme.color("border")
                        }

                        contentItem: ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingSmall

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacingSmall

                                CheckBox {
                                    checked: model.selected
                                    onToggled: model.selected = checked
                                }

                                Text {
                                    text: model.name
                                    color: Theme.color("text")
                                    font.pixelSize: Theme.fontSizeBody
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: model.description
                                wrapMode: Text.WordWrap
                                color: Theme.color("text")
                                opacity: 0.7
                                font.pixelSize: Theme.fontSizeSmall
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            background: Rectangle {
                radius: Theme.radiusLarge
                color: Theme.color("surface")
                border.color: Theme.color("border")
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingMedium
                spacing: Theme.spacingMedium

                TabView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Tab {
                        title: qsTr("Manual Analysis")
                        Flickable {
                            contentWidth: parent.width
                            contentHeight: manualColumn.implicitHeight
                            anchors.fill: parent
                            clip: true
                            ColumnLayout {
                                id: manualColumn
                                width: parent.width
                                spacing: Theme.spacingMedium

                                GroupBox {
                                    title: qsTr("Simulation Overview")
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.margins: Theme.spacingMedium
                                        anchors.fill: parent
                                        spacing: Theme.spacingSmall
                                        Label {
                                            text: qsTr("Selected model:") + " " + (currentModelPath || qsTr("None"))
                                            wrapMode: Text.WordWrap
                                        }
                                        Label {
                                            text: qsTr("Available tasks: %1").arg(controller.taskCount())
                                        }
                                        Label {
                                            text: qsTr("Stop time: %1 s").arg(stopTimeField.text)
                                        }
                                    }
                                }

                                GroupBox {
                                    title: qsTr("Simulation Result")
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    TextArea {
                                        readOnly: true
                                        text: JSON.stringify(lastResult, null, 2)
                                        wrapMode: TextEdit.WrapAnywhere
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                }
                            }
                        }
                    }

                    Tab {
                        title: qsTr("Constants")
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingMedium

                            Label {
                                text: qsTr("Constants placeholder - bind to MATLAB parameters.")
                                wrapMode: Text.WordWrap
                            }
                            DataTable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: controller.stabilityModel
                                columns: [
                                    TableViewColumn { role: "name"; title: qsTr("Task") ; width: 150 },
                                    TableViewColumn { role: "description"; title: qsTr("Description"); width: 320 },
                                    TableViewColumn { role: "status"; title: qsTr("Status"); width: 120 }
                                ]
                            }
                        }
                    }

                    Tab {
                        title: qsTr("Settings")
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingMedium

                            Switch {
                                text: qsTr("Append data to existing results")
                                checked: true
                            }
                            Switch {
                                text: qsTr("Use mock MATLAB engine (set ANALYSIS_USE_MOCK=1)")
                                checked: false
                                enabled: false
                            }
                            Label {
                                text: qsTr("Additional controls can be added here.")
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
    }
}
