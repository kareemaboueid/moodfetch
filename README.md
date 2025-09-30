<p align="center">
  <img src="https://raw.githubusercontent.com/kareemaboueid/moodfetch/refs/heads/main/logo/moodfetch.png" alt="Moodfetch Logo" width="300"/>
</p>

<h1 align="center" dir="auto">moodfetch</h1>

<p align="center" dir="auto">A command-line tool for displaying your system's "mood"</p>

Moodfetch displays your system's "mood" by fetching and presenting various system information in a visually appealing way. Your system definitely has something to say!

## Requirements

### Core Requirements

- bash 4.0+
- make (for installation via `make install`)

### Platform-Specific Requirements

#### Linux

- procfs and sysfs mounted (standard on most distributions)
- Optional:
  - `curl` → weather moods
  - `nmcli` → Wi-Fi signal strength
  - `pactl` / `amixer` → audio volume moods
  - `nvidia-smi` → NVIDIA GPU metrics
  - `intel_gpu_top` → Intel GPU metrics
  - `radeontop` → AMD GPU metrics

#### macOS

- Xcode Command Line Tools (for basic compilation tools)
- Optional:
  - `smckit` → CPU temperature monitoring
  - Root access → detailed CPU/GPU metrics via powermetrics
  - `osascript` → volume control monitoring

#### BSD Systems

- Base system with sysctl support
- Optional:
  - procfs mounted → enhanced CPU/memory metrics
  - `curl` → weather moods

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

Just run:

```bash
moodfetch
```

## Configuration

Moodfetch can be configured using either:

- System-wide config: `/etc/moodfetch/config`
- User config: `~/.config/moodfetch/config`

Copy the example config file to get started:

```bash
# For current user only:
mkdir -p ~/.config/moodfetch/
cp /etc/moodfetch/config.example ~/.config/moodfetch/config

# Or system-wide:
sudo cp /etc/moodfetch/config.example /etc/moodfetch/config
```

Configuration options include display preferences, warning thresholds, and theme settings.
CLI flags override config file settings.

### Themes

Moodfetch supports different personality themes for system messages:

- `sarcastic` (default) - Witty and humorous
- `professional` - Formal and business-like
- `friendly` - Helpful and encouraging

To switch themes, edit your config file:

```bash
# In ~/.config/moodfetch/config:
theme=professional  # Choose: sarcastic, professional, or friendly
```

#### Custom Themes

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
| `--no-ascii`     | Skip ASCII logo                              |
| `--compact-ascii`| Show smaller ASCII logo instead of full one  |
| `--verbose`      | Show metrics summary with numbers            |
| `--debug`        | Enable debug logging for troubleshooting     |
| `--version`      | Show version and exit                        |
| `--help, -h`     | Show help                                    |

## Contributing

Contributions are welcome!  
Feel free to fork the repo, create feature branches, and submit pull requests.  
For major changes, please open an issue first to discuss what you’d like to change.

### Example

<p>
  <img src="https://raw.githubusercontent.com/kareemaboueid/moodfetch/refs/heads/main/moodfetch-screenshot1.png" alt="Moodfetch Screenshot" width="400"/>
</p>

## License

[MIT](./LICENSE)
