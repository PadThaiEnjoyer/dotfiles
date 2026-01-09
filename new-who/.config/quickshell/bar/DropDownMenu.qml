import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Item {
    id: menuRoot
    width: 30
    height: parent.height

    FolderListModel {
        id: cursorModel
        folder: "file://" + Quickshell.env("HOME") + "/.icons"
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
    }

    readonly property bool mouseInMenuSystem: cursorArea.containsMouse || (dropDownWindow.visible && menuContentArea.containsMouse)

    Label {
        text: "󰇀" 
        font.pixelSize: 22
        anchors.centerIn: parent
        color: mouseInMenuSystem ? "#00ffff" : "white"
    }

    MouseArea {
        id: cursorArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: dropDownWindow.visible = true
    }

    PopupWindow {
        id: dropDownWindow
        anchor.window: root
        anchor.item: menuRoot
        anchor.rect.x: -160 
        anchor.rect.y: 46 
        width: 190
        height: Math.min(400, cursorCol.implicitHeight + 20)
        visible: false

        Rectangle {
            anchors.fill: parent
            color: "#dd202020"
            border.color: "#33ffffff"
            border.width: 1

            MouseArea {
                id: menuContentArea
                anchors.fill: parent
                hoverEnabled: true

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 5
                    clip: true

                    ColumnLayout {
                        id: cursorCol
                        width: parent.width - 15
                        spacing: 2

                        Label {
                            text: " SELECT CURSOR"
                            font.family: "BigBlueTermPlusNerdFont"
                            font.pixelSize: 10
                            color: "#66ffffff"
                            Layout.leftMargin: 5
                            Layout.bottomMargin: 5
                        }

                        Repeater {
                            model: cursorModel
                            delegate: Button {
                                id: cursorBtn
                                Layout.fillWidth: true
                                flat: true
                                hoverEnabled: true
                                
                                contentItem: Label {
                                    text: fileName
                                    color: cursorBtn.hovered ? "#00ffff" : "white"
                                    font.family: "BigBlueTermPlusNerdFont"
                                    elide: Text.ElideRight
                                    leftPadding: 10

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.leftMargin: -10
                                        height: parent.height
                                        width: 3
                                        color: "#00ffff"
                                        visible: cursorBtn.hovered
                                    }
                                }

                                onClicked: {
                                    console.log("Attempting to set cursor:", fileName);
                                    
                                    // THE FIX: Use 'running: true' instead of '.run()'
                                    processComponent.createObject(menuRoot, {
                                        "command": ["/home/tudor/.local/bin/set_cursor.sh", fileName, "24"],
                                        "running": true
                                    });
                                    
                                    dropDownWindow.visible = false;
                                }
                            }
                        }
                    }
                }
            }
        }

        Timer {
            interval: 150
            running: dropDownWindow.visible
            repeat: true
            onTriggered: {
                if (!menuRoot.mouseInMenuSystem) {
                    dropDownWindow.visible = false
                }
            }
        }
    }

    Component {
        id: processComponent
        Process {
            // Self-destruct when the script finishes to keep memory clean
            onExited: this.destroy()
        }
    }
}
