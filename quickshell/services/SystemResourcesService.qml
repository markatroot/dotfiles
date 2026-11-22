pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Polls CPU usage, memory and CPU temperature. Reads /proc and /sys directly
// through FileView, so a refresh spawns no processes; the only subprocess is
// the one-time sensor lookup at startup.
Singleton {
  id: root

  property bool active: true

  property string memUsed: ""
  property string memTotal: ""

  property real cpuPerc: 0

  // CPU package temperature in °C (-1 until a sensor is read)
  property real cpuTemp: -1

  property real lastCpuIdle: 0
  property real lastCpuTotal: 0

  // Path of the CPU temperature file, resolved once by tempSensorLookup.
  property string tempPath: ""

  function refresh() {
    statFile.reload()
    memFile.reload()
    if (root.tempPath !== "") tempFile.reload()
  }

  // Memory usage (GiB, one decimal), from MemTotal - MemAvailable.
  FileView {
    id: memFile
    path: "/proc/meminfo"
    onLoaded: {
      const text = memFile.text()
      const total = parseInt(text.match(/^MemTotal:\s+(\d+)/m)?.[1])
      const avail = parseInt(text.match(/^MemAvailable:\s+(\d+)/m)?.[1])
      if (isNaN(total) || isNaN(avail)) return
      root.memTotal = (total / 1048576).toFixed(1)
      root.memUsed = ((total - avail) / 1048576).toFixed(1)
    }
  }

  // CPU usage, from the delta of the aggregate "cpu" line between polls.
  FileView {
    id: statFile
    path: "/proc/stat"
    onLoaded: {
      const line = statFile.text().match(/^cpu\s+(.*)$/m)?.[1]
      if (!line) return
      const parts = line.trim().split(/\s+/).map(Number)
      if (parts.length < 4) return
      const idle = parts[3]
      const total = parts[0] + parts[1] + parts[2] + idle

      if (root.lastCpuTotal > 0) {
        const totalDiff = total - root.lastCpuTotal
        const idleDiff = idle - root.lastCpuIdle
        if (totalDiff > 0) root.cpuPerc = 1 - (idleDiff / totalDiff)
      }
      root.lastCpuIdle = idle
      root.lastCpuTotal = total
    }
  }

  FileView {
    id: tempFile
    path: root.tempPath
    blockLoading: root.tempPath === ""
    onLoaded: {
      const milli = parseInt(tempFile.text().trim())
      if (!isNaN(milli)) root.cpuTemp = milli / 1000
    }
  }

  // hwmon indexes aren't stable across boots, so find the CPU sensor by name
  // (Intel coretemp / AMD k10temp, zenpower), falling back to the
  // x86_pkg_temp thermal zone. Runs once; prints the file path to read.
  Process {
    id: tempSensorLookup
    running: true
    command: ["/bin/sh", "-c", `
for d in /sys/class/hwmon/hwmon*; do
  case "$(cat "$d/name" 2>/dev/null)" in
    coretemp|k10temp|zenpower) echo "$d/temp1_input"; exit ;;
  esac
done
for z in /sys/class/thermal/thermal_zone*; do
  [ "$(cat "$z/type" 2>/dev/null)" = x86_pkg_temp ] && { echo "$z/temp"; exit; }
done`]

    stdout: SplitParser {
      onRead: data => root.tempPath = data.trim()
    }
  }

  Timer {
    interval: 5000
    repeat: true
    running: root.active
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
