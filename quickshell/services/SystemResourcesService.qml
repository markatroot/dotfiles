pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property bool active: true

  property string memUsed: ""
  property string memTotal: ""

  property real cpuPerc: 0

  property real lastCpuIdle: 0
  property real lastCpuTotal: 0

  Component.onCompleted: {
    root.updateCPUProcess()
    root.updateMemProcess()
  }

  function updateMemProcess() {
    memProcess.running = true
  }

  function updateCPUProcess() {
    cpuProcess.running = true
  }

  // Memory usage
  Process {
    id: memProcess
    command: ['/bin/sh', '-c', `awk '
/MemTotal:/     { total = $2 }
/MemAvailable:/ { avail = $2 }
END {
    used = total - avail
    printf "%.1f|%.1f", used/1024/1024, total/1024/1024
}' /proc/meminfo`]
    // command: ["/bin/sh", "-c", "free -h | grep Mem | awk '{ print $2\"|\"$3 }'"]
    running: false

    stdout: SplitParser {
      onRead: data => {
        const parts = data.split('|')
        if (parts.length == 2) {
          root.memTotal = parts[1]
          root.memUsed = parts[0]
        }
      }
    }
  }

  // CPU usage calculation
  Process {
    id: cpuProcess
    command: ["/bin/sh", "-c", "cat /proc/stat | grep '^cpu '"]
    running: false

    stdout: SplitParser {
      onRead: data => {
        const parts = data.trim().split(/\s+/)
        if (parts.length >= 5) {
          const user = parseInt(parts[1])
          const nice = parseInt(parts[2])
          const system = parseInt(parts[3])
          const idle = parseInt(parts[4])
          const total = user + nice + system + idle

          if (root.lastCpuTotal > 0) {
            const totalDiff = total - root.lastCpuTotal
            const idleDiff = idle - root.lastCpuIdle
            if (totalDiff > 0) {
              root.cpuPerc = 1 - (idleDiff / totalDiff)
            }
          }
          root.lastCpuIdle = idle
          root.lastCpuTotal = total
        }
      }
    }
  }

  Timer {
    id: updateTimer
    interval: 5000
    repeat: true
    running: root.active
    triggeredOnStart: true
    onTriggered: {
      root.updateCPUProcess()
      root.updateMemProcess()
    }
  }

}
