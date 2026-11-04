import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../services" as QsServices
import "../config"

// Detailed readout for the topbar's right-side items. Shown in the main pill
// when it expands on hover (see Topbar.qml).
ColumnLayout {
  id: root
  spacing: 18

  readonly property color labelColor: Qt.alpha(Theme.fg, 0.7)
  readonly property color dimColor: Qt.alpha(Theme.fg, 0.6)

  // ── CPU / memory / uptime
  readonly property real cpuFraction: QsServices.SystemResourcesService.cpuPerc
  readonly property real cpuTemp: QsServices.SystemResourcesService.cpuTemp
  readonly property real memUsed: parseFloat(QsServices.SystemResourcesService.memUsed) || 0
  readonly property real memTotal: parseFloat(QsServices.SystemResourcesService.memTotal) || 0
  readonly property real uptime: QsServices.SystemResourcesService.uptime

  // ── Volume
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property bool sinkReady: !!sink && sink.ready
  readonly property bool muted: sinkReady && sink.audio.muted
  readonly property int volume: sinkReady ? Math.round(sink.audio.volume * 100) : 0

  // ── Network
  readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
  readonly property var activeNetwork: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null
  readonly property real signal: activeNetwork ? activeNetwork.signalStrength : 0

  // ── Battery
  readonly property var battery: UPower.displayDevice
  readonly property real batFraction: battery.percentage
  readonly property bool charging: battery.state === UPowerDeviceState.Charging

  function levelColor(fraction) {
    if (fraction <= 0.2) return Theme.danger
    if (fraction <= 0.5) return Theme.warning
    return Theme.success
  }

  function duration(seconds) {
    if (!seconds || seconds <= 0) return ""
    const d = Math.floor(seconds / 86400)
    const h = Math.floor((seconds % 86400) / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    if (d) return `${d}d ${h}h`
    return h ? `${h}h ${m}m` : `${m}m`
  }

  function batteryDetail() {
    switch (battery.state) {
    case UPowerDeviceState.Charging: {
      const t = duration(battery.timeToFull)
      return t ? `Charging · full in ${t}` : "Charging"
    }
    case UPowerDeviceState.Discharging: {
      const t = duration(battery.timeToEmpty)
      return t ? `${t} left` : "Discharging"
    }
    case UPowerDeviceState.FullyCharged: return "Full"
    case UPowerDeviceState.PendingCharge: return "Plugged in, not charging"
    default: return UPowerDeviceState.toString(battery.state)
    }
  }

  // "Built-in Audio Analog Stereo" -> "Built-in Audio"
  function sinkName() {
    if (!sinkReady) return "No output"
    const name = sink.description || sink.nickname || sink.name
    return name.replace(/\s+(Analog|Digital)\s+(Stereo|Surround).*$/i, "")
  }

  component DetailRow: RowLayout {
    id: row
    property string icon
    property color iconColor: root.labelColor
    property string label
    property string value
    property color valueColor: Theme.fg
    property string detail: ""

    Layout.fillWidth: true
    Layout.preferredHeight: 28
    spacing: 0

    Item {
      Layout.preferredWidth: 39
      Layout.fillHeight: true

      Image {
        id: rowIcon
        visible: false
        source: row.icon
        sourceSize.width: 20
        sourceSize.height: 20
      }

      MultiEffect {
        anchors.verticalCenter: parent.verticalCenter
        width: rowIcon.width
        height: rowIcon.height
        source: rowIcon
        colorization: 1.0
        colorizationColor: row.iconColor
      }
    }

    Text {
      Layout.preferredWidth: 110
      text: row.label.toUpperCase()
      color: root.labelColor
      font { family: Fonts.mono; pixelSize: 14; weight: Fonts.bold; letterSpacing: 1 }
    }

    Text {
      text: row.value
      color: row.valueColor
      font { family: Fonts.mono; pixelSize: 18; weight: Fonts.medium }
    }

    Text {
      Layout.fillWidth: true
      Layout.leftMargin: 16
      horizontalAlignment: Text.AlignRight
      text: row.detail
      color: root.dimColor
      elide: Text.ElideLeft
      font { family: Fonts.mono; pixelSize: Fonts.lg }
    }
  }

  RowLayout {
    Layout.fillWidth: true
    Layout.preferredHeight: 20
    Layout.bottomMargin: -4

    Text {
      text: "SYSTEM"
      color: root.dimColor
      font { family: Fonts.mono; pixelSize: 12; weight: Fonts.bold; letterSpacing: 2 }
    }

    Text {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignRight
      text: root.uptime > 0 ? `Up ${root.duration(root.uptime)}` : ""
      color: root.dimColor
      font { family: Fonts.mono; pixelSize: Fonts.lg }
    }
  }

  DetailRow {
    icon: Icons.cpu
    label: "CPU"
    value: `${Math.round(root.cpuFraction * 100)}%`
    valueColor: root.cpuFraction > 0.9 ? Theme.danger : Theme.fg
    detail: root.cpuTemp >= 0 ? `${Math.round(root.cpuTemp)} °C` : ""
  }

  DetailRow {
    icon: Icons.memory
    label: "Memory"
    value: `${root.memUsed.toFixed(1)} GB`
    detail: root.memTotal > 0 ? `of ${root.memTotal.toFixed(1)} GB` : ""
  }

  DetailRow {
    icon: Icons.volume(root.volume, root.muted)
    label: "Volume"
    value: root.muted ? "Muted" : `${root.volume}%`
    valueColor: root.muted ? root.dimColor : Theme.fg
    detail: root.sinkName()
  }

  DetailRow {
    icon: Icons.wifi(root.signal, Networking.wifiEnabled && !!root.activeNetwork)
    label: "Wi-Fi"
    value: !Networking.wifiEnabled ? "Off"
      : root.activeNetwork ? root.activeNetwork.name : "Not connected"
    valueColor: root.activeNetwork ? Theme.fg : root.dimColor
    detail: root.activeNetwork ? `${Math.round(root.signal * 100)}% signal` : ""
  }

  DetailRow {
    icon: Icons.battery(root.batFraction * 100, root.charging)
    iconColor: root.charging ? Theme.accent : root.labelColor
    label: "Battery"
    value: `${Math.round(root.batFraction * 100)}%`
    valueColor: root.charging ? Theme.accent : root.levelColor(root.batFraction)
    detail: root.batteryDetail()
  }
}
