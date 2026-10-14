import QtQuick

// Attach to a widget to reveal info while hovered, or briefly after poke()
HoverHandler {
  id: root
  property int duration: 1500
  // pokes are ignored this long after startup, while services populate their initial values
  property int startupDelay: 2000
  readonly property bool active: hovered || timer.running

  // show now, then hide after `duration` with no further activity
  function poke() {
    if (startup.running) return
    timer.restart()
  }

  onHoveredChanged: if (!hovered) timer.stop()

  property Timer timer: Timer {
    interval: root.duration
  }

  property Timer startup: Timer {
    interval: root.startupDelay
    running: true
  }
}
