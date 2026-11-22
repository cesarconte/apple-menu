/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Cesar Conte
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.draganddrop as DragDrop
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.plasmoid
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes
import CachyOS.UI

KCM.SimpleKCM {
    id: configGeneral

    property string cfg_icon: Plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: Plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: Plasmoid.configuration.customButtonImage

    property alias cfg_showAdvancedMode: showAdvancedMode.checked
    property alias cfg_aboutThisComputerSettings: aboutThisComputerSettings.text
    property alias cfg_systemPreferencesSettings: systemPreferencesSettings.text
    property alias cfg_appStoreSettings: appStoreSettings.text
    property alias cfg_forceQuitSettings: forceQuitSettings.text
    property alias cfg_sleepSettings: sleepSettings.text
    property alias cfg_restartSettings: restartSettings.text
    property alias cfg_shutDownSettings: shutDownSettings.text
    property alias cfg_lockScreenSettings: lockScreenSettings.text
    property alias cfg_logOutSettings: logOutSettings.text

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Item {
            Kirigami.FormData.label: i18n("Icon:")
            implicitWidth: iconButton.implicitWidth
            implicitHeight: iconButton.implicitHeight

            QQC2.Button {
                id: iconButton
                anchors.fill: parent

                implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
                implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2

                checkable: true
                checked: dropArea.containsAcceptableDrag

                onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

                DragDrop.DropArea {
                    id: dropArea
                    anchors.fill: parent
                    property bool containsAcceptableDrag: false

                    onDragEnter: (event) => {
                        var urlString = event.mimeData.url.toString();
                        var extensions = [".png", ".xpm", ".svg", ".svgz"];
                        containsAcceptableDrag = urlString.indexOf("file:///") === 0 && extensions.some(function (extension) {
                            return urlString.indexOf(extension) === urlString.length - extension.length;
                        });
                        if (!containsAcceptableDrag) {
                            event.ignore();
                        }
                    }
                    onDragLeave: containsAcceptableDrag = false

                    onDrop: (event) => {
                        if (containsAcceptableDrag) {
                            iconDialog.setCustomButtonImage(event.mimeData.url.toString().substr("file://".length));
                        }
                        containsAcceptableDrag = false;
                    }
                }

                KIconThemes.IconDialog {
                    id: iconDialog

                    function setCustomButtonImage(image) {
                        configGeneral.cfg_customButtonImage = image || configGeneral.cfg_icon || "start-here-kde";
                        configGeneral.cfg_useCustomButtonImage = true;
                    }

                    onIconNameChanged: setCustomButtonImage(iconName)
                }

                KSvg.FrameSvgItem {
                    id: previewFrame
                    anchors.centerIn: parent
                    imagePath: Plasmoid.location === PlasmaCore.Types.Vertical || Plasmoid.location === PlasmaCore.Types.Horizontal
                            ? "widgets/panel-background" : "widgets/background"
                    width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                    height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.large
                        height: width
                        source: configGeneral.cfg_useCustomButtonImage ? configGeneral.cfg_customButtonImage : configGeneral.cfg_icon
                    }
                }

                CachyMenu {
                    id: iconMenu
                    y: iconButton.height

                    onClosed: iconButton.checked = false

                    CachyMenuItem {
                        text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                        iconName: "document-open-folder"
                        onClicked: iconDialog.open()
                    }
                    CachyMenuItem {
                        text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
                        iconName: "edit-clear"
                        onClicked: {
                            configGeneral.cfg_icon = "start-here-kde";
                            configGeneral.cfg_useCustomButtonImage = false;
                            configGeneral.cfg_customButtonImage = "";
                        }
                    }
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Commands & Behavior")
        }

        CachySwitch {
            id: showAdvancedMode
            Kirigami.FormData.label: i18n("Custom commands:")
            text: i18n("Enable custom commands (expert mode)")
        }

        Text {
            visible: showAdvancedMode.checked
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: i18n("Warning: By default, the menu uses native Plasma 6 session and KWin DBus interfaces. Only override if you need specific commands.")
            color: CachyPalette.textSecondary
            font.pixelSize: 11
        }

        CachyTextField {
            id: appStoreSettings
            Kirigami.FormData.label: i18n("App Store:")
            placeholderText: "shelly-ui"
            visible: showAdvancedMode.checked
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        CachyTextField {
            id: systemPreferencesSettings
            Kirigami.FormData.label: i18n("System Preferences:")
            placeholderText: "systemsettings"
            visible: showAdvancedMode.checked
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        CachyTextField {
            id: aboutThisComputerSettings
            Kirigami.FormData.label: i18n("About This Computer:")
            placeholderText: "kinfocenter"
            visible: showAdvancedMode.checked
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        CachyTextField {
            id: forceQuitSettings
            Kirigami.FormData.label: i18n("Force Quit:")
            placeholderText: "qdbus6 org.kde.KWin /KWin killWindow"
            visible: showAdvancedMode.checked
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        CachyTextField {
            id: sleepSettings
            Kirigami.FormData.label: i18n("Sleep:")
            placeholderText: "systemctl suspend"
            visible: showAdvancedMode.checked
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        CachyTextField {
            id: restartSettings
            Kirigami.FormData.label: i18n("Restart:")
            placeholderText: "/sbin/reboot"
            visible: showAdvancedMode.checked
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        CachyTextField {
            id: shutDownSettings
            Kirigami.FormData.label: i18n("Shut Down:")
            placeholderText: "/sbin/shutdown now"
            visible: showAdvancedMode.checked
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        CachyTextField {
            id: lockScreenSettings
            Kirigami.FormData.label: i18n("Lock Screen:")
            placeholderText: "loginctl lock-session"
            visible: showAdvancedMode.checked
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        CachyTextField {
            id: logOutSettings
            Kirigami.FormData.label: i18n("Log Out:")
            placeholderText: "qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout"
            visible: showAdvancedMode.checked
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }
    }
}
