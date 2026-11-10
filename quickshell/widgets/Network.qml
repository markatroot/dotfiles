import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import Quickshell
import QtQuick.Controls
import "../config"
import QtQuick.Effects
import "../components"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  property var wifiDevice: Networking.devices.values.find((d) => d.type === DeviceType.Wifi)
  property var activeNetwork: wifiDevice ? wifiDevice.networks.values.find((n) => n.connected) : null

  readonly property real signalStrength: activeNetwork ? activeNetwork.signalStrength : 0

  readonly property string icon: Icons.wifi(signalStrength, Networking.wifiEnabled && !!activeNetwork)

  readonly property string wifiName: activeNetwork ? activeNetwork.name : ""

  TextInfoReveal {
    show: reveal.active
    text: root.signalStrength > 0 ? root.wifiName : "Not Connected"
  }

  HoverReveal { id: reveal }

  MultiEffect {
    // anchors.fill: wifiIcon
    source: wifiIcon
    colorization: 1.0
    colorizationColor: Theme.fg
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: wifiIcon.width
    Layout.preferredHeight: wifiIcon.height
  }

  Image {
    id: wifiIcon
    visible: false
    verticalAlignment: Text.AlignVCenter
    source: root.icon
    sourceSize.height: Icons.imgIconHeight
    sourceSize.width: Icons.imgIconWidth
  }

}
