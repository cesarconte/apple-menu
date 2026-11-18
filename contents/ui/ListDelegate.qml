/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Cesar Conte
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {
    id: item

    signal clicked
    signal hovered

    property bool isCurrent: false
    property alias text: label.text
    property string shortcutText: ""
    property alias containsMouse: area.containsMouse

    readonly property bool highlighted: isCurrent || area.containsMouse

    Layout.fillWidth: true
    implicitHeight: 26
    height: implicitHeight

    Rectangle {
        id: highlightRect
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        radius: 4
        color: item.highlighted ? Kirigami.Theme.highlightColor : "transparent"
        visible: item.highlighted
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: item.clicked()
        onEntered: item.hovered()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.smallSpacing * 2
        anchors.rightMargin: Kirigami.Units.smallSpacing * 2
        spacing: Kirigami.Units.smallSpacing

        Label {
            id: label
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
            color: item.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
            elide: Text.ElideRight
            font: Kirigami.Theme.defaultFont
        }

        Label {
            id: shortcutLabel
            text: item.shortcutText
            visible: item.shortcutText.length > 0
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            color: item.highlighted 
                   ? Kirigami.Theme.highlightedTextColor 
                   : Kirigami.Theme.disabledTextColor
            font: Kirigami.Theme.smallFont
            opacity: item.highlighted ? 1.0 : 0.8
        }
    }
}
