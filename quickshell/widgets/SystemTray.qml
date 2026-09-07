import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

// Minimal Quickshell system tray widget.
//
// This is a RowLayout, meant to be embedded directly inside your bar's
// row of widgets (next to your clock, workspaces, etc), e.g.:
//
//   RowLayout {
//       Clock {}
//       Workspaces {}
//       SystemTray {}
//   }
//
// Left click activates the item (e.g. opens the app).
// Right click opens its context menu if it has one, otherwise sends
// the secondary activate signal.

RowLayout {
    id: root
    spacing: 8

    property int iconSize: 18
    property color tooltipBg: "#1e1e2e"
    property color tooltipFg: "#cdd6f4"

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem
            required property SystemTrayItem modelData

            implicitWidth: root.iconSize
            implicitHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: icon
                anchors.fill: parent
                source: trayItem.modelData.icon
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: trayItem.modelData.menu
                anchor.item: trayItem
                anchor.window: trayItem.Window.window
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        trayItem.modelData.activate()
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayItem.modelData.hasMenu) {
                            menuAnchor.open()
                        } else {
                            trayItem.modelData.secondaryActivate()
                        }
                    }
                }
            }

            // Hover tooltip, rendered as its own floating popup surface.
            // (An inline Rectangle would get clipped to the bar's own
            // layer-shell surface bounds — a separate PopupWindow isn't.)
            PopupWindow {
                id: tooltip
                visible: mouseArea.containsMouse && tooltipText.text !== ""

                anchor.item: trayItem
                anchor.rect.x: 0
                anchor.rect.y: trayItem.height
                anchor.edges: Edges.Top | Edges.Left
                anchor.gravity: Edges.Bottom | Edges.Right

                color: "transparent"
                implicitWidth: tooltipText.implicitWidth + 16
                implicitHeight: tooltipText.implicitHeight + 10

                Rectangle {
                    anchors.fill: parent
                    color: root.tooltipBg
                    radius: 6
                    border.width: 1
                    border.color: "#313244"

                    Text {
                        id: tooltipText
                        anchors.centerIn: parent
                        text: trayItem.modelData.tooltipTitle || trayItem.modelData.title || ""
                        color: root.tooltipFg
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
