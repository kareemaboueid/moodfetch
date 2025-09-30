# moodfetch

![Moodfetch Logo](https://raw.githubusercontent.com/kareemaboueid/moodfetch/refs/heads/main/logo/moodfetch.png)

A command-line tool for displaying your system's "mood"

Moodfetch displays your system's "mood" by fetching and presenting various system information.

## Requirements

### Core Requirements

- bash 4.0+
- make (for installation via `make install`)

### Platform-Specific Requirements

#### Linux

- procfs and sysfs mounted (standard on most distributions)
- Optional:
  - `nmcli` → Wi-Fi signal strength
  - `pactl` / `amixer` → audio volume moods
  - `powerprofilesctl` → power profile detection

## Install

```bash
git clone https://github.com/kareemaboueid/moodfetch.git
```

```bash
cd moodfetch
```

```bash
sudo make install
```

## Usage

Basic usage:

```bash
moodfetch           # Display system mood
moodfetch --version # Show version information
moodfetch --check-update # Check for updates
```

Available options:

- `--version`: Display version information
- `--check-update`: Check for available updates

## Configuration

Moodfetch can be configured using either:

- System-wide config: `/etc/moodfetch/config`
- User config: `~/.config/moodfetch/config`

The configuration file contains system warning thresholds and performance settings.

### Signal Handling

Moodfetch handles system signals gracefully to ensure clean termination:

- `SIGINT` (Ctrl+C): Gracefully stops execution
- `SIGTERM`: Cleans up and exits normally
- `SIGHUP`: Handles terminal disconnect properly

Resources are automatically cleaned up on exit:

- Temporary files are removed
- Background processes are terminated
- Active network connections are closed

You can create custom themes in `~/.config/moodfetch/themes/`:

1. Create a new `.theme` file
2. Define sections with `[section_name]`
3. Add message templates (one per line)

Example custom theme:

```bash
# ~/.config/moodfetch/themes/mytheme.theme

[battery_critical]
Battery at {battery_pct}% - custom message here!
Another message template here...

[cpu_hot]
CPU temp {cpu_temp}°C - your message here...
```

Theme locations (in order of precedence):

1. `~/.config/moodfetch/themes/` (user themes)
2. `/etc/moodfetch/themes/` (system-wide themes)
3. Built-in themes

## Options

| Flag             | Description                                  |
|------------------|----------------------------------------------|
| `--verbose`      | Show metrics summary with numbers            |
| `--debug`        | Enable debug logging for troubleshooting     |
| `--version`      | Show version and exit                        |
| `--help, -h`     | Show help                                    |

## Contributing

Contributions are welcome!  
Feel free to fork the repo, create feature branches, and submit pull requests.  
For major changes, please open an issue first to discuss what you’d like to change.

### Example

![Moodfetch Screenshot](https://raw.githubusercontent.com/kareemaboueid/moodfetch/refs/heads/main/moodfetch-screenshot1.png)

## License

[MIT](./LICENSE)
