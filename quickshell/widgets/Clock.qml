import QtQuick
import QtQuick.Layouts
import Quickshell
import "../config"

RowLayout {
  id: root

  property var clockDate: systemClock.date

  Column {
    spacing: -20

    Text {
      text: Qt.formatDateTime(root.clockDate, "ddd, MMM dd yyyy")
      color: "#4f5775" // Fonts.colorNormal
      font.weight: Fonts.bold
      font.family: Fonts.mono
      font.pixelSize: Fonts.xxl
      anchors.horizontalCenter: parent.horizontalCenter
    }
    Text {
      text: Qt.formatDateTime(root.clockDate, "hh:mmAP")
      color: "#4f5775" // Fonts.colorNormal
      font.weight: Fonts.bold
      font.family: Fonts.mono
      font.pixelSize: Fonts.xxl * 6
    }
  }

  SystemClock {
    id: systemClock
    precision: SystemClock.Minutes
  }
}
