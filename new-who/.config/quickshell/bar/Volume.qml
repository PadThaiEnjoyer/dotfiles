pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick.Effects
import Quickshell.Io
import "mpris"

// We use an Item instead of a MouseArea as the root to prevent 
// global hovering/shrinking when touching the text.
Item {
    id: root

    required property var bar

    property var node: Pipewire.defaultAudioSink
    PwObjectTracker {
        objects: [root.node]
    }

    implicitWidth: volumeLayout.implicitWidth
    implicitHeight: 26

    RowLayout {
        id: volumeLayout
        anchors.fill: parent
        spacing: 8

        // 1. VOLUME PERCENTAGE TEXT
        Label {
            id: volText
            text: Math.round(root.node.audio.volume * 100) + "%"
            font.family: "BigBlueTermPlusNerdFont"
            font.pixelSize: 18
            color: btMouseArea.containsMouse ? "#00ffff" : "white"
            Layout.alignment: Qt.AlignVCenter
            
            // Text shrink effect
            scale: btMouseArea.containsMouse ? 0.9 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }

            MouseArea {
                id: btMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    btComponent.createObject(root, { "running": true });
                }
            }
        }

        // 2. VOLUME ICON AREA
        Item {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            
            Image {
                id: volIcon
                anchors.fill: parent
                source: {
                    const base = root.node.audio.muted ? "noaudio" : "audio";
                    const props = root.node.properties || {};
                    const isBluez = (root.node.name || "").startsWith("bluez");
                    const hasBtAddress = !!props["api.bluez5.address"];
                    const iconName = props["device.icon-name"] || "";
                    const isBtIcon = iconName.includes("bluetooth");
                    const isBluetooth = isBluez || hasBtAddress || isBtIcon;
                    
                    return `/home/tudor/assets/${base}${isBluetooth ? "-bluetooth" : ""}.png`;
                }
                smooth: false

                // Only shrinks when hovering the ICON mouse area
                scale: (iconMouseArea.containsMouse || popupLoader.active) ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 70 } }
            }

            MouseArea {
                id: iconMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.node.audio.muted = !root.node.audio.muted
            }
        }
    }

    // LazyLoader stays at the root level but now depends on the ICON mouse area
    LazyLoader {
        id: popupLoader
        property bool popupContainsMouse: false
        active: (iconMouseArea.containsMouse || popupContainsMouse)
        
        Behavior on active {
            NumberAnimation { duration: 100 }
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
                function onXChanged() { popup.updatePos(); }
            }

            Component.onCompleted: updatePos()
            function updatePos() {
                // mapToGlobal now maps from the icon area specifically
                const pos = iconMouseArea.mapToGlobal(iconMouseArea.width / 2 - popup.width / 2, iconMouseArea.height);
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
                onMoved: { root.node.audio.volume = slider.value; }
                value: root.node.audio.volume

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitHeight: 16
                    width: slider.availableWidth
                    height: implicitHeight
                    color: "#22ffffff"
                    opacity: root.node.audio.muted ? 0.5 : 1

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
                    color: "#00ffff"
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.5
                        brightness: slider.pressed ? 0.8 : 0.4
                        Behavior on brightness { NumberAnimation { duration: 100 } }
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

    Component {
        id: btComponent
        Process {
            command: ["blueman-manager"]
            onExited: this.destroy()
        }
    }
}
