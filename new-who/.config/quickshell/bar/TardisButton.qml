import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import "../"

MouseArea {
    id: root

    implicitWidth: 23
    implicitHeight: 40

    acceptedButtons: Qt.LeftButton

    Image {
        id: img
        anchors.fill: parent
        source: "/home/tudor/assets/tardis.png"
        smooth: false
        scale: root.containsMouse ? 0.8 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 70
            }
        }
    }
    MultiEffect {
        source: img
        anchors.fill: img
        blur: 1.0
        brightness: 0.3
        blurEnabled: true
    }

    onPressed: Globals.nextTardis()
}

