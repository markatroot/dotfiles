import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "../config"
import "../widgets" as Widgets

PanelWindow {
  id: topbar

  readonly property int barMargin: 16
  readonly property int osPillHeight: 43
  readonly property int pillHeight: 37
  implicitHeight: osPillHeight
  anchors { top: true; left: true; right: true }
  color: "transparent"
  aboveWindows: true
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "quickshell:topbar"

  RowLayout {
    anchors {
      fill: parent
      topMargin: 5
      leftMargin: 10
      rightMargin: 10
       // topMargin: topbar.barMargin
      // leftMargin: topbar.barMargin + 4
      // rightMargin: topbar.barMargin + 4
    }
    spacing: 16

    // OS PILL
    Rectangle {
      Layout.alignment: Qt.AlignVCenter
      implicitHeight: mainPill.height
      implicitWidth: topbar.osPillHeight
      radius: Theme.radius
      color: Theme.surface
      border.color: Theme.surfaceBorder
      border.width: 1

      Widgets.Os {
        anchors.centerIn: parent
      }
    }

    // MAIN PILL
    Rectangle {
      id: mainPill
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      implicitHeight: parent.height
      radius: Theme.radius
      color: Theme.surface
      border.color: Theme.surfaceBorder
      border.width: 1

      // LEFT SECTION
      Row {
        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
        spacing: 20

        Widgets.Workspaces {
          anchors.verticalCenter: parent.verticalCenter
        }

        Widgets.ActiveWindow {
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      // RIGHT SECTION
      Row {
        anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
        spacing: 24

        // Widgets.ScreenRecord {
        //   anchors.verticalCenter: parent.verticalCenter
        // }

        Widgets.SystemResources {
          anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          implicitWidth: 1
          implicitHeight: parent.height
          color: Theme.surfaceBorder
        }

        Widgets.Clipboard {
          id: clipboard
          anchors.verticalCenter: parent.verticalCenter
        }

        Widgets.Volume {
          anchors.verticalCenter: parent.verticalCenter
        }

        Widgets.Network {
          anchors.verticalCenter: parent.verticalCenter
        }

        Widgets.Battery {
          anchors.verticalCenter: parent.verticalCenter
        }

        Widgets.SystemTray {
          anchors.verticalCenter: parent.verticalCenter
        }

        // Widgets.Clock {
        //   anchors.verticalCenter: parent.verticalCenter
        // }
      }
    }
  }
}
