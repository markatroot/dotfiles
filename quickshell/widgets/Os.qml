import QtQuick
import QtQuick.Layouts
import "../config"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  property string icon: Icons.os

  Text {
    text: ""
    color: Theme.info
    font.weight: Fonts.black
    font.family: Fonts.mono
    font.pixelSize: Icons.imgIconHeight
    scale: 1.2
  }
  // MultiEffect {
  //   source: osIcon
  //   colorization: 1.0
  //   colorizationColor: Theme.fg
  //   Layout.alignment: Qt.AlignVCenter
  //   Layout.preferredWidth: osIcon.width
  //   Layout.preferredHeight: osIcon.height
  // }
  //
  // Image {
  //   id: osIcon
  //   visible: false
  //   verticalAlignment: Text.AlignVCenter
  //   source: Quickshell.iconPath(root.icon)
  //   sourceSize.height: Icons.imgIconHeight - 2
  //   sourceSize.width: Icons.imgIconWidth - 2
  // }
}

