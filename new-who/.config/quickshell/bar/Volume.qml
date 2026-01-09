pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick.Effects
import "mpris"

MouseArea {
    id: root

    required property var bar

    property var node: Pipewire.defaultAudioSink
    PwObjectTracker {
        objects: [root.node]
    }

    implicitWidth: 26
    implicitHeight: 26

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    //enabled: MprisController.canChangeVolume

    opacity: enabled ? 1 : 0.5

    Image {
        anchors.fill: parent
        source: {
            const base = root.node.audio.muted ? "noaudio" : "audio";
            
            // Safety check: ensure properties exist before searching
            const props = root.node.properties || {};
            
            // Check 1: Does the node name start with 'bluez' (Standard for Bluetooth)
            const isBluez = (root.node.name || "").startsWith("bluez");
            
            // Check 2: Does it have a Bluetooth MAC address property?
            const hasBtAddress = !!props["api.bluez5.address"];
            
            // Check 3: Fallback to icon name search
            const iconName = props["device.icon-name"] || "";
            const isBtIcon = iconName.includes("bluetooth");

            const isBluetooth = isBluez || hasBtAddress || isBtIcon;
            
            return `/home/tudor/assets/${base}${isBluetooth ? "-bluetooth" : ""}.png`;
        }
        smooth: false

        scale: popupLoader.active ? 0.9 : 1
        Behavior on scale {
            NumberAnimation {
                duration: 70
            }
        }
    }

    onClicked: node.audio.muted = !node.audio.muted

    LazyLoader {
        id: popupLoader

        property bool popupContainsMouse
        active: root.enabled && (root.containsMouse || popupContainsMouse)
        Behavior on active {
            NumberAnimation {
                duration: 100
            }
        }

        PopupWindow {
            id: popup

            visible: true
            anchor.window: root.bar
            implicitWidth: 200
            implicitHeight: 32
            color: "#aa1A1A1A"
            Connections {
                target: root
                function onXChanged() {
                    popup.updatePos();
                }
            }
            Component.onCompleted: updatePos()
            function updatePos() {
                const pos = root.mapToGlobal(root.width / 2 - popup.width / 2, root.height);
                popup.anchor.rect.x = pos.x;
                popup.anchor.rect.y = pos.y + 5;
            }

            Slider {
                id: slider

                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                anchors.margins: 5
                from: 0
                to: 1

                onMoved: {
                    root.node.audio.volume = slider.value;
                }
                value: root.node.audio.volume

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitHeight: 16
                    width: slider.availableWidth
                    height: implicitHeight
                    color: "#22ffffff"
                    opacity: node.audio.muted ? 0.5 : 1

                    Rectangle {
                        anchors.margins: 5
                        x: anchors.leftMargin
                        y: anchors.topMargin
                        width: slider.visualPosition * (parent.width - anchors.leftMargin - anchors.rightMargin)
                        height: parent.height - anchors.topMargin - anchors.bottomMargin
                        color: "#00ffff"
                    }
                }

                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 12
                    implicitHeight: 12
                    radius: 8
                    rotation: 0
                    color: "#00ffff"
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.5
                        brightness: slider.pressed ? 0.8 : 0.4 
                        Behavior on brightness {
                            NumberAnimation { duration: 100 }
                        }
                    }

                }
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
