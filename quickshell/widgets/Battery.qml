import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../config"
import "../components"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter
  Layout.fillHeight: true

  property int batPercentage: UPower.displayDevice.percentage * 100

  property var batStatus: UPower.displayDevice.state

  function getColor() {
    if (root.batPercentage <= 20) {
      return Theme.danger
    } else if (root.batPercentage <= 50) {
      return Theme.warning
    } else {
      return Theme.success
    }
  }

  HoverReveal { id: reveal }

  TextInfoReveal {
    show: reveal.active
    text: UPower.displayDevice.state == UPowerDeviceState.Charging 
    ? `${batIcon.secondsToHoursMinutes('', UPower.displayDevice.timeToFull)}`
    : `${batIcon.secondsToHoursMinutes('', UPower.displayDevice.timeToEmpty)}`
  }

  MultiEffect {
    source: batIcon
    colorization: 1.0
    colorizationColor: root.getColor()
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: batIcon.width
    Layout.preferredHeight: batIcon.height
  }

  Image {
    id: batIcon
    visible: false
    source: Icons.battery(root.batPercentage, root.batStatus == UPowerDeviceState.Charging)
    sourceSize.height: Icons.imgIconHeight + 3
    sourceSize.width: Icons.imgIconWidth + 3
    height: sourceSize.height
    width: sourceSize.width

    function secondsToHoursMinutes(label, seconds) {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      UPower.displayDevice.timeToEmptyChanged
      return `${label ? label + ' ' : ''}${hours ? hours + 'hrs' : ''} ${minutes ? minutes + 'mins' : ''}` +
      `(${(Math.floor(root.batPercentage))}%)`
    }

  }

  onBatStatusChanged: reveal.poke()
}
