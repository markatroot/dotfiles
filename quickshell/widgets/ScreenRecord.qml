import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Effects
import "../config"

RowLayout {
  id: recordButton
  implicitWidth: 24
  implicitHeight: 24

  property bool recording: false

  Process {
    id: recordProcess
    command: ["sh", "-c",
        "mkdir -p \"$HOME/Videos/Recordings\" && " +
        "wf-recorder -g \"$(slurp)\" -f \"$HOME/Videos/Recordings/$(date '+%m-%d-%y-%H-%M-%S-%3N').mkv\""
    ]
    onExited: recordButton.recording = false
  }

  Process {
    id: stopProcess
    command: ["pkill", "-INT", "-x", "wf-recorder"]
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (recordButton.recording) {
        stopProcess.running = true
      } else {
        recordButton.recording = true
        recordProcess.running = true
      }
    }
  }

  MultiEffect {
    source: recordImg
    colorization: 1.0
    colorizationColor: recordButton.getColor()
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: recordImg.width
    Layout.preferredHeight: recordImg.height
  }

  Image {
    id: recordImg
    visible: false
    source: Icons.iconPath("disc.svg")
    sourceSize.height: Icons.imgIconHeight - 2
    sourceSize.width: Icons.imgIconWidth - 2
  }

  function getColor() {
    return recordProcess.running ? Fonts.colorDanger : Fonts.colorNormal
  }
}
