pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  // [{ id: "123", text: "preview" }], newest first
  property var entries: []
  property bool loading: clipboardListProcess.running

  Process {
    id: clipboardListProcess
    command: ['cliphist', 'list']
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const seen = {}
        const result = []
        for (const line of text.split('\n')) {
          const tab = line.indexOf('\t')
          if (tab < 0) continue
          const id = line.slice(0, tab)
          const preview = line.slice(tab + 1)
          if (seen[preview]) continue
          seen[preview] = true
          result.push({ id: id, text: preview })
        }
        root.entries = result
      }
    }
  }

  // Deferred so the popup can map and paint before cliphist runs
  Timer {
    id: loadTimer
    interval: 50
    onTriggered: clipboardListProcess.running = true
  }

  function loadClipboard() {
    if (!clipboardListProcess.running) loadTimer.restart()
  }

  function filter(query) {
    const q = query.trim().toLowerCase()
    if (q.length === 0) return root.entries
    return root.entries.filter(e => e.text.toLowerCase().includes(q))
  }

  function copy(id) {
    Quickshell.execDetached(['bash', '-c', 'cliphist decode "$1" | wl-copy', '_', id])
  }

  function wipe() {
    Quickshell.execDetached(['cliphist', 'wipe'])
    root.entries = []
  }
}
