pragma Singleton

import QtQuick

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

  readonly property string colorPrimary: "#fd5a24"

  readonly property string colorNormal: "#c0caf5"

  readonly property string colorNormal50: "#71778f"

  readonly property string colorDanger: "#f97676"

  readonly property string colorWarning: "#ffff63"

  readonly property string colorSuccess: "#6dff6d"

}
