pragma Singleton

import QtQuick
import Quickshell

QtObject {
  id: root

  readonly property string mono: "SFMono Nerd Font"

  readonly property int xs: 10
  readonly property int sm: 12
  readonly property int md: 14
  readonly property int lg: 16
  readonly property int xl: 18
  readonly property int xxl: 24

  readonly property int normal: Font.Normal
  readonly property int medium: Font.Medium
  readonly property int bold: Font.Bold
  readonly property int black: Font.Black
}
