# Changelog

## [1.1.9] - 2025-09-19

- Refactor: enforce strict two-line output format: first line emoji, second line message. Remove raw metric prints.

## [0.1.8] - 2025-09-18

- Added `.gitignore`

## [0.1.7] - 2025-09-18

- Feature: print a zombie-themed sarcastic line when system uptime > 48 hours (lower priority than low battery).

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
