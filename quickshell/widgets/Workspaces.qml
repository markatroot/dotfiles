import Quickshell
import QtQuick
import QtQuick.Layouts
import "../services"
import "../config"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  property var workspaces: UmbrielService.workspaces

  property string focusedWorkspaceId: UmbrielService.focusedWorkspaceId

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
    if (modelData.focused) {
      return 1
    }
    return 0.5
  }

  Row {
    spacing: 6
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

      Rectangle {
        id: workspacePill
        required property var modelData

        required property int index

        readonly property bool focused: workspacePill.modelData.id == root.focusedWorkspaceId

        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: 20
        implicitWidth: Math.max(implicitHeight + 10, workspaceLabel.implicitWidth + 16)
        radius: Theme.radius
        color: workspacePill.focused
          ? Theme.magenta
          : workspaceHover.containsMouse ? Theme.selection : "transparent"

        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
          id: workspaceLabel
          anchors.centerIn: parent
          text: workspacePill.modelData.index
          color: workspacePill.focused ? Theme.bg : Theme.fg
          opacity: workspacePill.focused ? 1 : 0.6
          font.weight: Fonts.medium
          font.family: Fonts.mono
          font.pixelSize: Fonts.md
        }

        MouseArea {
          id: workspaceHover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: () => {
            UmbrielService.focusWorkspace(workspacePill.modelData)
          }
        }
      }
    }
  }
}
