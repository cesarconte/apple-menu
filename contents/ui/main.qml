/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Cesar Conte
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kcmutils // KCMLauncher
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.sessions as Sessions

PlasmoidItem {
    id: root

    Sessions.SessionManagement {
        id: sm
    }

    Sessions.SessionsModel {
        id: sessionsModel
    }

    // define exec system ( call commands )
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        property var callbacks: ({})
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"]

            if (callbacks[sourceName] !== undefined) {
                callbacks[sourceName](stdout);
            }

            exited(sourceName, stdout)
            disconnectSource(sourceName) // exec finished
        }

        function exec(cmd, onNewDataCallback) {
            if (!cmd || cmd.trim() === "") {
                return;
            }
            if (onNewDataCallback !== undefined) {
                callbacks[cmd] = onNewDataCallback
            }
            connectSource(cmd)
        }
        signal exited(string sourceName, string stdout)
    }

    Connections {
        target: root
        function onExpandedChanged() {
            if (root.expanded) {
                if (fullRoot) {
                    fullRoot.forceActiveFocus();
                    fullRoot.currentIndex = -1;
                }
            } else {
                if (fullRoot) {
                    fullRoot.currentIndex = -1;
                }
            }
        }
    }

    preferredRepresentation: compactRepresentation
    compactRepresentation: null

    fullRepresentation: FocusScope {
        id: fullRoot
        focus: true

        readonly property double iwSize: Kirigami.Units.gridUnit * 12.6 // item width

        property int currentIndex: -1

        readonly property var menuItems: [
            aboutThisComputerItem,
            systemPreferencesItem,
            appStoreItem,
            forceQuitItem,
            sleepItem,
            restartItem,
            shutDownItem,
            lockScreenItem,
            logOutItem
        ]

        Layout.preferredWidth: 215
        Layout.preferredHeight: columnLayout.implicitHeight + 8
        implicitWidth: Layout.preferredWidth
        implicitHeight: Layout.preferredHeight

        function triggerCurrent(event) {
            if (currentIndex >= 0 && currentIndex < menuItems.length) {
                menuItems[currentIndex].clicked();
                if (event) {
                    event.accepted = true;
                }
            }
        }

        function triggerAction(actionName) {
            root.expanded = false;

            switch (actionName) {
                case "about":
                    soInfo.visible = true;
                    break;

                case "preferences":
                    if (plasmoid.configuration.showAdvancedMode && plasmoid.configuration.systemPreferencesSettings && plasmoid.configuration.systemPreferencesSettings.trim() !== "") {
                        executable.exec(plasmoid.configuration.systemPreferencesSettings);
                    } else {
                        KCMLauncher.openSystemSettings("");
                    }
                    break;

                case "appstore":
                    var appCmd = plasmoid.configuration.appStoreSettings;
                    if (!appCmd || appCmd.trim() === "" || appCmd === "plasma-discover") {
                        appCmd = "shelly-ui";
                    }
                    executable.exec(appCmd);
                    break;

                case "forcequit":
                    if (plasmoid.configuration.showAdvancedMode && plasmoid.configuration.forceQuitSettings && plasmoid.configuration.forceQuitSettings.trim() !== "" && plasmoid.configuration.forceQuitSettings !== "xkill") {
                        executable.exec(plasmoid.configuration.forceQuitSettings);
                    } else {
                        executable.exec("qdbus6 org.kde.KWin /KWin killWindow || busctl --user call org.kde.KWin /KWin org.kde.KWin killWindow");
                    }
                    break;

                case "sleep":
                    if (plasmoid.configuration.showAdvancedMode && plasmoid.configuration.sleepSettings && plasmoid.configuration.sleepSettings.trim() !== "" && plasmoid.configuration.sleepSettings !== "systemctl suspend") {
                        executable.exec(plasmoid.configuration.sleepSettings);
                    } else {
                        if (sm.canSuspend) {
                            sm.suspend();
                        } else {
                            executable.exec("systemctl suspend");
                        }
                    }
                    break;

                case "restart":
                    if (plasmoid.configuration.showAdvancedMode && plasmoid.configuration.restartSettings && plasmoid.configuration.restartSettings.trim() !== "" && plasmoid.configuration.restartSettings !== "/sbin/reboot") {
                        executable.exec(plasmoid.configuration.restartSettings);
                    } else {
                        sm.requestReboot();
                    }
                    break;

                case "shutdown":
                    if (plasmoid.configuration.showAdvancedMode && plasmoid.configuration.shutDownSettings && plasmoid.configuration.shutDownSettings.trim() !== "" && plasmoid.configuration.shutDownSettings !== "/sbin/shutdown now") {
                        executable.exec(plasmoid.configuration.shutDownSettings);
                    } else {
                        sm.requestShutdown();
                    }
                    break;

                case "lock":
                    if (plasmoid.configuration.showAdvancedMode && plasmoid.configuration.lockScreenSettings && plasmoid.configuration.lockScreenSettings.trim() !== "" && plasmoid.configuration.lockScreenSettings !== "qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock") {
                        executable.exec(plasmoid.configuration.lockScreenSettings);
                    } else {
                        sm.lock();
                    }
                    break;

                case "logout":
                    if (plasmoid.configuration.showAdvancedMode && plasmoid.configuration.logOutSettings && plasmoid.configuration.logOutSettings.trim() !== "" && plasmoid.configuration.logOutSettings !== "qdbus org.kde.ksmserver /KSMServer logout 0 0 0") {
                        executable.exec(plasmoid.configuration.logOutSettings);
                    } else {
                        sm.requestLogout();
                    }
                    break;
            }
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Down) {
                if (currentIndex < 0 || currentIndex >= menuItems.length - 1) {
                    currentIndex = 0;
                } else {
                    currentIndex++;
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                if (currentIndex <= 0) {
                    currentIndex = menuItems.length - 1;
                } else {
                    currentIndex--;
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Home) {
                currentIndex = 0;
                event.accepted = true;
            } else if (event.key === Qt.Key_End) {
                currentIndex = menuItems.length - 1;
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                triggerCurrent(event);
            } else if (event.key === Qt.Key_Escape) {
                root.expanded = false;
                event.accepted = true;
            }
        }

        ColumnLayout {
            id: columnLayout
            anchors.fill: parent
            anchors.margins: 4
            spacing: 1

            ListDelegate {
                id: aboutThisComputerItem
                isCurrent: fullRoot.currentIndex === 0
                text: i18n("About This Computer")
                onHovered: fullRoot.currentIndex = 0
                onClicked: fullRoot.triggerAction("about")
            }

            MenuSeparator {
                id: s1
                Layout.fillWidth: true
                padding: 0
                topPadding: 3
                bottomPadding: 3
                contentItem: Rectangle {
                    implicitWidth: fullRoot.iwSize
                    implicitHeight: 1
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                }
            }

            ListDelegate {
                id: systemPreferencesItem
                isCurrent: fullRoot.currentIndex === 1
                text: i18n("System Preferences...")
                onHovered: fullRoot.currentIndex = 1
                onClicked: fullRoot.triggerAction("preferences")
            }

            ListDelegate {
                id: appStoreItem
                isCurrent: fullRoot.currentIndex === 2
                text: i18n("App Store...")
                onHovered: fullRoot.currentIndex = 2
                onClicked: fullRoot.triggerAction("appstore")
            }

            MenuSeparator {
                id: s2
                Layout.fillWidth: true
                padding: 0
                topPadding: 3
                bottomPadding: 3
                contentItem: Rectangle {
                    implicitWidth: fullRoot.iwSize
                    implicitHeight: 1
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                }
            }

            ListDelegate {
                id: forceQuitItem
                isCurrent: fullRoot.currentIndex === 3
                text: i18n("Force Quit...")
                shortcutText: "⌥⌘⎋"
                onHovered: fullRoot.currentIndex = 3
                onClicked: fullRoot.triggerAction("forcequit")
            }

            MenuSeparator {
                id: s3
                Layout.fillWidth: true
                padding: 0
                topPadding: 3
                bottomPadding: 3
                contentItem: Rectangle {
                    implicitWidth: fullRoot.iwSize
                    implicitHeight: 1
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                }
            }

            ListDelegate {
                id: sleepItem
                isCurrent: fullRoot.currentIndex === 4
                text: i18n("Sleep")
                onHovered: fullRoot.currentIndex = 4
                onClicked: fullRoot.triggerAction("sleep")
            }

            ListDelegate {
                id: restartItem
                isCurrent: fullRoot.currentIndex === 5
                text: i18n("Restart...")
                onHovered: fullRoot.currentIndex = 5
                onClicked: fullRoot.triggerAction("restart")
            }

            ListDelegate {
                id: shutDownItem
                isCurrent: fullRoot.currentIndex === 6
                text: i18n("Shut Down...")
                onHovered: fullRoot.currentIndex = 6
                onClicked: fullRoot.triggerAction("shutdown")
            }

            MenuSeparator {
                id: s4
                Layout.fillWidth: true
                padding: 0
                topPadding: 3
                bottomPadding: 3
                contentItem: Rectangle {
                    implicitWidth: fullRoot.iwSize
                    implicitHeight: 1
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                }
            }

            ListDelegate {
                id: lockScreenItem
                isCurrent: fullRoot.currentIndex === 7
                text: i18n("Lock Screen")
                shortcutText: "⌃⌘Q"
                onHovered: fullRoot.currentIndex = 7
                onClicked: fullRoot.triggerAction("lock")
            }

            ListDelegate {
                id: logOutItem
                isCurrent: fullRoot.currentIndex === 8
                text: i18n("Log Out")
                shortcutText: "⇧⌘Q"
                onHovered: fullRoot.currentIndex = 8
                onClicked: fullRoot.triggerAction("logout")
            }
        }
    }

    SoInfo {
        id: soInfo
        visible: false
    }

    Plasmoid.icon: plasmoid.configuration.useCustomButtonImage ? plasmoid.configuration.customButtonImage : plasmoid.configuration.icon
}
