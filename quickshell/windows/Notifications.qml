import QtQuick
import QtQuick.Layouts
import Quickshell
import "../config"
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications

// Minimal Quickshell notification popup.
//
// Usage: put this file next to your shell.qml as "Notifications.qml"
// and load it from shell.qml, e.g.:
//
//   Notifications {}
//
// It creates its own NotificationServer, so don't declare another one
// unless you want to route notifications elsewhere too.

Scope {
  id: root

  // ---- Tunables -----------------------------------------------------
  property int popupWidth: 340
  property int spacing: 8
  property int margin: 16
  property int defaultTimeoutMs: 6000
  property color bg: Theme.surface
  property color fg: Theme.fg
  property color subFg: Qt.darker(Theme.fg, 1.2)
  property color lowColor: Theme.primary
  property color normalColor: Theme.primary
  property color criticalColor: Theme.danger

  NotificationServer {
    id: notifServer
    keepOnReload: true
    imageSupported: true
    actionsSupported: true
    bodyMarkupSupported: true

    // Tracked notifications live in notifServer.trackedNotifications.
    // dismiss()/expire() untrack them, which removes the card automatically.
    onNotification: function (notification) {
      notification.tracked = true
    }
  }

  // One popup panel per screen, anchored top-right
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors.top: true
      anchors.right: true

      margins.top: root.margin
      margins.right: root.margin

      implicitWidth: root.popupWidth
      implicitHeight: Math.max(1, column.implicitHeight)
      visible: notifServer.trackedNotifications.values.length > 0

      color: "transparent"

      exclusiveZone: 0
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "quickshell-notifications"

      ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: root.spacing

        Repeater {
          model: notifServer.trackedNotifications

          delegate: Rectangle {
            id: card
            required property var modelData
            readonly property var notification: modelData

            Layout.fillWidth: true
            implicitHeight: content.implicitHeight + 24
            radius: Theme.radius
            color: root.bg
            border.width: 1
            border.color: Theme.surfaceBorder
            // border.width: 1
            // border.color: {
            //   switch (notification.urgency) {
            //     case NotificationUrgency.Critical: return root.criticalColor
            //     case NotificationUrgency.Low: return root.lowColor
            //     default: return root.normalColor
            //   }
            // }

            // Slide/fade in
            opacity: 0
            Component.onCompleted: opacity = 1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            MouseArea {
              anchors.fill: parent
              onClicked: card.notification.dismiss()
            }

            Timer {
              interval: card.notification.expireTimeout > 0 ? card.notification.expireTimeout : root.defaultTimeoutMs
              running: true
              onTriggered: card.notification.expire()
            }

            RowLayout {
              id: content
              anchors.fill: parent
              anchors.margins: 12
              spacing: 10

              ClippingRectangle {
                visible: notification.image !== "" || notification.appIcon !== ""
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                Layout.rightMargin: 6
                Layout.alignment: Qt.AlignTop
                radius: width / 2
                color: "transparent"

                Image {
                  anchors.fill: parent
                  source: notification.image !== "" ? notification.image : ("image://icon/" + notification.appIcon)
                  fillMode: Image.PreserveAspectCrop
                  sourceSize.width: 72
                  sourceSize.height: 72
                }
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                  text: notification.summary
                  color: root.fg
                  font.bold: true
                  font.pixelSize: 13
                  Layout.fillWidth: true
                  elide: Text.ElideRight
                }

                Text {
                  visible: notification.body !== ""
                  text: notification.body
                  color: root.subFg
                  font.pixelSize: 12
                  wrapMode: Text.Wrap
                  Layout.fillWidth: true
                  maximumLineCount: 3
                  elide: Text.ElideRight
                  textFormat: Text.StyledText
                }

                RowLayout {
                  visible: notification.actions.length > 0
                  spacing: 6
                  Layout.topMargin: 4

                  Repeater {
                    model: notification.actions

                    Rectangle {
                      required property var modelData
                      implicitWidth: actionLabel.implicitWidth + 16
                      implicitHeight: 24
                      radius: Theme.radius
                      color: Theme.selection

                      Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text
                        color: root.fg
                        font.pixelSize: 11
                      }

                      MouseArea {
                        anchors.fill: parent
                        onClicked: {
                          modelData.invoke()
                          if (card.notification) card.notification.dismiss()
                        }
                      }
                    }
                  }
                }
              }

              Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignTop
                radius: 10
                color: "transparent"

                Text {
                  anchors.centerIn: parent
                  text: "✕"
                  color: root.subFg
                  font.pixelSize: 11
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: card.notification.dismiss()
                }
              }
            }
          }
        }
      }
    }
  }
}
