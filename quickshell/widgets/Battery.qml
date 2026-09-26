import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Services.UPower
import "../config"
import "../components"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter
  Layout.fillHeight: true

  property int batPercentage: UPower.displayDevice.percentage * 100

  function getColor() {
    if (root.batPercentage <= 20) {
      return Fonts.colorDanger
    } else if (root.batPercentage <= 50) {
      return Fonts.colorWarning
    } else {
      return Fonts.colorSuccess
    }
  }

  TextInfoReveal {
    show: batteryHover.containsMouse
    text: UPower.displayDevice.state == UPowerDeviceState.Charging 
    ? `${batIcon.secondsToHoursMinutes('Charging:', UPower.displayDevice.timeToFull)}`
    : `${batIcon.secondsToHoursMinutes('Discharging:', UPower.displayDevice.timeToEmpty)}`
  }

  MultiEffect {
    source: batIcon
    colorization: 1.0
    colorizationColor: root.getColor()
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: batIcon.width
    Layout.preferredHeight: batIcon.height
  }

  MouseArea {
    id: batteryHover
    anchors.fill: parent
    hoverEnabled: true // Required to detect hover without clicking
  }

  Image {
    id: batIcon
    visible: false
    source: `${Quickshell.shellDir}/icons/${batIcon.getIcon()}`
    sourceSize.height: Icons.imgIconHeight
    sourceSize.width: Icons.imgIconWidth
    height: sourceSize.height
    width: sourceSize.width

    function getIcon() {
      if (UPower.displayDevice.state == UPowerDeviceState.Charging) {
        return 'battery-charging.svg'
      } else {
        if (root.batPercentage > 98) {
          return 'battery-full.svg'
        } else if (root.batPercentage > 80) {
          return 'battery-full.svg'
        } else if (root.batPercentage > 64) {
          return 'battery-medium.svg'
        } else if (root.batPercentage > 48) {
          return 'battery-medium.svg'
        } else if (root.batPercentage > 32) {
          return 'battery-low.svg'
        } else if (root.batPercentage > 16) {
          return 'battery-low.svg'
        } else if (root.batPercentage < 16) {
          return 'battery.svg'
        } else {
          return 'battery.svg'
        }
      }
    }

    function secondsToHoursMinutes(label, seconds) {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      UPower.displayDevice.timeToEmptyChanged
      return `${label} ${hours ? hours + 'hrs' : ''} ${minutes ? minutes + 'mins' : ''}` +
      `(${(Math.floor(root.batPercentage))}%)`
    }

  }

}
