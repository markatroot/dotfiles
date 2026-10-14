import QtQuick
import QtQuick.Layouts
import Quickshell
import "../config"
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
// Right click opens its (themed) context menu if it has one, otherwise sends
// the secondary activate signal.

RowLayout {
    id: root
    spacing: 8

    property int iconSize: 18
    property color tooltipBg: Theme.bg
    property color tooltipFg: Theme.fg

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
                            menu.toggle()
                        } else {
                            trayItem.modelData.secondaryActivate()
                        }
                    }
                }
            }

            // Context menu, drawn by us (instead of QsMenuAnchor's native
            // Qt menu) so it follows Theme. Submenus open in place, with a
            // "back" row at the top.
            PopupWindow {
                id: menu

                property var stack: []

                function toggle() {
                    if (visible) {
                        visible = false
                    } else {
                        stack = [trayItem.modelData.menu]
                        visible = true
                    }
                }

                onVisibleChanged: if (!visible) stack = []

                anchor.item: trayItem
                anchor.rect.y: trayItem.height + 6
                anchor.edges: Edges.Top | Edges.Left
                anchor.gravity: Edges.Bottom | Edges.Right
                grabFocus: true

                color: "transparent"
                implicitWidth: menuBody.implicitWidth
                implicitHeight: menuBody.implicitHeight

                QsMenuOpener {
                    id: opener
                    menu: menu.stack.length ? menu.stack[menu.stack.length - 1] : null
                }

                Rectangle {
                    id: menuBody
                    anchors.fill: parent
                    implicitWidth: Math.max(160, menuColumn.implicitWidth + 8)
                    implicitHeight: menuColumn.implicitHeight + 8
                    color: Theme.bg
                    radius: 6
                    border.width: 1
                    border.color: Theme.selection

                    ColumnLayout {
                        id: menuColumn
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 0

                        TrayMenuRow {
                            visible: menu.stack.length > 1
                            label: "Back"
                            leading: "\u2039"
                            onClicked: menu.stack = menu.stack.slice(0, -1)
                        }

                        Rectangle {
                            visible: menu.stack.length > 1
                            Layout.fillWidth: true
                            Layout.margins: 4
                            implicitHeight: 1
                            color: Theme.selection
                        }

                        Repeater {
                            model: opener.children

                            delegate: Loader {
                                id: entryLoader
                                required property QsMenuEntry modelData
                                Layout.fillWidth: true
                                sourceComponent: modelData.isSeparator ? separator : row

                                Component {
                                    id: separator
                                    Item {
                                        implicitHeight: 9
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: parent.width - 8
                                            height: 1
                                            color: Theme.selection
                                        }
                                    }
                                }

                                Component {
                                    id: row
                                    TrayMenuRow {
                                        readonly property QsMenuEntry entry: entryLoader.modelData
                                        label: entry.text
                                        iconSource: entry.icon
                                        enabled: entry.enabled
                                        leading: entry.buttonType === QsMenuButtonType.CheckBox
                                            ? (entry.checkState === Qt.Checked ? "\u2611" : "\u2610")
                                            : entry.buttonType === QsMenuButtonType.RadioButton
                                            ? (entry.checkState === Qt.Checked ? "\u25c9" : "\u25cb")
                                            : ""
                                        trailing: entry.hasChildren ? "\u203a" : ""
                                        onClicked: {
                                            if (entry.hasChildren) {
                                                menu.stack = menu.stack.concat([entry])
                                            } else {
                                                entry.triggered()
                                                menu.visible = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Hover tooltip, rendered as its own floating popup surface.
            // (An inline Rectangle would get clipped to the bar's own
            // layer-shell surface bounds — a separate PopupWindow isn't.)
            PopupWindow {
                id: tooltip
                visible: mouseArea.containsMouse && !menu.visible && tooltipText.text !== ""

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
                    border.color: Theme.selection

                    Text {
                        id: tooltipText
                        anchors.centerIn: parent
                        text: trayItem.modelData.tooltipTitle || trayItem.modelData.title || ""
                        color: root.tooltipFg
                        font.family: Fonts.mono
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
