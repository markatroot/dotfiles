import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "../widgets" as Widgets

PanelWindow {
  id: topbar
  implicitHeight: 50
  anchors { top: true; left: true; right: true }
  color: "transparent"
  aboveWindows: true
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "quickshell:topbar"

  RowLayout {
    anchors.fill: parent
    spacing: 0

    // LEFT SECTION
    Row {
      spacing: 20
      leftPadding: 20
      Layout.fillHeight: true

      Widgets.Workspaces {
        anchors.verticalCenter: parent.verticalCenter
      }

      Widgets.ActiveWindow {
        anchors.verticalCenter: parent.verticalCenter
      }

      // Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

    }

    // FLEX SPACE
    Item { Layout.fillWidth: true }

    // RIGHT SECTION
    Row {
      spacing: 30
      rightPadding: 20

      // Widgets.ScreenRecord {
      //   anchors.verticalCenter: parent.verticalCenter
      // }

      Widgets.SystemResources {
        anchors.verticalCenter: parent.verticalCenter
      }

      // Widgets.Clipboard {
      //   anchors.verticalCenter: parent.verticalCenter
      // }

      Widgets.Volume {
        anchors.verticalCenter: parent.verticalCenter
      }

      Widgets.Network {
        anchors.verticalCenter: parent.verticalCenter
      }

      Widgets.Battery {
        anchors.verticalCenter: parent.verticalCenter
      }

      // Widgets.SystemTray {
      //   anchors.verticalCenter: parent.verticalCenter
      // }

      // Widgets.Clock {
      //   anchors.verticalCenter: parent.verticalCenter
      // }

    }
  }
}

