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

  readonly property string icon: {
    if (!Networking.wifiEnabled || !activeNetwork) return Icons.iconPath(`wifi-off.svg`)
    // if (!active) return "network-wireless-offline-symbolic"
    return Icons.iconPath(root.getWifiIcon(signalStrength))
  }

  readonly property string wifiName: activeNetwork ? activeNetwork.name : ""

  function getWifiIcon(strength) {
    if (strength <= 0)
      return "wifi-off.svg";
    if (strength < 0.25)
    return "wifi-zero.svg";
    if (strength < 0.50)
      return "wifi-low.svg";
    if (strength < 0.75)
      return "wifi-high.svg";
    return "wifi.svg";
  }

  TextInfoReveal {
    show: wifiHover.containsMouse
    text: root.signalStrength > 0 ? root.wifiName : "Not Connected"
  }

  MultiEffect {
    // anchors.fill: wifiIcon
    source: wifiIcon
    colorization: 1.0
    colorizationColor: Fonts.colorNormal
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: wifiIcon.width
    Layout.preferredHeight: wifiIcon.height
  }

  MouseArea {
    id: wifiHover
    anchors.fill: parent
    hoverEnabled: true // Required to detect hover without clicking
  }

  Image {
    id: wifiIcon
    visible: false
    verticalAlignment: Text.AlignVCenter
    source: Quickshell.iconPath(root.icon)
    sourceSize.height: Icons.imgIconHeight - 2
    sourceSize.width: Icons.imgIconWidth - 2
  }

}
