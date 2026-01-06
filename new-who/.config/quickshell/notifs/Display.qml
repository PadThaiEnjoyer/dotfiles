// This is how the notification looks

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

Item {
    id: root

    required property Notification notif

    implicitWidth: 240
    implicitHeight: layout.height

    ColumnLayout {
        id: layout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: 0

        Image {
            id: eggWisk
            Layout.fillWidth: true
            Layout.preferredHeight: width * (sourceSize.height / sourceSize.width)
            source: "/home/tudor/assets/eggwisk.png"
            smooth: false
        }

        Rectangle {
            id: bannerRect

            color: "#3B253F"
            Layout.fillWidth: true
            implicitHeight: textColumn.height
            Layout.leftMargin: (width / eggwisk.sourceSize.width) * 2 + 3
            Layout.rightMargin: (width / eggwisk.sourceSize.width) * 2 + 3

            ColumnLayout {
                id: textColumn

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    Layout.maximumWidth: bannerRect.width
                    text: root.notif.summary + (root.notif.body ? "\n=======" : "")
                    font.family: "BigBlueTermPlusNerdFont"
                    wrapMode: Text.Wrap
                    font.pointSize: 18
                    font.bold: true
                    color: "#9292B6"
                }

                Text {
                    Layout.maximumWidth: bannerRect.width
                    text: root.notif.body
                    font.family: "BigBlueTermPlusNerdFont"
                    wrapMode: Text.Wrap
                    font.pointSize: 14
                    font.bold: false
                    color: "#9292B6"
                }
            }
        }
    }
}
