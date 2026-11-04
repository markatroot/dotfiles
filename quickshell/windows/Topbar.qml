import Quickshell
import QtQuick
import QtQuick.Shapes
import Quickshell.Wayland
import "../config"
import "../widgets" as Widgets

PanelWindow {
  id: topbar

  readonly property int barHeight: 44
  readonly property int pillPadding: 18

  // Hover-expanded main pill: details slide down from the frame strip and the
  // right-side items ride down to the bottom of the pill.
  readonly property int detailsSidePadding: 30
  readonly property int detailsTopPadding: 34
  readonly property int detailsBottomPadding: 22
  readonly property int detailsWidth: 568
  readonly property real detailsHeight: details.implicitHeight + detailsTopPadding + detailsBottomPadding
  property bool expanded: false

  // The window is tall enough for the expanded pill, but only reserves the
  // bar's height; the mask keeps the empty area click-through.
  implicitHeight: barHeight + Math.ceil(detailsHeight)
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: barHeight
  anchors { top: true; left: true; right: true }
  color: "transparent"
  aboveWindows: true
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "quickshell:topbar"

  mask: Region {
    item: strip
    Region { item: osPill }
    Region { item: mainPill }
  }

  Item {
    id: strip
    anchors { top: parent.top; left: parent.left; right: parent.right }
    height: Theme.frameTop
  }

  // Frame strip along the top with the pills hanging from it. Pill bottoms
  // are rounded and the joins between strip and pill sides are filleted.
  Shape {
    id: frameShape
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    readonly property real w: width
    readonly property real t: Theme.frameTop
    readonly property real r: Theme.frameRadius
    readonly property real lw: osPill.x + osPill.width
    readonly property real lb: osPill.height
    readonly property real rx: mainPill.x
    readonly property real rb: mainPill.height

    ShapePath {
      fillColor: Theme.frame
      strokeWidth: -1

      startX: 0; startY: 0
      PathLine { x: frameShape.w; y: 0 }
      PathLine { x: frameShape.w; y: frameShape.rb }

      // right pill: bottom-left corner, then fillet into the strip
      PathLine { x: frameShape.rx + frameShape.r; y: frameShape.rb }
      PathArc {
        x: frameShape.rx; y: frameShape.rb - frameShape.r
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
      PathLine { x: frameShape.lw; y: frameShape.lb - frameShape.r }
      PathArc {
        x: frameShape.lw - frameShape.r; y: frameShape.lb
        radiusX: frameShape.r; radiusY: frameShape.r
      }
      PathLine { x: 0; y: frameShape.lb }
      PathLine { x: 0; y: 0 }
    }
  }

  // OS PILL
  Item {
    id: osPill
    anchors { top: parent.top; left: parent.left }
    height: topbar.barHeight
    width: osPillRow.implicitWidth + Theme.frameThickness + topbar.pillPadding * 2

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

  // MAIN PILL
  Item {
    id: mainPill
    anchors { top: parent.top; right: parent.right }

    readonly property real collapsedWidth: rightSection.collapsedWidth + Theme.frameThickness + topbar.pillPadding * 2
    readonly property real expandedWidth: Math.max(collapsedWidth, topbar.detailsWidth + Theme.frameThickness + topbar.detailsSidePadding * 2)

    width: topbar.expanded ? expandedWidth : collapsedWidth
    height: topbar.barHeight + (topbar.expanded ? topbar.detailsHeight : 0)

    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

    // Keep the pill open while the pointer is on it, or a tray menu hangs off
    // it; close it when the clipboard overlay takes over.
    readonly property bool wantOpen: (hover.hovered || tray.openMenus > 0) && !clipboard.popupOpen

    onWantOpenChanged: {
      if (wantOpen) {
        closeTimer.stop()
        if (!topbar.expanded) openTimer.restart()
      } else {
        openTimer.stop()
        if (topbar.expanded) closeTimer.restart()
      }
    }

    HoverHandler { id: hover }

    Timer {
      id: openTimer
      interval: 150
      onTriggered: topbar.expanded = true
    }

    Timer {
      id: closeTimer
      interval: 300
      onTriggered: topbar.expanded = false
    }

    // DETAILS: content is pinned to the bottom of a clipped area that grows
    // with the pill, so it slides down from behind the frame strip.
    Item {
      id: detailsArea
      anchors {
        top: parent.top
        topMargin: Theme.frameTop
        left: parent.left
        right: parent.right
        rightMargin: Theme.frameThickness
        bottom: itemsArea.top
      }
      clip: true

      Widgets.TopbarDetails {
        id: details
        anchors {
          bottom: parent.bottom
          bottomMargin: topbar.detailsBottomPadding
          horizontalCenter: parent.horizontalCenter
        }
        width: topbar.detailsWidth
        opacity: topbar.expanded ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
      }
    }

    // Divider between the details and the items row
    Rectangle {
      anchors {
        left: parent.left
        right: parent.right
        rightMargin: Theme.frameThickness
        bottom: itemsArea.top
      }
      height: 1
      color: Theme.surfaceBorder
      opacity: topbar.expanded ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // RIGHT SECTION: always sits in the bottom bar-height slice of the pill
    Item {
      id: itemsArea
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      height: topbar.barHeight - Theme.frameTop

      Row {
        id: rightSection

        readonly property int baseSpacing: 24
        property real sidePadding: topbar.expanded ? topbar.detailsSidePadding : topbar.pillPadding

        // Positioners skip hidden and zero-size items, so only count the rest
        readonly property var laidOut: {
          let width = 0, count = 0
          for (const child of children) {
            if (child.visible && child.width > 0 && child.height > 0) {
              width += child.width
              count++
            }
          }
          return { width, count }
        }
        readonly property real collapsedWidth: laidOut.width + baseSpacing * Math.max(0, laidOut.count - 1)

        anchors {
          right: parent.right
          rightMargin: Theme.frameThickness + sidePadding
          verticalCenter: parent.verticalCenter
        }

        // Spread across the pill when expanded
        spacing: topbar.expanded && laidOut.count > 1
          ? Math.max(baseSpacing, (mainPill.expandedWidth - Theme.frameThickness - topbar.detailsSidePadding * 2 - laidOut.width) / (laidOut.count - 1))
          : baseSpacing

        Behavior on spacing { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on sidePadding { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

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
          id: tray
          anchors.verticalCenter: parent.verticalCenter
        }

        // Widgets.Clock {
        //   anchors.verticalCenter: parent.verticalCenter
        // }
      }
    }
  }
}
