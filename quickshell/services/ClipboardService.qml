pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property var entries: null

  Process {
    id: clipboardListProcess
    command: ['bash', '-c', `cliphist list | awk '!seen[$2]++ { print $2 }'`]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var lines = text?.split('\n');
          root.entries = lines
        } catch (e) {
          root.entries = []
          console.error(e)
        }
      }
    }
  }

  function tryParseJson(obj) {
    if (!obj) {
      return null
    }
    try {
      return JSON.parse(obj)
    } catch (e) {
      console.error('parse error', e)
      return null
    }
  }

  function loadClipboard() {
    clipboardListProcess.running = true
  }


}
