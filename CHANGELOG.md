# Changelog

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
