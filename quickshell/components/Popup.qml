import QtQuick
import QtQuick.Controls

Popup {
  id: root

  property string text: " "

  height: messageText.height + 5
  width: messageText.width + 10
  anchors.centerIn: parent

  visible: true
  modal: true
  popupType: Popup.Window
  topMargin: 40

  Row {
    Text {
      id: messageText
      text: root.text
      color: "red"
      font {
        weight: 600
        family: "SFMono Nerd Font"
        pixelSize: 14
      }
    }
  }
}
