pragma Singleton

import QtQuick
import Quickshell

QtObject {
  readonly property int imgIconHeight: 25
  readonly property int imgIconWidth: 25

  function imagePath(image) {
    return `${Quickshell.shellDir}/images/${image}`
  }

  function iconPath(image) {
    return `${Quickshell.shellDir}/icons/${image}`
  }

}
