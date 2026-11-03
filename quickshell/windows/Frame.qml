import Quickshell
import QtQuick
import QtQuick.Shapes
import Quickshell.Wayland
import "../config"

// Left, right and bottom screen border with rounded inner corners. The top
// edge is drawn by the Topbar; topOffset should match its height.
Scope {
  id: root

  property int topOffset: 0

  // Click-through overlay that draws the border.
  PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell:frame"
    WlrLayershell.exclusiveZone: -1

    Shape {
      id: shape
      anchors.fill: parent
      anchors.topMargin: root.topOffset
      preferredRendererType: Shape.CurveRenderer

      readonly property real w: width
      readonly property real h: height
      readonly property real f: Theme.frameThickness
      readonly property real r: Theme.frameRadius

      ShapePath {
        fillColor: Theme.frame
        strokeWidth: -1
        fillRule: ShapePath.OddEvenFill

        // outer edge
        startX: 0; startY: 0
        PathLine { x: shape.w; y: 0 }
        PathLine { x: shape.w; y: shape.h }
        PathLine { x: 0; y: shape.h }
        PathLine { x: 0; y: 0 }

        // inner rounded hole
        PathMove { x: shape.f + shape.r; y: 0 }
        PathLine { x: shape.w - shape.f - shape.r; y: 0 }
        PathArc { x: shape.w - shape.f; y: shape.r; radiusX: shape.r; radiusY: shape.r }
        PathLine { x: shape.w - shape.f; y: shape.h - shape.f - shape.r }
        PathArc { x: shape.w - shape.f - shape.r; y: shape.h - shape.f; radiusX: shape.r; radiusY: shape.r }
        PathLine { x: shape.f + shape.r; y: shape.h - shape.f }
        PathArc { x: shape.f; y: shape.h - shape.f - shape.r; radiusX: shape.r; radiusY: shape.r }
        PathLine { x: shape.f; y: shape.r }
        PathArc { x: shape.f + shape.r; y: 0; radiusX: shape.r; radiusY: shape.r }
      }
    }
  }

  // Invisible strips that reserve space so windows sit inside the border.
  PanelWindow {
    anchors { left: true; top: true; bottom: true }
    implicitWidth: Theme.frameThickness
    color: "transparent"
    mask: Region {}
    exclusiveZone: Theme.frameThickness
    WlrLayershell.namespace: "quickshell:frame-left"
  }

  PanelWindow {
    anchors { right: true; top: true; bottom: true }
    implicitWidth: Theme.frameThickness
    color: "transparent"
    mask: Region {}
    exclusiveZone: Theme.frameThickness
    WlrLayershell.namespace: "quickshell:frame-right"
  }

  PanelWindow {
    anchors { left: true; right: true; bottom: true }
    implicitHeight: Theme.frameThickness
    color: "transparent"
    mask: Region {}
    exclusiveZone: Theme.frameThickness
    WlrLayershell.namespace: "quickshell:frame-bottom"
  }
}
