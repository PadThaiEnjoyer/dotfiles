pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Hyprland

MouseArea {
    id: root

    required property var bar
    property int wsBaseIndex: 1
    property int wsCount: 10
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    property int currentIndex: 0
    property int existsCount: 0

    signal workspaceAdded(workspace: HyprlandWorkspace)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    acceptedButtons: Qt.NoButton

    onWheel: e => {
        e.accepted = true;
        const step = -Math.sign(e.angleDelta.y);
        const targetWs = currentIndex + step;

        if (targetWs >= wsBaseIndex && targetWs < wsBaseIndex + wsCount) {
            Hyprland.dispatch(`workspace ${targetWs}`);
        }
    }

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 12

        Repeater {
            model: root.wsCount

            MouseArea {
                id: wsItem

                required property int index
                property int wsIndex: root.wsBaseIndex + index
                property HyprlandWorkspace workspace: null
                property bool exists: workspace != null
                property bool active: (root.monitor?.activeWorkspace ?? false) && root.monitor.activeWorkspace == workspace

                // VISIBILITY: Only show up to the highest workspace currently in use
                property bool shouldShow: {
                    let maxActive = 1;
                    const workspaces = Hyprland.workspaces.values;
                    for (let i = 0; i < workspaces.length; i++) {
                        if (workspaces[i].id > maxActive) {
                            maxActive = workspaces[i].id;
                        }
                    }
                    // Always show at least the first workspace, otherwise up to the max active one
                    return wsIndex <= maxActive;
                }
                
                visible: shouldShow
                implicitWidth: 32
                implicitHeight: 32

                // HOVER EFFECT: Shrinks to 0.8 size when mouse enters
                hoverEnabled: true
                scale: containsMouse ? 0.9 : 1.0
                Behavior on scale { 
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic } 
                }

                acceptedButtons: Qt.LeftButton
                onPressed: Hyprland.dispatch(`workspace ${wsIndex}`)

                onExistsChanged: {
                    root.existsCount += exists ? 1 : -1;
                }

                onActiveChanged: {
                    if (active) root.currentIndex = wsIndex;
                }

                Connections {
                    target: root
                    function onWorkspaceAdded(workspace: HyprlandWorkspace) {
                        if (workspace.id == wsItem.wsIndex) {
                            wsItem.workspace = workspace;
                        }
                    }
                }

                // THE IMAGE & COLORING SECTION
                Image {
                    id: galSymbol
                    anchors.fill: parent
                    smooth: true
                    asynchronous: true
                    source: `file:///home/tudor/assets/workspace_images/gal_${wsIndex}.png`
                    
                    // Greyed out (0.3 opacity) if workspace is empty
                    opacity: wsItem.exists ? 1.0 : 0.3
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        
                        // Default color is White, Active color is Gold (#FFD700)
                        colorizationColor: wsItem.active ? "#FFD700" : "#FFFFFF"
                        
                        // Active Glow
                        blurEnabled: wsItem.active
                        blur: 0.4
                        brightness: wsItem.active ? 0.6 : 0.0

                        Behavior on brightness { NumberAnimation { duration: 200 } }
                        Behavior on colorizationColor { ColorAnimation { duration: 200 } }
                    }
                }
            }
        }
    }

    Connections {
        target: Hyprland.workspaces
        function onObjectInsertedPost(workspace) {
            root.workspaceAdded(workspace);
        }
    }

    Component.onCompleted: {
        Hyprland.workspaces.values.forEach(workspace => {
            root.workspaceAdded(workspace);
        });
    }
}
