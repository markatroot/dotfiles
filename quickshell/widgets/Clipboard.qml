import QtQuick
import Quickshell
import QtQuick.Layouts
import "../services"
import "../config"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  property var entries: ClipboardService.entries

  Image {
    id: pasteIcon
    source: Quickshell.iconPath("edit-paste")
    sourceSize.height: Icons.imgIconHeight
    sourceSize.width: Icons.imgIconWidth


    MouseArea {
      anchors.fill: parent
      onClicked: {
        clipboardPopup.visible = !clipboardPopup.visible
      }
    }
  }

  PopupWindow {
    id: clipboardPopup

    anchor.item: pasteIcon
    anchor.edges: Edges.Bottom

    height: popupBackground.height
    width: popupBackground.width

    Keys.onEscapePressed: clipboardPopup.visible = false

    onVisibleChanged: {
      if (clipboardPopup.visible) {
        ClipboardService.loadClipboard()
      } else {
      }
    }

    Rectangle {
      id: popupBackground
      width: 400
      height: 500
      color: "#1e1e2e"
      radius: 10

      border {
        color: "#89b4fa"
        width: 2
        pixelAligned: true
      }

      ListView {
        anchors.fill: parent
        delegate: Rectangle {
          width: parent.width
          height: 40

          Text {
            anchors.centerIn: parent
            text: "sample"
          }
        }
      }
    }
  }

}


