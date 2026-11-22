/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Cesar Conte
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: item

    signal clicked
    signal hovered

    property bool isCurrent: false
    property alias text: label.text
    property string shortcutText: ""
    readonly property bool containsMouse: hoverHandler.hovered
    readonly property bool highlighted: isCurrent || containsMouse

    Layout.fillWidth: true
    implicitHeight: 28
    height: implicitHeight

    scale: tapHandler.pressed ? 0.98 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: CachyTheme.animFast
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: highlightRect
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        radius: CachyTheme.radiusSmall
        color: item.highlighted ? CachyTheme.accentColor : "transparent"
        visible: item.highlighted

        Behavior on color {
            ColorAnimation {
                duration: CachyTheme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (hovered) {
                item.hovered();
            }
        }
    }

    TapHandler {
        id: tapHandler
        onTapped: item.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: CachyTheme.spacingSmall

        Text {
            id: label
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            verticalAlignment: Text.AlignVCenter
            color: item.highlighted ? "#FFFFFF" : CachyPalette.text
            elide: Text.ElideRight
            font.pixelSize: 13
        }

        Text {
            id: shortcutLabel
            text: item.shortcutText
            visible: item.shortcutText.length > 0
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            color: item.highlighted ? Qt.rgba(1, 1, 1, 0.85) : CachyPalette.textSecondary
            font.pixelSize: 11
        }
    }
}
