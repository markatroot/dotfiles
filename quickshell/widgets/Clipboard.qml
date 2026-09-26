import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../services"
import "../config"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  // OneDark palette
  readonly property color cBg: Theme.bg
  readonly property color cBgAlt: Theme.bgAlt
  readonly property color cSurface: Qt.lighter(Theme.bg, 1.1)
  readonly property color cHighlight: Theme.selection
  readonly property color cFg: Theme.fg
  readonly property color cComment: Theme.brightBlack
  readonly property color cBlue: Theme.blue
  readonly property color cRed: Theme.red

  readonly property int maxVisibleItems: 15
  readonly property int rowHeight: 34

  property string query: ""
  readonly property bool popupOpen: clipboardPopup.visible

  // Bind a key to `qs ipc call clipboard toggle`
  IpcHandler {
    target: "clipboard"
    function toggle(): void { clipboardPopup.visible = !clipboardPopup.visible }
    function show(): void { clipboardPopup.visible = true }
    function hide(): void { clipboardPopup.visible = false }
    function isOpen(): bool { return clipboardPopup.visible }
  }

  function applyQuery() {
    searchDebounce.stop()
    root.query = search.text
    list.currentIndex = 0
    list.positionViewAtBeginning()
  }
  property var entries: ClipboardService.filter(query)

  MultiEffect {
    id: clipboardIcon
    // anchors.fill: wifiIcon
    source: iconImage
    colorization: 1.0
    colorizationColor: Fonts.colorNormal
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: iconImage.width
    Layout.preferredHeight: iconImage.height

    MouseArea {
      id: iconHover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: clipboardPopup.visible = !clipboardPopup.visible
    }
  }

  Image {
    id: iconImage
    visible: false
    source: Icons.iconPath("clipboard.svg")
    sourceSize.height: Icons.imgIconHeight - 4
    sourceSize.width: Icons.imgIconWidth - 4
  }

  // Layer-shell overlay instead of PopupWindow: xdg_popup grabs need an input
  // serial on the bar, which an IPC-triggered open (Mod+C) never has
  PanelWindow {
    id: clipboardPopup
    visible: false

    anchors { top: true; right: true }
    margins { top: 8; right: 12 }
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:clipboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    implicitWidth: popupBackground.width
    implicitHeight: popupBackground.height
    color: "transparent"

    onVisibleChanged: {
      if (visible) {
        search.text = ""
        root.query = ""
        list.currentIndex = 0
        list.positionViewAtBeginning()
        search.forceActiveFocus()
        ClipboardService.loadClipboard()
      }
    }

    // Debounce filtering while typing
    Timer {
      id: searchDebounce
      interval: 120
      onTriggered: root.applyQuery()
    }

    Rectangle {
      id: popupBackground
      width: 500
      height: header.height + search.height + listContainer.height + 32
      color: root.cBg
      radius: 10
      border.color: root.cHighlight
      border.width: 1

      // Header
      RowLayout {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
        height: 24

        Text {
          text: "Clipboard"
          color: root.cBlue
          font { family: Fonts.mono; pixelSize: Fonts.xl; weight: Fonts.bold }
        }

        Text {
          text: ClipboardService.loading ? "…" : root.query.length > 0
            ? `${root.entries.length}/${ClipboardService.entries.length}`
            : `${root.entries.length}`
          color: root.cComment
          font { family: Fonts.mono; pixelSize: Fonts.md }
        }

        Item { Layout.fillWidth: true }

        Text {
          visible: ClipboardService.entries.length > 0
          text: "Clear"
          color: clearHover.containsMouse ? root.cRed : root.cComment
          font { family: Fonts.mono; pixelSize: Fonts.md }

          MouseArea {
            id: clearHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ClipboardService.wipe()
          }
        }
      }

      // Search
      TextField {
        id: search
        anchors { top: header.bottom; left: parent.left; right: parent.right; margins: 12; topMargin: 8 }
        placeholderText: "Search clipboard"
        placeholderTextColor: root.cComment
        color: root.cFg
        font { family: Fonts.mono; pixelSize: Fonts.md }
        leftPadding: 10
        topPadding: 6
        bottomPadding: 6
        background: Rectangle {
          radius: 6
          color: root.cBgAlt
          border.width: 1
          border.color: search.activeFocus ? root.cBlue : root.cHighlight
        }

        onTextChanged: searchDebounce.restart()

        Keys.onPressed: event => {
          switch (event.key) {
          case Qt.Key_Escape:
            clipboardPopup.visible = false; break
          case Qt.Key_Down:
          case Qt.Key_Tab:
            list.incrementCurrentIndex(); break
          case Qt.Key_Up:
          case Qt.Key_Backtab:
            list.decrementCurrentIndex(); break
          case Qt.Key_Return:
          case Qt.Key_Enter: {
            // Apply any pending query before picking
            if (searchDebounce.running) root.applyQuery()
            const entry = root.entries[list.currentIndex]
            if (entry) {
              ClipboardService.copy(entry.id)
              clipboardPopup.visible = false
            }
            break
          }
          default:
            return
          }
          event.accepted = true
        }
      }

      // List
      Rectangle {
        id: listContainer
        anchors { top: search.bottom; left: parent.left; right: parent.right; margins: 12; topMargin: 8 }
        height: root.entries.length === 0
          ? root.rowHeight * 2
          : Math.min(root.entries.length, root.maxVisibleItems) * root.rowHeight
        color: root.cBgAlt
        radius: 6
        clip: true

        Text {
          anchors.centerIn: parent
          visible: root.entries.length === 0
          text: ClipboardService.loading ? "Loading…"
            : root.query.length > 0 ? "No matches" : "Clipboard is empty"
          color: root.cComment
          font { family: Fonts.mono; pixelSize: Fonts.sm; italic: true }
        }

        ListView {
          id: list
          anchors.fill: parent
          model: root.entries
          boundsBehavior: Flickable.StopAtBounds
          keyNavigationWraps: true
          ScrollBar.vertical: ScrollBar {
            policy: root.entries.length > root.maxVisibleItems ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
          }

          delegate: Rectangle {
            id: row
            required property var modelData
            required property int index

            width: ListView.view.width
            height: root.rowHeight
            readonly property bool active: ListView.isCurrentItem
            color: active ? root.cHighlight : (index % 2 === 0 ? root.cBgAlt : root.cSurface)

            RowLayout {
              anchors { fill: parent; leftMargin: 0; rightMargin: 0 }
              spacing: 10

              Text {
                text: `${row.index + 1}`
                color: row.active ? root.cBlue : root.cComment
                Layout.preferredWidth: 22
                horizontalAlignment: Text.AlignRight
                font { family: Fonts.mono; pixelSize: Fonts.md }
              }

              Text {
                Layout.fillWidth: true
                text: row.modelData.text
                color: root.cFg
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
                font { family: Fonts.mono; pixelSize: Fonts.lg }
              }
            }

            MouseArea {
              id: rowHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: list.currentIndex = row.index
              onClicked: {
                ClipboardService.copy(row.modelData.id)
                clipboardPopup.visible = false
              }
            }
          }
        }
      }
    }
  }
}
