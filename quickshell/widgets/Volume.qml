import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire // Import the PipeWire service
import Quickshell
import QtQuick.Controls
import QtQuick.Effects
import "../config"
import "../components"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  property var sink: Pipewire.defaultAudioSink

  readonly property bool ready: sink && sink.ready
  readonly property bool muted: ready && sink.audio.muted
  readonly property int volume: ready ? Math.round(sink.audio.volume * 100) : 0

  function getVolumeIcon(volumeLevel, isMuted) {
    if (isMuted || volumeLevel === 0)
      return "volume-x.svg";

    if (volumeLevel <= 33)
      return "volume.svg";

    if (volumeLevel <= 66)
      return "volume-1.svg";

    if (volumeLevel <= 100)
      return "volume-2.svg";
    return "volume-off.svg";
  }

  readonly property string icon: {
    return `${Quickshell.shellDir}/icons/${getVolumeIcon(volume, muted)}`
  }

  TextInfoReveal {
    show: volumeHover.containsMouse
    text: `${root.volume} %`
    opacity: root.muted ? 0.5 : 1
  }

  MultiEffect {
    source: volumeIcon
    colorization: 1.0
    colorizationColor: Fonts.colorNormal
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: volumeIcon.width
    Layout.preferredHeight: volumeIcon.height
  }

  MouseArea {
    id: volumeHover
    anchors.fill: parent
    hoverEnabled: true // Required to detect hover without clicking
  }

  Image {
    id: volumeIcon
    visible: false
    verticalAlignment: Text.AlignVCenter
    source: Quickshell.iconPath(root.icon)
    sourceSize.height: Icons.imgIconHeight - 2
    sourceSize.width: Icons.imgIconWidth - 2
  }

  PwObjectTracker {
    objects: [root.sink]
  }

}

