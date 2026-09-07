import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Hyprland


RowLayout {

  id: root

  spacing: 10
  Layout.fillHeight: true

  Repeater {
    model: 10

    Rectangle {
      id: workspaceIndicator

      bottomLeftRadius: 5
      bottomRightRadius: 5
      topLeftRadius: 5
      topRightRadius: 5

      required property int index

      property var workspace: Hyprland.workspaces.values.find(w => w.id === index + 1)
      property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

      Behavior on opacity {
        NumberAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }

      // Behavior on Layout.preferredWidth {
      //   NumberAnimation {
      //     duration: 200
      //     easing.type: Easing.InBounce
      //   }
      // }
      
      MouseArea {
        anchors.fill: parent
        onClicked: {
          Hyprland.dispatch("workspace " + (index + 1))
        }
      }

      border.color: "#ed8796"
      color: "#ed8796"

      opacity: isActive ? 1 : (workspace ? .7 : .4)

      Layout.preferredWidth: isActive ? 30 : 20

      height: 18

      // Text {
      //   anchors.fill: parent
      //   text: workspaceIndicator.index + 1
      //   color: "#1e1e2e"
      //   verticalAlignment: Text.AlignVCenter
      //   horizontalAlignment: Text.AlignHCenter
      //   font.pixelSize: 16
      //   font.bold: true
      //   font.family: "SFMono Nerd Font"
      // }

    }
  }

}
