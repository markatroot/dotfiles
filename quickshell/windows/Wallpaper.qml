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
  color: Theme.bg

  property string companionImagePath: Icons.wallpaperCompanion

  property bool isHovered: false

  // Layered wallpaper: sky (back) -> clock -> mountains (front)
  Image {
    id: skyImg
    anchors.fill: parent
    fillMode: Image.PreserveAspectCrop
    source: Icons.wallpaperSky
  }

  Widgets.Clock {
    id: clock
    anchors.centerIn: parent
    anchors.verticalCenterOffset: (clock.height * -1) + 50 // ((root.height / 4) - 200) * -1
  }

  // Image {
  //   id: companionImage
  //   source: root.companionImagePath
  //   anchors.margins: 0
  //   fillMode: Image.FillMode
  //   opacity: root.isHovered ? 0 : 1
  //   anchors.verticalCenter: parent.verticalCenter
  //   anchors.right: parent.right
  //   anchors.verticalCenterOffset: ((root.height / 6) - 140) * -1
  //   rotation: -10
  // }

  Image {
    id: mountainImg
    anchors.fill: parent
    fillMode: Image.PreserveAspectCrop
    source: Icons.wallpaperMountains
  }
}
