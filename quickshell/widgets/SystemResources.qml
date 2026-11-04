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

  // Text boxes reserve descender space, so their visual center sits above the
  // box center. Shift icons up to line up with the glyphs instead of the box.
  // (In a RowLayout with AlignVCenter, a bottom margin of 2n raises by n px.)
  readonly property int iconLift: 1

  function formatResourceAbbr(value) {
    return value.replace('Gi', 'GB').replace('Mi', 'MB')
  }

  // CPU: icon, usage
  MultiEffect {
    source: cpuIcon
    colorization: 1.0
    Layout.bottomMargin: root.iconLift * 2
    colorizationColor: Theme.fg
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: cpuIcon.width
    Layout.preferredHeight: cpuIcon.height
  }

  Image {
    id: cpuIcon
    visible: false
    source: Icons.cpu
    sourceSize.height: Icons.imgIconHeight / 1.2
    sourceSize.width: Icons.imgIconWidth / 1.2
    height: sourceSize.height
    width: sourceSize.width
  }

  Text {
    Layout.leftMargin: 4
    text: `${root.cpuUsagePercent}%`
    color: root.cpuUsagePercent > 90 ? Theme.danger : Theme.fg
    font.weight: Fonts.black
    font.family: Fonts.mono
    font.pixelSize: Fonts.lg
  }

  // Memory: icon, used
  MultiEffect {
    source: memoryIcon
    colorization: 1.0
    Layout.leftMargin: 28
    Layout.bottomMargin: root.iconLift * 2
    colorizationColor: Theme.fg
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: memoryIcon.width
    Layout.preferredHeight: memoryIcon.height
  }

  Image {
    id: memoryIcon
    visible: false
    source: Icons.memory
    sourceSize.height: Icons.imgIconHeight / 1.2
    sourceSize.width: Icons.imgIconWidth / 1.2
    height: sourceSize.height
    width: sourceSize.width
  }

  Text {
    Layout.leftMargin: 4
    text: `${root.memoryUsage} GB`
    color: Theme.fg
    font.weight: Fonts.medium
    font.family: Fonts.mono
    font.pixelSize: Fonts.lg
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

