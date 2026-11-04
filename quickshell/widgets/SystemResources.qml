import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../services" as QsServices
import "../config"
import "../components"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true
  // spacing: 5

  readonly property var cpuUsageFraction: QsServices.SystemResourcesService.cpuPerc

  readonly property var memoryUsage: QsServices.SystemResourcesService.memUsed

  readonly property var memoryTotal: QsServices.SystemResourcesService.memTotal

  readonly property var cpuUsagePercent: Math.floor(root.cpuUsageFraction * 100)

  readonly property real cpuTemp: QsServices.SystemResourcesService.cpuTemp

  // °C thresholds for the CPU icon color
  readonly property int tempWarn: 60
  readonly property int tempHigh: 80

  function cpuTempColor() {
    if (root.cpuTemp < 0) return Theme.fg
    if (root.cpuTemp >= root.tempHigh) return Theme.danger
    if (root.cpuTemp >= root.tempWarn) return Theme.warning
    return Theme.success
  }

  // Text boxes reserve descender space, so their visual center sits above the
  // box center. Shift icons up to line up with the glyphs instead of the box.
  // (In a RowLayout with AlignVCenter, a bottom margin of 2n raises by n px.)
  readonly property int iconLift: 1

  function formatResourceAbbr(value) {
    return value.replace('Gi', 'GB').replace('Mi', 'MB')
  }

  Text {
    // anchors.verticalCenter: parent.verticalCenter
    text: `${root.cpuUsagePercent}%`
    color: root.cpuUsagePercent > 90 ? Theme.danger : Theme.fg
    font.weight: Fonts.black
    font.family: Fonts.mono
    font.pixelSize: Fonts.lg

    MouseArea {
      id: cpuUsageHover
      anchors.fill: parent
      hoverEnabled: true
    }
  }

  TextInfoReveal {
    show: (cpuUsageHover.containsMouse || cpuIconHover.containsMouse) && root.cpuTemp >= 0
    text: `${Math.round(root.cpuTemp)}°C`
    textColor: root.cpuTempColor()
    fontSize: Fonts.md
  }

  MultiEffect {
    source: cpuIcon
    colorization: 1.0
    Layout.bottomMargin: root.iconLift * 2
    colorizationColor: root.cpuTempColor()
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: cpuIcon.width
    Layout.preferredHeight: cpuIcon.height

    MouseArea {
      id: cpuIconHover
      anchors.fill: parent
      hoverEnabled: true
    }
  }

  Image {
    id: cpuIcon
    visible: false
    source: Icons.cpu
    sourceSize.height: Icons.imgIconHeight / 1.5
    sourceSize.width: Icons.imgIconWidth / 1.5
    height: sourceSize.height
    width: sourceSize.width
  }

  Text {
    Layout.leftMargin: 20
    Layout.rightMargin: -5
    text: `${root.memoryUsage}Gb`
    color: Theme.fg
    font.weight: Fonts.medium
    font.family: Fonts.mono
    font.pixelSize: Fonts.lg

    MouseArea {
      id: memoryUsageHover
      anchors.fill: parent
      hoverEnabled: true // Required to detect hover without clicking
    }
  }

  TextInfoReveal {
    show: memoryUsageHover.containsMouse || memoryUsageIconHover.containsMouse
    text: `/${root.memoryTotal}Gb`
    fontSize: Fonts.lg
    opacity: .6
  }

  MultiEffect {
    source: memoryIcon
    colorization: 1.0
    Layout.bottomMargin: root.iconLift * 2
    colorizationColor: Theme.fg
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: memoryIcon.width
    Layout.preferredHeight: memoryIcon.height


    MouseArea {
      id: memoryUsageIconHover
      anchors.fill: parent
      hoverEnabled: true // Required to detect hover without clicking
    }
  }

  Image {
    id: memoryIcon
    visible: false
    source: Icons.memory
    sourceSize.height: Icons.imgIconHeight / 1.5
    sourceSize.width: Icons.imgIconWidth / 1.5
    height: sourceSize.height
    width: sourceSize.width
  }


  // Column {
  //   Row {
  //     id: row
  //     anchors.right: parent.right
  //     spacing: 10
  //
  //     property int cpuPercentage: root.cpuUsageFraction * 100
  //
  //     Text {
  //       anchors.verticalCenter: parent.verticalCenter
  //       text: `${row.cpuPercentage}%`
  //       color: Theme.fg
  //       font.weight: Fonts.black
  //       font.family: Fonts.mono
  //       font.pixelSize: Fonts.md
  //     }
  //     Image {
  //       anchors.verticalCenter: parent.verticalCenter
  //       source: {
  //         if (row.cpuPercentage > 90) {
  //           return Quickshell.iconPath("indicator-cpufreq-100")
  //         } else if (row.cpuPercentage > 75) {
  //           return Quickshell.iconPath("indicator-cpufreq-75")
  //         } else if (row.cpuPercentage > 50) {
  //           return Quickshell.iconPath("indicator-cpufreq-50")
  //         } else if (row.cpuPercentage > 25) {
  //           return Quickshell.iconPath("indicator-cpufreq-25")
  //         }
  //         return Quickshell.iconPath("indicator-cpufreq")
  //       }
  //       sourceSize.height: 14
  //       sourceSize.width: 14
  //     }
  //
  //   }
  //   Row {
  //     spacing: 10
  //
  //     Text {
  //       anchors.verticalCenter: parent.verticalCenter
  //       text: `${root.memoryUsage}Gb/${root.memoryTotal}Gb`
  //       color: Theme.fg
  //       font.weight: Fonts.medium
  //       font.family: Fonts.mono
  //       font.pixelSize: Fonts.lg
  //     }
  //     Image {
  //       anchors.verticalCenter: parent.verticalCenter
  //       source: Quickshell.iconPath("indicator-sensors-memory")
  //       sourceSize.height: 14
  //       sourceSize.width: 14
  //       Layout.alignment: Qt.AlignVCenter
  //     }
  //   }
  // }

}

