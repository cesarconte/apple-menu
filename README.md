# Apple Menu for KDE Plasma 6

A macOS 27 Golden Gate (Liquid Glass) Apple Menu plasmoid for CachyOS / KDE Plasma 6 built with `CachyOS.UI`.

![Screenshot](screenshots/screenshot.png)

## Features

- **macOS Golden Gate Experience**: Clean, native Liquid Glass dropdown menu for system actions adhering to `CachyOS.UI` canonical styling.
- **Full Keyboard Navigation**: Navigate menu items smoothly with arrow keys (`Up` / `Down`), `Home`, `End`, `Enter` / `Return` / `Space` to activate, and `Escape` to dismiss.
- **Shelly-UI App Store**: Opens **Shelly-UI** (`shelly-ui`) out of the box when clicking on *App Store...*.
- **Native KDE Plasma 6 Session Controls**: Reliable integration with Plasma 6 session management (Suspend, Reboot, Shutdown, Lock Screen, and Log Out) without requiring root permissions, functioning seamlessly under Wayland and X11.
- **Native KWin Force Quit**: Uses KWin's native `killWindow` action across Wayland and X11.
- **About This Computer**: Native Golden Gate utility window presenting CPU, GPU, memory, and storage details with CachyOS design standards.
- **Customizable**: Configurable icons, custom button image, and custom command overrides if desired.

## Installation

Install system-wide in `/usr/share/plasma/plasmoids/org.kpple.kppleMenu`:

```bash
sudo mkdir -p /usr/share/plasma/plasmoids/org.kpple.kppleMenu
sudo cp -r contents metadata.json /usr/share/plasma/plasmoids/org.kpple.kppleMenu/
```

Restart Plasma Shell to load changes:

```bash
systemctl --user restart plasma-plasmashell.service
```

## License

GNU General Public License v2.0
