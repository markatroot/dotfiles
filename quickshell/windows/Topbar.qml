import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
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

  // Frame strip along the top with the pills hanging from it. Pill bottoms
  // are rounded and the joins between strip and pill sides are filleted.
  Shape {
    id: frameShape
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    readonly property real w: width
    readonly property real h: height
    readonly property real t: Theme.frameTop
    readonly property real r: Theme.frameRadius
    readonly property real lw: osPill.x + osPill.width
    readonly property real rx: mainPill.x

    ShapePath {
      fillColor: Theme.frame
      strokeWidth: -1

      startX: 0; startY: 0
      PathLine { x: frameShape.w; y: 0 }
      PathLine { x: frameShape.w; y: frameShape.h }

      // right pill: bottom-left corner, then fillet into the strip
      PathLine { x: frameShape.rx + frameShape.r; y: frameShape.h }
      PathArc {
        x: frameShape.rx; y: frameShape.h - frameShape.r
        radiusX: frameShape.r; radiusY: frameShape.r
      }
      PathLine { x: frameShape.rx; y: frameShape.t + frameShape.r }
      PathArc {
        x: frameShape.rx - frameShape.r; y: frameShape.t
        radiusX: frameShape.r; radiusY: frameShape.r
        direction: PathArc.Counterclockwise
      }

      // left pill: fillet out of the strip, then bottom-right corner
      PathLine { x: frameShape.lw + frameShape.r; y: frameShape.t }
      PathArc {
        x: frameShape.lw; y: frameShape.t + frameShape.r
        radiusX: frameShape.r; radiusY: frameShape.r
        direction: PathArc.Counterclockwise
      }
      PathLine { x: frameShape.lw; y: frameShape.h - frameShape.r }
      PathArc {
        x: frameShape.lw - frameShape.r; y: frameShape.h
        radiusX: frameShape.r; radiusY: frameShape.r
      }
      PathLine { x: 0; y: frameShape.h }
      PathLine { x: 0; y: 0 }
    }
  }

  RowLayout {
    anchors.fill: parent
    spacing: 0

    // OS PILL
    Item {
      id: osPill
      Layout.fillHeight: true
      implicitWidth: osPillRow.implicitWidth + Theme.frameThickness + topbar.pillPadding * 2

      Row {
        id: osPillRow
        anchors {
          left: parent.left
          leftMargin: Theme.frameThickness + topbar.pillPadding
          verticalCenter: parent.verticalCenter
          verticalCenterOffset: Theme.frameTop / 2
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
      implicitWidth: rightSection.implicitWidth + Theme.frameThickness + topbar.pillPadding * 2

      // RIGHT SECTION
      Row {
        id: rightSection
        anchors {
          right: parent.right
          rightMargin: Theme.frameThickness + topbar.pillPadding
          verticalCenter: parent.verticalCenter
          verticalCenterOffset: Theme.frameTop / 2
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
