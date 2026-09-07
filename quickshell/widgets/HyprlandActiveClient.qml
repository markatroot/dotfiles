import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Row {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

  property string activeAppTitle: ""

  Connections {
    target: Hyprland
    // Listen to all events from socket2
    function onRawEvent(event) {
      if (event.name == "activewindow") {
        let arr = event.data.split(',')
        let hasActiveWindow = !!arr[0]
        activeWindowAppRect.visible = hasActiveWindow
        activeWindowText.visible = hasActiveWindow
        if (hasActiveWindow) {
          activeWindowApp.text = " " + arr.shift()?.toUpperCase()
          activeWindowText.text = " " + arr?.join('')
        }
      }
    }
  }

  Rectangle {
    id: activeWindowAppRect
    color: "#ed8796"
    radius: 5

    implicitWidth: activeWindowApp.width + 6
    implicitHeight: activeWindowApp.height

    Text {
      id: activeWindowApp
      verticalAlignment: Text.AlignVCenter
      property var activeWindow: HyprlandToplevel.title
      Layout.fillHeight: true
      color: "#1e1e2e"
      font.pixelSize: 16
      font.family: "SFMono Nerd Font"
      elide: Text.ElideRight
      font.bold: true
    }
  }

  Text {
    id: activeWindowText
    verticalAlignment: Text.AlignVCenter
    property var activeWindow: HyprlandToplevel.title
    Layout.fillHeight: true
    color: "#ffffff"
    font.pixelSize: 16
    font.family: "SFMono Nerd Font"
    elide: Text.ElideRight
  }
}
