import QtQuick
import QtQuick.Layouts
import "../config"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  property string icon: Icons.os

  Image {
    id: osIcon
    visible: true
    source: root.icon
    fillMode: Image.PreserveAspectFit
    smooth: true
    scale: 1.1
    mipmap: true
    sourceSize.height: Icons.imgIconHeight
    height: Icons.imgIconHeight
    width: Icons.imgIconHeight * implicitWidth / Math.max(1, implicitHeight)
  }
}
