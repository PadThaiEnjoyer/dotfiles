import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import "../"

MouseArea {
    id: root
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    required property var bar

    readonly property var chargeState: UPower.displayDevice.state
    readonly property bool isCharging: chargeState == UPowerDeviceState.Charging
    readonly property bool isPluggedIn: isCharging || chargeState == UPowerDeviceState.PendingCharge
    readonly property real percentage: UPower.displayDevice.percentage
    readonly property bool isLow: percentage <= 0.20
    
    // Detects if the device is a laptop battery [cite: 23]
    readonly property bool isLaptop: UPower.displayDevice.type === UPowerDevice.Battery

    width: 32
    height: 32

    onClicked: {
        // 1. Logic to predict the next state in QML immediately
        let nextMode = "";
        if (Globals.powerMode === "performance") {
            nextMode = "balanced";
        } else if (Globals.powerMode === "balanced") {
            nextMode = "power-saver";
        } else {
            nextMode = "performance";
        }

        // 2. Update the UI variable right now
        Globals.powerMode = nextMode;

        // 3. Send the command to the system in the background
        Globals.sh("powerprofilesctl set " + nextMode + " && notify-send 'Power Mode' 'Switched to: " + nextMode + "' -i preferences-system-power");
    }

    // Scale animation matching Theme.qml
    scale: root.containsMouse ? 0.9 : 1
    Behavior on scale {
        NumberAnimation {
            duration: 70
        }
    }

    Image {
        id: mask
        source: "/home/tudor/assets/battery-mask.png"
        smooth: false
        anchors.fill: parent
        visible: false
    }

    Rectangle {
        id: progressBar
        anchors.fill: parent
        color: "black"
        visible: false

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.isLaptop ? root.percentage * parent.height : parent.height
            color: root.isLaptop ? (root.isLow ? "red" : "#EEA939") : "#EEA939"
        }
    }

    OpacityMask {
        id: pBarMask
        anchors.fill: progressBar
        source: progressBar
        maskSource: mask
    }

    MultiEffect {
        source: pBarMask
        anchors.fill: pBarMask
        brightness: root.isCharging ? 0.3 : 0
        blur: 1.0
        blurEnabled: root.isCharging
    }

    // Hover popup to display power mode text 
    LazyLoader {
        id: popupLoader
        property bool popupContainsMouse
        active: root.enabled && (root.containsMouse || popupContainsMouse)
        Behavior on active { NumberAnimation { duration: 100 } }

        PopupWindow {
            id: popup
            visible: true
            anchor.window: root.bar
            width: 120
            height: 28
            color: "#9B5B36"

            Component.onCompleted: updatePos()
            function updatePos() {
                const pos = root.mapToGlobal(root.width / 2 - popup.width / 2, root.height);
                popup.anchor.rect.x = pos.x;
                popup.anchor.rect.y = pos.y + 5;
            }

            Text {
                anchors.centerIn: parent
                text: (Globals.powerMode || "loading").toUpperCase()
                color: "white"
                font.pixelSize: 11
                font.bold: true
                font.family: "BigBlueTermPlusNerdFont"
            }

            MouseArea {
                id: popupMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                propagateComposedEvents: true
                onEntered: popupLoader.popupContainsMouse = true
                onExited: popupLoader.popupContainsMouse = false
            }
        }
    }
}
