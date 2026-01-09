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
    implicitWidth: 700
    implicitHeight: 800

    mask: Region {
        item: wrapper
    }

    color: "transparent"

    property Scope positionInfo: Scope {
        id: positionInfo

        property int position: Math.floor(MprisController.activePlayer.position)
        property int length: Math.floor(MprisController.activePlayer.length)

        // FIX 1: Use a Timer instead of FrameAnimation to stop CPU pinning
        Timer {
            id: posTracker
            interval: 500
            running: MprisController.activePlayer.isPlaying
            repeat: true
            onTriggered: MprisController.activePlayer.positionChanged()
        }

        function timeStr(time: int): string {
            const seconds = time % 60;
            const minutes = Math.floor(time / 60);

            return `${minutes}:${seconds.toString().padStart(2, '0')}`;
        }
    }

    Rope {
        segmentCount: 4
        segmentLen: 22
        start: Qt.vector2d(250, -5)
        end: Qt.vector2d(wrapper.x + 49, wrapper.y)
        color: "#FF0000"
    }
    Rope {
        segmentCount: 4
        segmentLen: 22
        start: Qt.vector2d(wrapper.width + 200 - 50, -5)
        end: Qt.vector2d(wrapper.width + wrapper.x - 49, wrapper.y)
        color: "#00aa00"
    }

    Rectangle {
        id: wrapper
        implicitWidth: 500
        implicitHeight: popupContent.implicitHeight + popupContent.anchors.margins * 2
        color: "transparent"

        x: 200
        y: -wrapper.height
  
        readonly property var targetX: 200
        readonly property var targetY: root.isOpen ? 70 : -wrapper.height - 50
        property var velocityX: 0        
        property var velocityY: 0

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton 
            
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.isOpen = false;
                    root.focusable = false;
                }
            }
        }

        Item {
            anchors.fill: parent
            // FIX 2: Disable blur when window is closed to save resources
            layer.enabled: root.isOpen 
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1.0 
                brightness: -0.1 
            }
            
            Rectangle {
                anchors.fill: parent
                color: "#aa1A1A1A" 
                border.color: "#00ffff" 
                border.width: 4
            }
        }

        FrameAnimation {
            running: true
            function dampingVelocity(currentVelocity, delta) {
                const spring = 8.0;
                const damping = 0.3;
                const springForce = spring * delta;
                const dampingForce = -damping * currentVelocity;
                return currentVelocity + (springForce + dampingForce);
            }
            onTriggered: {
                const deltaX = wrapper.targetX - wrapper.x;
                const deltaY = wrapper.targetY - wrapper.y;
                
                // FIX 3: Physics "Sleep" logic - stop calculating when still
                if (Math.abs(deltaX) > 0.1 || Math.abs(deltaY) > 0.1 || Math.abs(wrapper.velocityX) > 0.1) {
                    wrapper.velocityX = dampingVelocity(wrapper.velocityX, deltaX);
                    wrapper.velocityY = dampingVelocity(wrapper.velocityY, deltaY);
                    wrapper.x += wrapper.velocityX * frameTime;
                    wrapper.y += wrapper.velocityY * frameTime;
                } else {
                    // Idle the physics engine
                    wrapper.x = wrapper.targetX;
                    wrapper.y = wrapper.targetY;
                    wrapper.velocityX = 0;
                    wrapper.velocityY = 0;
                }
            }
        }

        MouseArea {
            property var prevMouseX: 0
            property var prevMouseY: 0
            anchors.fill: parent
            onPressed: e => {
                prevMouseX = e.x;
                prevMouseY = e.y;
            }
            onPositionChanged: e => {
                wrapper.x += (e.x - prevMouseX) * 0.3;
                wrapper.y += (e.y - prevMouseY) * 0.3;
                prevMouseX = e.x;
                prevMouseY = e.y;
            }
        }

        // --- THE FULL ORIGINAL CONTENT STARTS HERE ---
        ColumnLayout {
            id: popupContent
            anchors.fill: parent
            anchors.margins: 8

            Connections {
                target: MprisController
                function onTrackChanged(reverse: bool) {
                    trackStack.updateTrack(reverse, false);
                }
            }

            Item {
                id: playerSelectorContainment
                Layout.fillWidth: true
                implicitHeight: playerSelector.implicitHeight
                implicitWidth: playerSelector.implicitWidth

                Rectangle {
                    anchors.centerIn: parent
                    implicitWidth: 50
                    implicitHeight: 50
                    color: "#00000000"
                }

                RowLayout {
                    id: playerSelector
                    property Item selectedPlayerDisplay: Mpris.players[0]
                    x: parent.width / 2 - (selectedPlayerDisplay ? selectedPlayerDisplay.x + selectedPlayerDisplay.width / 2 : 0)
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on x {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutExpo
                        }
                    }

                    Repeater {
                        model: Mpris.players
                        MouseArea {
                            required property MprisPlayer modelData
                            readonly property bool selected: modelData == MprisController.activePlayer
                            onSelectedChanged: () => {
                                if (selected) playerSelector.selectedPlayerDisplay = this;
                            }
                            implicitWidth: childrenRect.width
                            implicitHeight: childrenRect.height
                            onClicked: MprisController.setActivePlayer(modelData)

                            Item {
                                width: 50
                                height: 50
                                Image {
                                    anchors.fill: parent
                                    source: {
                                        const identity = modelData.identity.toLowerCase();
                                        if (identity.includes("chrome") || identity.includes("chromium")) return Quickshell.iconPath("google-chrome") || Quickshell.iconPath("chromium");
                                        if (identity.includes("firefox")) return Quickshell.iconPath("firefox");
                                        if (identity.includes("spotify")) return Quickshell.iconPath("spotify");
                                        if (modelData.identity == "Brave") return "/opt/brave-bin/product_logo_64.png";
                                        const entry = DesktopEntries.byId(modelData.desktopEntry);
                                        if (entry && entry.icon) return Quickshell.iconPath(entry.icon);
                                        return "/home/tudor/assets/mpd.png";
                                    }
                                    smooth: false
                                    sourceSize.width: 50
                                    sourceSize.height: 50
                                    cache: true // Set to true to help CPU
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.topMargin: 8
                Layout.bottomMargin: 16
                Label {
                    anchors.centerIn: parent
                    text: MprisController.activePlayer.identity
                    font.family: "BigBlueTermPlusNerdFont"
                    color: "white"
                }
            }

            SlideView {
                id: trackStack
                Layout.fillWidth: true
                implicitHeight: 100
                clip: animating || (lastFlicked?.contentX ?? 0) != 0

                property Flickable lastFlicked
                property bool reverse: false

                Component.onCompleted: updateTrack(false, true)

                function updateTrack(reverse: bool, immediate: bool) {
                    this.reverse = reverse;
                    this.replace(trackComponent, {
                        track: MprisController.activeTrack
                    }, immediate);
                }

                property var trackComponent: Component {
                    Flickable {
                        id: flickable
                        required property var track
                        readonly property bool svReady: img.status === Image.Ready
                        contentWidth: width + 1
                        onDragStarted: trackStack.lastFlicked = this
                        onDragEnded: {
                            if (Math.abs(contentX) > 75) {
                                if (contentX < 0) MprisController.previous();
                                else if (contentX > 0) MprisController.next();
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 8
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                implicitHeight: 128
                                implicitWidth: 128
                                color: "transparent"
                                Image {
                                    id: img
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop
                                    visible: flickable.track.artUrl != ""
                                    source: flickable.track.artUrl
                                    cache: true
                                    asynchronous: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                Label {
                                    text: flickable.track.title
                                    font.pointSize: albumLabel.font.pointSize + 1
                                    font.family: "BigBlueTermPlusNerdFont"
                                    color: "white"
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: Math.min(300, implicitWidth)
                                }
                                Label {
                                    id: albumLabel
                                    text: flickable.track.album
                                    opacity: 0.8
                                    font.family: "BigBlueTermPlusNerdFont"
                                    color: "white"
                                    Layout.maximumWidth: Math.min(300, implicitWidth)
                                }
                                Label {
                                    text: flickable.track.artist
                                    opacity: 0.8
                                    font.family: "BigBlueTermPlusNerdFont"
                                    color: "white"
                                    Layout.maximumWidth: Math.min(300, implicitWidth)
                                }
                            }
                        }
                    }
                }

                readonly property real fromPos: trackStack.width * (trackStack.reverse ? -1 : 1)

                enterTransition: PropertyAnimation {
                    property: "x"
                    from: trackStack.fromPos
                    to: 0
                    duration: 350
                    easing.type: Easing.OutExpo
                }
                exitTransition: PropertyAnimation {
                    property: "x"
                    to: target.x - trackStack.fromPos
                    duration: 350
                    easing.type: Easing.OutExpo
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: controlsRow.implicitHeight

                RowLayout {
                    id: controlsRow
                    anchors.centerIn: parent

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
                        image: "/home/tudor/assets/fastforward.png"
                        mirror: true
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
            }

            RowLayout {
                Layout.margins: 5
                Label {
                    text: positionInfo.timeStr(positionInfo.position)
                    font.family: "BigBlueTermPlusNerdFont"
                    color: "white"
                }
                Slider {
                    id: slider
                    Layout.fillWidth: true
                    enabled: MprisController.activePlayer.canSeek
                    from: 0; to: 1
                    value: MprisController.activePlayer.length > 0 ? MprisController.activePlayer.position / MprisController.activePlayer.length : 0
                    
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
                    font.family: "BigBlueTermPlusNerdFont"
                    color: "white"
                }
            }
        }
    }

    Image {
        source: "/home/tudor/assets/wire-tie-red.png"
        width: 32; height: 32
        x: wrapper.x + 49 - 16; y: wrapper.y - 16
    }
    Image {
        source: "/home/tudor/assets/wire-tie-green.png"
        width: 32; height: 32
        x: wrapper.width + wrapper.x - 49 - 16; y: wrapper.y - 16
    }
}
