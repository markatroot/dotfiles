import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "../config"
import "../widgets" as Widgets

PanelWindow {
  id: topbar

  readonly property int barHeight: 44
  readonly property int pillPadding: 18
  implicitHeight: barHeight
  anchors { top: true; left: true; right: true }
  color: "transparent"
  aboveWindows: true
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "quickshell:topbar"

  // Full-width bar with square edges.
  Rectangle {
    anchors.fill: parent
    color: Theme.frame
  }

  RowLayout {
    anchors.fill: parent
    spacing: 0

    // OS PILL
    Item {
      id: osPill
      Layout.fillHeight: true
      implicitWidth: osPillRow.implicitWidth + topbar.pillPadding * 2

      Row {
        id: osPillRow
        anchors {
          left: parent.left
          leftMargin: topbar.pillPadding
          verticalCenter: parent.verticalCenter
        }
        spacing: 20

        Widgets.Os {
          anchors.verticalCenter: parent.verticalCenter
        }

        Widgets.Workspaces {
          anchors.verticalCenter: parent.verticalCenter
        }

        Widgets.ActiveWindow {
          anchors.verticalCenter: parent.verticalCenter
        }
      }
    }

    Item { Layout.fillWidth: true }

    // MAIN PILL
    Item {
      id: mainPill
      Layout.fillHeight: true
      implicitWidth: rightSection.implicitWidth + topbar.pillPadding * 2

      // RIGHT SECTION
      Row {
        id: rightSection
        anchors {
          right: parent.right
          rightMargin: topbar.pillPadding
          verticalCenter: parent.verticalCenter
        }
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
