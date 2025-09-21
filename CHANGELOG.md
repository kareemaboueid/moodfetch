# Changelog

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
