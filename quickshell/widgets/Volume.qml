import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire // Import the PipeWire service
import Quickshell
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

  readonly property string icon: Icons.volume(volume, muted)

  HoverReveal { id: reveal }

  TextInfoReveal {
    show: reveal.active
    text: `${root.volume} %`
    opacity: root.muted ? 0.5 : 1
  }

  MultiEffect {
    source: volumeIcon
    colorization: 1.0
    colorizationColor: Theme.fg
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: volumeIcon.width
    Layout.preferredHeight: volumeIcon.height
    TapHandler {
      onTapped: {
        if (root.sink?.audio) {
          root.sink.audio.muted = !root.sink.audio.muted
        }
      }
    }
  }

  Image {
    id: volumeIcon
    visible: false
    verticalAlignment: Text.AlignVCenter
    source: root.icon
    sourceSize.height: Icons.imgIconHeight
    sourceSize.width: Icons.imgIconWidth
  }

  PwObjectTracker {
    objects: [root.sink]
  }

  onVolumeChanged: reveal.poke()

  onMutedChanged: reveal.poke()
}
