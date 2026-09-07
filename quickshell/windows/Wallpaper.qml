import Quickshell
import QtQuick
import Quickshell.Wayland
import "../config"
import "../widgets" as Widgets

PanelWindow {
  id: root
  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }
  WlrLayershell.layer: WlrLayer.Background
  WlrLayershell.namespace: "quickshell:my-wallpaper"
  WlrLayershell.exclusiveZone: -1
  color: "#010133"

  property string companionImagePath: Icons.imagePath("chowy_front.png")

  property bool isHovered: false

  Widgets.Clock {
    id: clock
    anchors.centerIn: parent
    anchors.verticalCenterOffset: ((root.height / 4) + 15) * -1
  }

  Image {
    id: companionImage
    source: root.companionImagePath
    anchors.margins: 0
    fillMode: Image.FillMode
    opacity: root.isHovered ? 0 : 1
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    anchors.verticalCenterOffset: ((root.height / 6) - 20) * -1
    rotation: -10
  }

  Image {
    id: mountainImg
    anchors.bottom: parent.bottom
    height: root.height - (root.height / 4)
    width: root.width
    source: Icons.imagePath("forest.png")
  }
}
