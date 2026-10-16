pragma Singleton

import QtQuick
import Quickshell

// Single source of truth for every icon/image the shell uses. Widgets refer
// to the named properties (or the state helpers below) instead of filenames,
// so swapping an icon set only touches this file.
QtObject {
  id: root

  readonly property int imgIconHeight: 22
  readonly property int imgIconWidth: 22

  function imagePath(image) {
    return `${Quickshell.shellDir}/images/${image}`
  }

  function iconPath(image) {
    return `${Quickshell.shellDir}/icons/${image}`
  }

  // System
  readonly property string os: iconPath("arch-linux.svg")
  readonly property string cpu: iconPath("cpu.svg")
  readonly property string memory: iconPath("memory.svg")
  readonly property string clipboard: iconPath("clipboard.svg")
  readonly property string screenRecord: iconPath("disc.svg")

  // Battery
  readonly property string batteryCharging: iconPath("battery-charging.svg")
  readonly property string batteryFull: iconPath("battery-full.svg")
  readonly property string batteryHigh: iconPath("battery-high.svg")
  readonly property string batteryMedium: iconPath("battery-medium.svg")
  readonly property string batteryLow: iconPath("battery-low.svg")
  readonly property string batteryEmpty: iconPath("battery-empty.svg")

  // Volume
  readonly property string volumeMuted: iconPath("speaker-slash.svg")
  readonly property string volumeLow: iconPath("speaker-none.svg")
  readonly property string volumeMedium: iconPath("speaker-low.svg")
  readonly property string volumeHigh: iconPath("speaker-high.svg")

  // Wi-Fi
  readonly property string wifiOff: iconPath("wifi-x.svg")
  readonly property string wifiNone: iconPath("wifi-none.svg")
  readonly property string wifiLow: iconPath("wifi-low.svg")
  readonly property string wifiMedium: iconPath("wifi-medium.svg")
  readonly property string wifiHigh: iconPath("wifi-high.svg")

  // Images
  readonly property string wallpaper: imagePath("forest-one-dark.png")
  readonly property string wallpaperCompanion: imagePath("chowy_front.png")

  // percent: 0-100
  function battery(percent, charging) {
    if (charging) return batteryCharging
    if (percent > 80) return batteryFull
    if (percent > 60) return batteryHigh
    if (percent > 40) return batteryMedium
    if (percent > 16) return batteryLow
    return batteryEmpty
  }

  // level: 0-100+ (Pipewire allows boosting past 100)
  function volume(level, muted) {
    if (muted || level === 0) return volumeMuted
    if (level <= 33) return volumeLow
    if (level <= 66) return volumeMedium
    return volumeHigh
  }

  // strength: 0.0-1.0
  function wifi(strength, connected) {
    if (!connected || strength <= 0) return wifiOff
    if (strength < 0.25) return wifiNone
    if (strength < 0.50) return wifiLow
    if (strength < 0.75) return wifiMedium
    return wifiHigh
  }
}
