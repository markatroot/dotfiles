// Quickshell application launcher
// Place at: ~/.config/quickshell/launcher/shell.qml
// Run with: qs -c launcher
// Toggle:   qs -c launcher ipc call launcher toggle

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

ShellRoot {
    id: root

    property bool shown: false

    // ---- Theme -------------------------------------------------------------
    readonly property color cBackdrop:  "#99101624"
    readonly property color cSurface:   "#1b2233"
    readonly property color cField:     "#232c42"
    readonly property color cHighlight: "#3a4a78"
    readonly property color cText:      "#e6e9f2"
    readonly property color cSubtext:   "#8f98b3"
    readonly property color cAccent:    "#8fa8ff"
    readonly property int   maxResults: 8

    // ---- IPC: bind a key to `qs -c launcher ipc call launcher toggle` ----
    IpcHandler {
        target: "launcher"
        function toggle(): void { root.shown = !root.shown }
        function show(): void   { root.shown = true }
        function hide(): void   { root.shown = false }
    }

    // ---- Search / ranking --------------------------------------------------
    function rank(entry, q) {
        const name = (entry.name || "").toLowerCase();
        if (name === q) return 100;
        if (name.startsWith(q)) return 80;
        if (name.split(/[\s\-_]+/).some(w => w.startsWith(q))) return 60;
        if (name.includes(q)) return 40;

        const extra = [
            entry.genericName || "",
            entry.comment || "",
            (entry.keywords || []).join(" "),
        ].join(" ").toLowerCase();
        if (extra.includes(q)) return 20;

        // Loose subsequence match, e.g. "ffx" -> "firefox"
        let i = 0;
        for (const ch of name) if (ch === q[i]) i++;
        return i === q.length ? 10 : 0;
    }

    function filterApps(query) {
        const q = query.trim().toLowerCase();
        const apps = [...DesktopEntries.applications.values].filter(a => !a.noDisplay);

        if (q.length === 0)
            return apps.sort((a, b) => a.name.localeCompare(b.name));

        return apps
            .map(a => ({ app: a, score: rank(a, q) }))
            .filter(r => r.score > 0)
            .sort((a, b) => b.score - a.score || a.app.name.localeCompare(b.app.name))
            .map(r => r.app);
    }

    function launch(entry) {
        if (!entry) return;
        entry.execute();
        root.shown = false;
    }

    // ---- Window ------------------------------------------------------------
    PanelWindow {
        id: win
        visible: root.shown
        color: "transparent"

        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.namespace: "quickshell-launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive
                                                : WlrKeyboardFocus.None

        onVisibleChanged: {
            if (visible) {
                search.text = "";
                list.currentIndex = 0;
                search.forceActiveFocus();
            }
        }

        // Dim backdrop; click outside to close
        Rectangle {
            anchors.fill: parent
            color: root.cBackdrop
            MouseArea {
                anchors.fill: parent
                onClicked: root.shown = false
            }
        }

        Rectangle {
            id: panel
            width: 560
            height: column.implicitHeight + 24
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.22
            radius: 14
            color: root.cSurface
            border.color: Qt.rgba(1, 1, 1, 0.06)

            // Swallow clicks so they don't close the launcher
            MouseArea { anchors.fill: parent }

            ColumnLayout {
                id: column
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                spacing: 8

                TextField {
                    id: search
                    Layout.fillWidth: true
                    placeholderText: "Search apps"
                    placeholderTextColor: root.cSubtext
                    color: root.cText
                    font.pixelSize: 18
                    leftPadding: 14
                    topPadding: 12
                    bottomPadding: 12
                    background: Rectangle {
                        radius: 10
                        color: root.cField
                        border.width: search.activeFocus ? 1 : 0
                        border.color: root.cAccent
                    }

                    onTextChanged: list.currentIndex = 0

                    Keys.onPressed: event => {
                        switch (event.key) {
                        case Qt.Key_Escape:
                            root.shown = false; break;
                        case Qt.Key_Down:
                        case Qt.Key_Tab:
                            list.incrementCurrentIndex(); break;
                        case Qt.Key_Up:
                        case Qt.Key_Backtab:
                            list.decrementCurrentIndex(); break;
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            root.launch(list.model[list.currentIndex]); break;
                        default:
                            return;
                        }
                        event.accepted = true;
                    }
                }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(count, root.maxResults) * 52
                    clip: true
                    spacing: 2
                    keyNavigationWraps: true
                    highlightMoveDuration: 80
                    boundsBehavior: Flickable.StopAtBounds

                    model: root.filterApps(search.text)

                    highlight: Rectangle { radius: 8; color: root.cHighlight }

                    delegate: Item {
                        id: row
                        required property var modelData
                        required property int index
                        width: ListView.view.width
                        height: 50

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: list.currentIndex = row.index
                            onClicked: root.launch(row.modelData)
                        }

                        RowLayout {
                            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                            spacing: 12

                            IconImage {
                                implicitSize: 32
                                source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text {
                                    Layout.fillWidth: true
                                    text: row.modelData.name
                                    color: root.cText
                                    font.pixelSize: 15
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    visible: text.length > 0
                                    text: row.modelData.comment || row.modelData.genericName || ""
                                    color: root.cSubtext
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 4
                    visible: list.count === 0
                    horizontalAlignment: Text.AlignHCenter
                    text: "No apps match \"" + search.text + "\""
                    color: root.cSubtext
                    font.pixelSize: 13
                }
            }
        }
    }
}
