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

  readonly property string colorPrimary: Quickshell.env("THEME_BLUE")

  readonly property string colorNormal: Quickshell.env("THEME_FG")

  readonly property string colorNormal50: "#71778f"

  readonly property string colorDanger: Quickshell.env("THEME_DANGER")

  readonly property string colorWarning: Quickshell.env("THEME_WARNING")

  readonly property string colorSuccess: Quickshell.env("THEME_SUCCESS")

}
