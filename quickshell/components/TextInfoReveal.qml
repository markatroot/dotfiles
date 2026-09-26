import QtQuick
import QtQuick.Layouts
import "../config"

Rectangle {
  id: root
  Layout.alignment: Qt.AlignVCenter
  Layout.fillHeight: true

  required property string text

  required property bool show

  property string textColor: Fonts.colorNormal

  Layout.preferredWidth: root.show ? labelText.width : 0
  width: Layout.preferredWidth   // keep width in sync so clip works visually
  height: labelText.height
  clip: true
  color: "transparent"

  Behavior on Layout.preferredWidth {
    NumberAnimation {
      duration: 500
      easing.type: Easing.InOutQuad
    }
  }

  Text {
    anchors.centerIn: parent
    id: labelText
    text: root.text
    color: Fonts.colorNormal
    font.weight: Fonts.black
    font.family: Fonts.mono
    font.pixelSize: Fonts.md
  }
}
