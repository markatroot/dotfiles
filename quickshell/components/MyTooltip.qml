import Quickshell
import QtQuick
import Quickshell.Wayland

PanelWindow {
  id: root

  required property bool show

  required property string text

  required property Item anchorItem

  visible: root.show 

  color: "transparent"

  implicitWidth: tooltipText.implicitWidth
  implicitHeight: tooltipText.implicitHeight

  anchors {
    left: true
    top: true
  }

  margins {
    top: anchorItem.mapToGlobal(0, 0).y
    left: anchorItem.mapToGlobal(0, anchorItem.width).x - screen.width
  }

  Rectangle {
    id: tooltipContent
    anchors.fill: parent
    Text {
      id: tooltipText
      text: root.text
    }
    implicitHeight: tooltipText.height
    implicitWidth: tooltipText.width


  MouseArea {
    anchors.fill: parent
    onEntered: {
      var globalPos = root.anchorItem.mapToGlobal(0, 0)
    }
  }
  }
}
