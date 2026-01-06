import QtQuick
import Quickshell.Services.UPower

Item {
    id: root
    
    // Give it a fixed width for testing to ensure it's not 0
    implicitWidth: 32 
    implicitHeight: 32
    readonly property real percentage: UPower.displayDevice.percentage
    readonly property bool isLow: percentage <= 0.20

    Text {
        id: batteryLabel
        anchors.centerIn: parent
        
        // If percentage is 0 or NaN, it will show 0%
        text: Math.round((percentage || 0) * 100) + "%"
        color: isLow ? "#ff7b7b" : "#EEA939" 
        font.pixelSize: 20
        font.bold: true
        font.family: "BigBlueTermPlusNerdFont"
        
        // Remove the 'visible' check temporarily to see if it appears
        visible: true 
    }
}
