import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import "../config"

RowLayout {
  id: root

  property var clockDate: systemClock.date

  Column {
    spacing: (textDate.height * -1) + -10 

    Text {
      id: textDate
      text: Qt.formatDateTime(root.clockDate, "ddd, MMM dd yyyy")
      color: Theme.fg
      font.weight: Fonts.bold
      font.family: Fonts.mono
      font.pixelSize: Fonts.xxl * 1.5
      anchors.horizontalCenter: parent.horizontalCenter
      opacity: .3
    }

    Text {
      text: Qt.formatDateTime(root.clockDate, "hh:mmAP")
      color: Theme.fg
      font.weight: Fonts.bold
      font.family: Fonts.mono
      font.pixelSize: Fonts.xxl * 10
      font.letterSpacing: -10
      opacity: .2
    }
  }

  SystemClock {
    id: systemClock
    precision: SystemClock.Minutes
  }
}
