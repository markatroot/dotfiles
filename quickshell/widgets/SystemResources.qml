import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../services" as QsServices
import "../config"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true
  spacing: 5

  readonly property var cpuUsageFraction: QsServices.SystemResourcesService.cpuPerc

  readonly property var memoryUsage: QsServices.SystemResourcesService.memUsed

  readonly property var memoryTotal: QsServices.SystemResourcesService.memTotal

  readonly property var cpuUsagePercent: Math.floor(root.cpuUsageFraction * 100)

  function formatResourceAbbr(value) {
    return value.replace('Gi', 'GB').replace('Mi', 'MB')
  }

  Text {
    // anchors.verticalCenter: parent.verticalCenter
    text: `${root.cpuUsagePercent}%`
    color: root.cpuUsagePercent > 90 ? Fonts.colorDanger : Fonts.colorNormal
    font.weight: Fonts.black
    font.family: Fonts.mono
    font.pixelSize: Fonts.lg
  }

  MultiEffect {
    source: cpuIcon
    colorization: 1.0
    colorizationColor: Fonts.colorNormal
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: cpuIcon.width
    Layout.preferredHeight: cpuIcon.height
  }

  Image {
    id: cpuIcon
    visible: false
    source: Icons.iconPath("cpu.svg")
    sourceSize.height: Icons.imgIconHeight - 6
    sourceSize.width: Icons.imgIconWidth - 6
    height: sourceSize.height
    width: sourceSize.width
  }

  Text {
    Layout.leftMargin: 20
    text: `${root.memoryUsage}Gb`
    color: Fonts.colorNormal
    font.weight: Fonts.medium
    font.family: Fonts.mono
    font.pixelSize: Fonts.lg
  }

  MultiEffect {
    source: memoryIcon
    colorization: 1.0
    colorizationColor: Fonts.colorNormal
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: memoryIcon.width
    Layout.preferredHeight: memoryIcon.height
  }

  Image {
    id: memoryIcon
    visible: false
    source: Icons.iconPath("memory-stick.svg")
    sourceSize.height: Icons.imgIconHeight - 2
    sourceSize.width: Icons.imgIconWidth - 2
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
  //       color: Fonts.colorNormal
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
  //       color: Fonts.colorNormal
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

