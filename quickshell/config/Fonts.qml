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

  // readonly property string colorPrimary: "#ed8796"

  readonly property color colorPrimary: Theme.primary

  readonly property color colorNormal: Theme.fg

  readonly property color colorNormal50: Qt.darker(Theme.fg, 1.5)

  readonly property color colorDanger: Theme.danger

  readonly property color colorWarning: Theme.warning

  readonly property color colorSuccess: Theme.success

}
