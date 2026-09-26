import Quickshell
import QtQuick
import QtQuick.Layouts
import "../services"
import "../config"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  property var workspaces: NiriService.workspaces

  property real focusedWorkspaceId: NiriService.focusedWorkspaceId

  property var workspaceIcons: ({
    1: '󰎤',
    2: '󰎧',
    3: '󰎪',
    4: '󰎭',
    5: '󰎱',
    6: '󰎳',
    7: '󰎶',
    8: '󰎹',
    9: '󰎼',
  })

  function getWorkspaceIconById(id) {
    return root.workspaceIcons[id]
  }


  function calculateItemOpacity(modelData) {
    if (modelData.is_focused) {
      return 1
    }
    return 0.5
  }

  Row {
    spacing: 8
    visible: Boolean(root.workspaces.length)

    Repeater {
      model: root.workspaces

      // Rectangle {
      //   id: rect
      //
      //   required property var modelData
      //
      //   required property int index
      //
      //   anchors.verticalCenter: parent.verticalCenter
      //
      //   color: "#ed8796"
      //   radius: 5
      //   height: 15
      //   opacity: rect.modelData.id == focusedWorkspaceId ? 1 : 0.5
      //
      //   Text {
      //     id: text
      //     // text: rect.modelData.idx // rect.modelData.id
      //     text: root.getWorkspaceIconById(rect.modelData.idx)
      //     color: "#1e1e2e"
      //   }
      //   implicitHeight: text.height
      //   implicitWidth: 16
      // }

      Text {
        id: workspaceLabel
        required property var modelData

        required property int index

        opacity: workspaceLabel.modelData.id == focusedWorkspaceId ? 1 : 0.7
        // text: rect.modelData.idx // rect.modelData.id
        text: root.getWorkspaceIconById(workspaceLabel.modelData.idx)
        color: Fonts.colorPrimary
        font.weight: Fonts.black
        font.family: Fonts.mono
        font.pixelSize: Fonts.xxl

        MouseArea {
          anchors.fill: parent
          onClicked: () => {
            Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", workspaceLabel.modelData.idx])
          }
        }
      }
    }
  }
}
