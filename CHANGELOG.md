# Changelog

## [0.1.6] - 2025-09-18

- Feature: if battery < 20% and not charging, print a sarcastic low-battery message.

## [0.1.5] - 2025-09-18

- Bugfix: correctly convert float uptime seconds from `/proc/uptime` to integer hours with `awk`.

- Read battery percentage if available.

## [0.1.4] - 2025-09-18

- Added crude battery percentage detection from `/sys/class/power_supply/BAT0/capacity`.

## [0.1.3] - 2025-09-18

- Added uptime detection from `/proc/uptime`.

## [0.1.2] - 2025-09-18

- A little polish to the README.md file.

## [0.1.1] - 2025-09-18

- made a logo for moodfetch
- Initiated `README.md` and `CHANGELOG.md`
- Added moodfetch logo to `README.md`

## [0.1.0] - initial commit

- Initial commit with a basic test script.
