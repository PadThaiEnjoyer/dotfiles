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

    Process {
        id: wifiProc
        command: ["networkmanager_dmenu"]
    }

    Process {
        id: getSignal
        command: ["bash", "-c", "nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d: -f2"]
        stdout: SplitParser {
            onRead: (data) => {
                let s = data.trim();
                if (s !== "" && !isNaN(s)) {
                    wifiRoot.strength = s;
                }
            }
        }
    }

    Timer {
        interval: 30000 // Refreshes every 30 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getSignal.running = false;
            getSignal.running = true;
        }
    }

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
            
            // Shrink effect
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

            // Shrink effect
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
