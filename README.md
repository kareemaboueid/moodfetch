<p align="center">
  <img src="https://raw.githubusercontent.com/kareemaboueid/moodfetch/refs/heads/main/logo/moodfetch.png" alt="Moodfetch Logo" width="300"/>
</p>

<h1 align="center" dir="auto">moodfetch</h1>

<p align="center" dir="auto">A command-line tool for displaying your system's "mood"</p>

Moodfetch displays your system's "mood" by fetching and presenting various system information in a visually appealing way. Your system definitely has something to say!

## Requirements

- bash
- make (for installation via `make install`)  
- Optional extras:
  - `curl` → weather moods  
  - `nmcli` → Wi-Fi signal strength  
  - `pactl` / `amixer` → audio volume moods

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

## Options

| Flag             | Description                                  |
|------------------|----------------------------------------------|
| `--no-ascii`     | Skip ASCII logo                              |
| `--compact-ascii`| Show smaller ASCII logo instead of full one  |
| `--verbose`      | Show metrics summary with numbers            |
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
