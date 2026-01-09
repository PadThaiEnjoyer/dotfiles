pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: wifiRoot
    implicitWidth: wifiLayout.implicitWidth
    implicitHeight: 26

    property string strength: "0"

    // Process for the popup menu
    Process {
        id: wifiProc
        command: ["networkmanager_dmenu"]
    }

    // Process for the signal strength
    Process {
        id: getSignal
        command: ["bash", "-c", "nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d: -f2"]
        
        stdout: SplitParser {
            onRead: (data) => {
                let s = data.trim();
                // Only update the property if the value actually changed
                // This prevents unnecessary layout re-renders that cause lag
                if (s !== "" && !isNaN(s) && s !== wifiRoot.strength) {
                    wifiRoot.strength = s;
                }
            }
        }

        // Only start the delay timer after the process has fully exited
        onExited: (code) => {
            delayRestart.start();
        }
    }

    // Delay timer ensures we aren't constantly spawning shells
    Timer {
        id: delayRestart
        interval: 10000 // 10 second refresh is safe for CPU
        repeat: false
        onTriggered: getSignal.running = true
    }

    // Start the first check when the bar loads
    Component.onCompleted: getSignal.running = true

    RowLayout {
        id: wifiLayout
        anchors.fill: parent
        spacing: 12

        // 1. Percentage Text (Left)
        Label {
            id: strengthText
            text: wifiRoot.strength + "%"
            font.family: "BigBlueTermPlusNerdFont"
            font.pixelSize: 18
            color: "white"
            
            // Interaction: Shrink by 0.9 on hover
            scale: textMouse.containsMouse ? 0.9 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }

            MouseArea {
                id: textMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    wifiProc.running = false;
                    wifiProc.running = true;
                }
            }
        }

        // 2. WiFi Icon (Right)
        Label {
            id: wifiIcon
            text: {
                let s = parseInt(wifiRoot.strength);
                if (s > 75) return "󰤨";
                if (s > 50) return "󰤥";
                if (s > 25) return "󰤢";
                if (s > 0) return "󰤟";
                return "󰤯";
            }
            font.family: "BigBlueTermPlusNerdFont"
            font.pixelSize: 20
            color: iconMouse.containsMouse ? "#00ffff" : "white"

            // Interaction: Shrink by 0.9 on hover
            scale: iconMouse.containsMouse ? 0.9 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }

            MouseArea {
                id: iconMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    wifiProc.running = false;
                    wifiProc.running = true;
                }
            }
        }
    }
}
