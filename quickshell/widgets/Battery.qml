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
    if (root.batStatus == UPowerDeviceState.Charging) {
      return Theme.accent
    } else if (root.batPercentage <= 20) {
      return Theme.danger
    } else if (root.batPercentage <= 50) {
      return Theme.warning
    } else {
      return Theme.success
    }
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
  }
}
