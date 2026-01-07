import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import "./"

PanelWindow {
    property var modelData
    screen: modelData

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: false
    color: "transparent"
    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }
    Image {
        id: bg
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: `/home/tudor/assets/Wallpapers/tardis-ints/tardis-int${Globals.tardisIndex}.png`
        smooth: false
    }
    MultiEffect {
        source: bg
        anchors.fill: bg
        blurEnabled: false
        blurMax: 24
        blur: 1.0
    }

}
