# Changelog

## [0.2.12]

- Auto-disable ANSI colors when output is not a TTY.
- "Mood" header now prints in plain text when piped or redirected.

## [0.2.11]

- Extended GPU model probe with multiple optional tools (`lspci`, `glxinfo`, `nvidia-smi`).
- Added graceful fallback when none available.

## [0.2.10]

- Improved Wi-Fi detection to avoid false positives on non-Wi-Fi systems.
- Added graceful fallback when no interface or signal data available.

## [0.2.9]

- Weather check now fast-fails if internet is offline, avoiding hangs when curl returns empty.
- Added offline fallback message for weather moods.

## [0.2.8]

- Replaced `--metrics` flag with `--verbose` for clarity.
- `--verbose` now shows metrics summary and keeps numbers inside mood text.

## [0.2.7]

- Added automatic stripping of numeric metrics from mood text unless `--metrics` is specified.
- Mood messages now stay sarcastic without exposing raw percentages by default.

## [0.2.6]

- Added `--no-ascii` flag to disable ASCII art logo in output.
- Updated help message to show available options.

## [0.2.5]

- Cleaned output: by default moods no longer show raw numbers.

## [0.2.4]

- Added basic CLI flags:
  - `--no-ascii` → skip ASCII art
  - `--metrics` → print metrics summary after mood
  - `--version` → show version

## [0.2.3]

- Improved performance of CPU/I/O probes by reducing sleeps and adding fast exits.
- Weather moods now use curl with short timeouts (1.5s) and fail fast if unreachable.

## [0.2.2]

- Refactor: modularize project into `moodfetch`, `metrics.sh`, `mood_engine.sh`, `templates.sh`, and `utils.sh`.

## [0.2.1]

- Added random witty fallback moods when all else is boring.

## [0.2.0]

- Added temperature moods.
- Added audio/volume moods (works if `pactl` or `amixer` is installed)
- Both new sensors act as late-stage fallbacks after network and disk checks.

## [0.1.9]

- Added process count moods.

## [0.1.8]

- Added time-of-day moods.
- Time-of-day moods trigger as the ultimate fallback.

## [0.1.7]

- Re-introduced uptime moods as the final fallback:
- Guarantees Moodfetch always prints something smart and expressive.

## [0.1.6]

- Added network connectivity moods:
- Network moods trigger when disk usage looks fine.

## [0.1.5]

- Added disk usage moods:
  - Spacious (<70%)
  - Crowded (<90%)
  - Suffocating (>=90%)
- Terminal now clears before showing ASCII art and mood.

## [0.1.4]

- Added RAM usage moods.
- Memory moods trigger when CPU load is normal:
  - Spacious (<50%)
  - Cluttered (<80%)
  - Jammed (>=80%)

## [0.1.3]

- Added CPU load moods (normalized by core count).
- Three sarcastic ranges:
  - Relaxed (<0.5)
  - Busy but fine (<1.0)
  - Overloaded (>=1.0)
- CPU moods are used when no battery is detected.

## [0.1.2]

- Added battery metrics with moods.
- Battery moods override uptime moods when available.

## [0.1.1]

- Added uptime metric in hours.
- Introduced sarcastic uptime-based moods:
  - Fresh (<1h)
  - Moderate (<24h)
  - Zombie (24h+)
- Added `README.md`.

## [0.1.0] - initial commit

- Initial release of Moodfetch.
