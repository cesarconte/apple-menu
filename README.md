# Apple Menu for KDE Plasma 6

A macOS-style Apple Menu applet for KDE Plasma 6.

![Screenshot](screenshots/screenshot.png)

## Features

- **macOS Apple Menu Experience**: Clean, native dropdown menu for system actions.
- **Full Keyboard Navigation**: Navigate menu items smoothly with arrow keys (`Up` / `Down`), `Home`, `End`, `Enter` / `Return` / `Space` to activate, and `Escape` to dismiss.
- **Shelly-UI App Store**: Opens **Shelly-UI** (`shelly-ui`) out of the box when clicking on *App Store...*.
- **Native KDE Plasma 6 Session Controls**: Reliable integration with Plasma 6 session management (Suspend, Reboot, Shutdown, Lock Screen, and Log Out) without requiring root permissions, functioning seamlessly under Wayland and X11.
- **Native KWin Force Quit**: Uses KWin's native `killWindow` action across Wayland and X11.
- **Customizable**: Configurable icons, custom button image, and custom command overrides if desired.

## Installation

### From Source

Clone into your local Plasma applets directory:

```bash
git clone https://github.com/cesarconte/apple-menu.git ~/.local/share/plasma/plasmoids/org.kpple.kppleMenu
```

Or if you have the repository in another folder (e.g. `~/Proyectos/apple-menu`), you can symlink it:

```bash
ln -s ~/Proyectos/apple-menu ~/.local/share/plasma/plasmoids/org.kpple.kppleMenu
```

Restart Plasma Shell to load changes:

```bash
plasmashell --replace &
# or on systemd-managed Plasma:
systemctl --user restart plasma-plasmashell.service
```

## License

GNU General Public License v2.0
