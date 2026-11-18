/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Cesar Conte
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-desktop-plasma"
        source: "config/configGeneral.qml"
    }
}
