import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import QtQuick.Effects
import ".."

Text {
    id: timetxt
    font.family: "Orbitron"
    font.weight: Font.Bold
    font.pointSize: 18
    font.bold: true
    color: "#FFFFFF" 
    opacity: 0.8
    layer.enabled: true
    layer.effect: MultiEffect {
        blurEnabled: true
        blur: 0.0
        brightness: 0.5 // This creates the "glow"
        colorization: 0.3
        colorizationColor: "#FF991C"
    }

    Process {
        id: dateProc
        command: ["date", "+%H⯁%M"]
        running: true
        stdout: SplitParser {
            onRead: data => timetxt.text = data
        }
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
