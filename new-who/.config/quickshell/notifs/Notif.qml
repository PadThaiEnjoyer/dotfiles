// This is all the behaviour and animations for the notification

import QtQuick
import Quickshell.Io
import "." as Notifs

Item {
    id: root

    signal dismissed

    required property var notif
    property var screen: Qt.size(1920, 1080)

    property var lifetime: 5000

    enum AnimState {
        Returning,
        Inert,
        Flinging,
        Dismissing
    }
    property var state: Notif.Returning
    property var isDragging: false

    property var initialX: 200
    property var initialY: 100
    property var initialR: 45
    property var targetX: 0
    property var targetY: 0
    property var targetR: 0
    property var velocityX: 0
    property var velocityY: 0
    property var velocityR: 0

    FrameAnimation {
        function dampingVelocity(currentVelocity, delta) {
            const spring = 1.0;
            const damping = 0.1;
            const springForce = spring * delta;
            const dampingForce = -damping * currentVelocity;
            return currentVelocity + (springForce + dampingForce);
        }

        running: root.state != Notif.Inert
        onTriggered: {
            if (root.state == Notif.Returning) {
                const deltaX = root.targetX - display.x;
                const deltaY = root.targetY - display.y;
                const deltaR = root.targetR - display.rotation;

                root.velocityX = dampingVelocity(root.velocityX, deltaX);
                root.velocityY = dampingVelocity(root.velocityY, deltaY);
                root.velocityR = dampingVelocity(root.velocityR, deltaR);

                if (Math.abs(root.velocityX) < 0.1 && Math.abs(root.velocityY) < 0.1) {
                    console.log("inter");
                    root.state = Notif.Inert;
                    root.velocityX = 0;
                    root.velocityY = 0;
                    root.velocityR = 0;
                    display.x = root.targetX;
                    display.y = root.targetY;
                    display.rotation = root.targetR;
                }

                if (root.isDragging) {
                    if (Math.abs(root.velocityX) > 1600 || Math.abs(root.velocityY) > 1600) {
                        root.state = Notif.Flinging;
                    }
                }
            } else if (root.state == Notif.Flinging) {
                root.velocityY += 3000 * frameTime;
                display.rotation = -root.velocityY * frameTime;

                dalek.visible = true;
                dalek.x += root.velocityX * frameTime;
                dalek.y += root.velocityY * frameTime;
                dalek.rotation += root.velocityX * 0.2 * frameTime;

                if (display.x > display.width || display.y > root.screen.height) {
                    root.dismissed();
                }
            } else if (root.state == Notif.Dismissing) {
                root.velocityX += frameTime * 20000;

                if (display.x > display.width) {
                    root.dismissed();
                }
            }

            display.x += root.velocityX * frameTime;
            display.y += root.velocityY * frameTime;
            display.rotation += root.velocityR * frameTime;
        }
    }

    implicitWidth: display.width
    implicitHeight: display.height
    anchors.fill: display

    Notifs.Display {
        id: display
        notif: root.notif
        x: root.initialX
        y: root.initialY
        rotation: root.initialR
        transformOrigin: Item.Right
    }
    Image {
        id: dalek
        source: "/home/tudor/assets/dalek.png"
        x: width *0.6 // Keep it inside the notification bounds
        y: -300
        width: display.width * 1.5 // A reasonable size for a 240px notification
        fillMode: Image.PreserveAspectFit // Keeps the Dalek's proportions
        smooth: true // Makes it look better when rotating
        visible: false
        Process {
            id: screamCmd
        }
        onVisibleChanged: () => {
            if (visible) {
                screamCmd.startDetached();
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: display
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        enabled: root.state != Notif.Flinging

        property var prevMouseX: 0
        property var prevMouseY: 0

        onPressed: e => {
            if (enabled && e.buttons & Qt.LeftButton) {
                prevMouseX = e.x;
                prevMouseY = e.y;
                root.isDragging = true;
                root.state = Notif.Inert;
            }
        }
        onReleased: e => {
            if (!(e.buttons & Qt.LeftButton)) {
                root.isDragging = false;
            }
        }
        onPositionChanged: e => {
            if (enabled && root.isDragging) {
                root.state = Notif.Returning;
                root.velocityX = (e.x - prevMouseX) * 150;
                root.velocityY = (e.y - prevMouseY) * 150;
                prevMouseX = e.x;
                prevMouseY = e.y;
            }
        }

        onClicked: e => {
            if (enabled && e.button & Qt.RightButton) {
                root.state = Notif.Dismissing;
            }
        }
    }

    Timer {
        id: timer
        interval: root.lifetime
        repeat: false
        running: !mouseArea.containsMouse && root.state == Notif.Inert
        onTriggered: () => {
            root.state = Notif.Dismissing;
        }
    }

    Process {
        id: playSoundCmd
        command: ["play", "--no-show-progress", "~/assets/notification.wav"]
    }
    Component.onCompleted: playSoundCmd.startDetached()
}
