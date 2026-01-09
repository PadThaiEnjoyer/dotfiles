pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick.Effects
import "../.."
import "../../components"
import ".."

PopupWindow {
    id: root

    property bool isOpen: false
    visible: isOpen

    // FIX: Use WlrChildSurface or requestActivate to handle focus instead of a direct "focusable" property.
    // This also triggers the track update so info appears immediately on open.
    onIsOpenChanged: {
        if (isOpen) {
            trackStack.updateTrack(false, true); // [cite: 43, 44]
            root.requestActivate();
        }
    }

    implicitWidth: 700
    implicitHeight: 800

    mask: Region {
        item: wrapper
    }

    color: "transparent"

    property Scope positionInfo: Scope {
        id: positionInfo

        // FIXED SYNTAX: Properly defined properties to avoid "Expected token" errors 
        property int position: Math.floor(MprisController.activePlayer.position)
        property int length: Math.floor(MprisController.activePlayer.length)

        Timer {
            id: posTracker
            interval: 500
            running: MprisController.activePlayer.isPlaying && root.isOpen // [cite: 2]
            repeat: true
            onTriggered: {
                // Explicitly update the local position property to refresh the UI [cite: 2]
                positionInfo.position = Math.floor(MprisController.activePlayer.position);
                MprisController.activePlayer.positionChanged();
            }
        }

        function timeStr(time: int): string {
            const seconds = time % 60;
            const minutes = Math.floor(time / 60);
            return `${minutes}:${seconds.toString().padStart(2, '0')}`; // [cite: 3, 4]
        }
    }

    // Static Ropes [cite: 4, 5]
    Rope {
        segmentCount: 4; segmentLen: 22
        start: Qt.vector2d(250, -5)
        end: Qt.vector2d(wrapper.x + 49, wrapper.y)
        color: "#FF0000"
    }
    Rope {
        segmentCount: 4; segmentLen: 22
        start: Qt.vector2d(wrapper.width + 200 - 50, -5)
        end: Qt.vector2d(wrapper.width + wrapper.x - 49, wrapper.y)
        color: "#00aa00"
    }

    Rectangle {
        id: wrapper
        implicitWidth: 500
        implicitHeight: popupContent.implicitHeight + popupContent.anchors.margins * 2
        color: "transparent"

        // Static Position [cite: 6, 7]
        x: 200
        y: 70 

        // Right-click to close logic [cite: 8, 9]
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton 
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    root.isOpen = false;
                }
            }
        }

        Item {
            anchors.fill: parent
            layer.enabled: root.isOpen // [cite: 10]
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1.0 
                brightness: -0.1 
            }
            
            Rectangle {
                anchors.fill: parent
                color: "#aa1A1A1A" 
                border.color: "#00ffff" 
                border.width: 4 // [cite: 11]
            }
        }

        ColumnLayout {
            id: popupContent
            anchors.fill: parent
            anchors.margins: 8

            Connections {
                target: MprisController
                function onTrackChanged(reverse: bool) {
                    trackStack.updateTrack(reverse, true); // [cite: 23, 24]
                }
            }

            // Player Icon Selector [cite: 29, 31, 35]
            Item {
                id: playerSelectorContainment
                Layout.fillWidth: true
                implicitHeight: 60

                RowLayout {
                    id: playerSelector
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Repeater {
                        model: Mpris.players
                        MouseArea {
                            required property MprisPlayer modelData
                            implicitWidth: 50; implicitHeight: 50
                            onClicked: MprisController.setActivePlayer(modelData)
                            
                            Image {
                                anchors.fill: parent; anchors.margins: 5
                                source: {
                                    const identity = modelData.identity.toLowerCase();
                                    if (identity.includes("chrome") || identity.includes("chromium")) return Quickshell.iconPath("google-chrome");
                                    if (identity.includes("firefox")) return Quickshell.iconPath("firefox");
                                    if (identity.includes("spotify")) return Quickshell.iconPath("spotify");
                                    if (modelData.identity == "Brave") return "/opt/brave-bin/product_logo_64.png";
                                    const entry = DesktopEntries.byId(modelData.desktopEntry);
                                    if (entry && entry.icon) return Quickshell.iconPath(entry.icon);
                                    return "/home/tudor/assets/mpd.png";
                                }
                                cache: true
                                asynchronous: true
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true; Layout.topMargin: 4; Layout.bottomMargin: 8
                Label {
                    anchors.centerIn: parent
                    text: MprisController.activePlayer.identity
                    font.family: "BigBlueTermPlusNerdFont"
                    color: "white" // [cite: 41]
                }
            }

            // Track Details [cite: 42, 45, 52]
            SlideView {
                id: trackStack
                Layout.fillWidth: true; implicitHeight: 130
                function updateTrack(reverse: bool, immediate: bool) {
                    this.replace(trackComponent, { track: MprisController.activeTrack }, immediate);
                }

                property var trackComponent: Component {
                    RowLayout {
                        id: trackRow
                        required property var track
                        spacing: 15
                        Rectangle {
                            implicitHeight: 120; implicitWidth: 120; color: "transparent"
                            Image {
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: parent.parent.track.artUrl || ""
                                cache: true; asynchronous: true
                            }
                        }
                        ColumnLayout {
                            Label { 
                                text: trackRow.track.title
                                font.family: "BigBlueTermPlusNerdFont"; font.pointSize: 12
                                color: "white"; elide: Text.ElideRight; Layout.maximumWidth: 300 
                            }
                            Label { 
                                text: trackRow.track.album; opacity: 0.7
                                font.family: "BigBlueTermPlusNerdFont"; color: "white"
                                elide: Text.ElideRight; Layout.maximumWidth: 300 
                            }
                            Label { 
                                text: trackRow.track.artist; opacity: 0.7
                                font.family: "BigBlueTermPlusNerdFont"; color: "white"
                                elide: Text.ElideRight; Layout.maximumWidth: 300 
                            }
                        }
                    }
                }
            }

            // Media Controls [cite: 70, 75, 78, 82]
            RowLayout {
                id: controlsRow
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                ClickableIcon {
                    implicitWidth: 24; implicitHeight: 24
                    enabled: MprisController.loopSupported
                    image: {
                        switch (MprisController.loopState) {
                            case MprisLoopState.None: return "/home/tudor/assets/repeat-off.png";
                            case MprisLoopState.Playlist: return "/home/tudor/assets/repeat.png";
                            case MprisLoopState.Track: return "/home/tudor/assets/repeat-once.png";
                        }
                    }
                    onClicked: {
                        let target = MprisLoopState.None;
                        if (MprisController.loopState == MprisLoopState.None) target = MprisLoopState.Playlist;
                        else if (MprisController.loopState == MprisLoopState.Playlist) target = MprisLoopState.Track;
                        MprisController.setLoopState(target);
                    }
                }

                ClickableIcon {
                    implicitWidth: 32; implicitHeight: 32
                    enabled: MprisController.canGoPrevious
                    image: "/home/tudor/assets/fastforward.png"; mirror: true
                    onClicked: MprisController.previous()
                }

                ClickableIcon {
                    implicitWidth: 42; implicitHeight: 42
                    enabled: MprisController.canTogglePlaying
                    image: `/home/tudor/assets/${MprisController.isPlaying ? "pause" : "play"}.png`
                    onClicked: MprisController.togglePlaying()                       
                }

                ClickableIcon {
                    implicitWidth: 32; implicitHeight: 32
                    enabled: MprisController.canGoNext
                    image: "/home/tudor/assets/fastforward.png"
                    onClicked: MprisController.next()
                }

                ClickableIcon {
                    implicitWidth: 24; implicitHeight: 24
                    enabled: MprisController.shuffleSupported
                    image: `/home/tudor/assets/${MprisController.hasShuffle ? "shuffle" : "noshuffle"}.png`
                    onClicked: MprisController.setShuffle(!MprisController.hasShuffle)
                }
            }

            // Progress Slider [cite: 84, 87, 90]
            RowLayout {
                Layout.fillWidth: true; Layout.margins: 10
                Label { 
                    text: positionInfo.timeStr(positionInfo.position)
                    color: "white"; font.family: "BigBlueTermPlusNerdFont" 
                }
                Slider {
                    id: slider; Layout.fillWidth: true
                    enabled: MprisController.activePlayer.canSeek
                    from: 0; to: 1
                    value: positionInfo.length > 0 ? positionInfo.position / positionInfo.length : 0
                    background: Rectangle { 
                        implicitHeight: 24; color: "#22ffffff" 
                        Rectangle {
                            anchors.margins: 8; x: 8; y: 8
                            width: slider.visualPosition * (parent.width - 16)
                            height: parent.height - 16; color: "#00ffff"
                        }
                    }
                }
                Label { 
                    text: positionInfo.timeStr(positionInfo.length)
                    color: "white"; font.family: "BigBlueTermPlusNerdFont" 
                }
            }
        }
    }

    // Tie Wires [cite: 92, 95]
    Image { source: "/home/tudor/assets/wire-tie-red.png"; width: 32; height: 32; x: wrapper.x + 49 - 16; y: wrapper.y - 16 }
    Image { source: "/home/tudor/assets/wire-tie-green.png"; width: 32; height: 32; x: wrapper.width + wrapper.x - 49 - 16; y: wrapper.y - 16 }
}
