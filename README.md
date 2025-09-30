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

### Quick Local Setup (Recommended)

Simple, safe, and no system modifications required:

```bash
git clone https://github.com/kareemaboueid/moodfetch.git
cd moodfetch
chmod +x moodfetch
./moodfetch
```

That's it! You can now use `./moodfetch` from anywhere within the repository directory.

**Benefits of local usage:**

- ✅ No sudo required
- ✅ Easy to update with `git pull`
- ✅ No system files modified
- ✅ Easy to uninstall (just delete the directory)

### Optional: Global Installation

If you want to run `moodfetch` from anywhere on your system, use one of these methods:

#### Option 1: Using make (recommended)

```bash
sudo make install
```

#### Option 2: Using the installation script

```bash
sudo ./install.sh
```

> **Note:** Simple copying to `/usr/local/bin/` won't work because moodfetch requires its module files to be properly installed in the system directories.

## Usage

Basic usage:

```bash
./moodfetch         # Local usage (from repo directory)
# or
moodfetch           # Global usage (if installed globally)
```

Available options:

- `--debug`: Enable debug logging for troubleshooting

## Updating

### Local Installation

```bash
cd moodfetch
git pull
```

> **Note:** Update notifications only appear when running moodfetch from a git repository. If you installed via `make install` without the git repository, updates must be checked manually.

### Global Installation

```bash
cd moodfetch
git pull
sudo make install
```

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
