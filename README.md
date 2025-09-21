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

### Example

<p>
  <img src="https://raw.githubusercontent.com/kareemaboueid/moodfetch/refs/heads/main/moodfetch-screenshot1.png" alt="Moodfetch Screenshot" width="400"/>
</p>

## License

[MIT](./LICENSE)
