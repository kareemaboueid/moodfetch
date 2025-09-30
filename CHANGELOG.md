# Changelog

## Latest

- **Improved installation documentation**
  - Added simple local setup as the recommended installation method
  - No sudo required, safer and easier for users
  - Clear instructions for both local and global usage
  - Added updating instructions for both installation types
  - Clarified that global installation requires proper installers

- **Added lightweight update notifier**
  - Fully decoupled from installation method
  - Only works in git repositories (graceful skip in other environments)
  - Update checking logic built into main script (no separate module)
  - Installation scripts remain git-agnostic for pure file copying
  - Non-blocking update checks using git ls-remote or GitHub API fallback
  - Fast 1.5s timeout to avoid delays in mood generation
  - Shows friendly notification when updates are available
  - Provides exact update commands with current repository path

- **Removed version support completely**
  - Deleted --version and --check-update CLI flags
  - Removed version.sh module and all version tracking
  - Cleaned up version references from documentation
  - Simplified CLI interface to focus on core mood functionality

- **Complete offline refactoring**: Removed all network-dependent features
  - Disabled update checking that used curl/GitHub API
  - Removed Wi-Fi signal strength detection via nmcli  
  - Replaced wifi_weak_tpl with net_offline_tpl for better offline experience
  - All functionality now operates completely offline for faster, more reliable execution

- **Improved user experience with placeholder output**
  - Added temporary "hmm..." placeholder during mood generation
  - Implements clean terminal clearing using ANSI escape sequences
  - Provides immediate feedback while system metrics are being collected
  - Works consistently across most Linux terminal environments

- **Enhanced stability and safety**
  - Added numeric validation to prevent arithmetic errors in mood engine
  - Improved error handling for system metrics collection
  - Updated humor and fallback messages to remove network references
  - Better handling of edge cases in process and network checks

## Previous Release

- Removed weather functionality for offline-only moods
  - Eliminated external API dependencies (ipinfo.io, wttr.in)
  - Simplified mood engine to focus only on local system metrics
  - Faster, more reliable operation without network delays
  - All moods now based purely on device performance and status

- Comprehensive code cleanup and bug fixes
  - Fixed syntax errors in mood_engine.sh and other core files
  - Removed duplicate function definitions in os_detect.sh
  - Added numeric validation to prevent arithmetic errors
  - Cleaned up unused templates and placeholder code
  - Enhanced error handling throughout the codebase
  - Improved production stability and reliability

## Historical Release

- Fixed incorrect module sourcing path in metrics.sh
  - Corrected os_detect.sh import path from script_dir to metrics subdirectory
  - Ensures OS detection functionality works properly
- Completed os_detect.sh implementation for Linux-only support
  - Added missing OS constants and CURRENT_OS variable
  - Fixed incomplete init_os_detect function with proper case statement
  - Added Linux distribution detection
  - Implemented all missing public interface functions
  - Removed incomplete cross-platform code to focus on Linux
- Cleaned up minor code duplication and undefined variables
  - Removed duplicate exit statement in --check-update flag handling
  - Added default values for verbose and no_color variables to prevent errors
- Fixed install.sh to match current directory structure
  - Updated module installation paths to use src/core and src/metrics subdirectories
  - Added proper directory structure creation during installation
  - Fixed module lookup paths to match reorganized project layout
- Removed unused macOS and BSD probe references
  - Cleaned up metrics collection to focus on Linux-only functionality
  - Removed calls to non-existent macOS and BSD probe functions  
  - Simplified collect_all_metrics function for Linux-only support
  - Added warning for unsupported operating systems

## Historical Release

- Reorganized project structure
  - Created organized directory hierarchy
  - Separated core and metrics modules
  - Centralized configuration management
  - Improved asset organization
- Build system improvements
  - Updated Makefile for new structure
  - Improved installation process
  - Better dependency handling
  - Clearer installation messages
- Documentation updates
  - Added project structure documentation
  - Improved installation instructions
  - Updated configuration guide

## Historical Release

- Simplified project structure
  - Removed theme system in favor of classic sarcastic personality
  - Removed additional theme files and configurations
  - Streamlined installation process
  - Simplified configuration options
- Performance improvements
  - Reduced code complexity
  - Removed unused theme management code
  - Optimized template loading

## Historical Release

- Refactored for Linux-only support
  - Removed macOS and BSD support modules
  - Streamlined OS detection for Linux distributions
  - Optimized metrics collection for Linux interfaces
  - Simplified installation process
  - Updated documentation for Linux-only support
- Performance improvements
  - Direct access to Linux system interfaces
  - Removed cross-platform compatibility overhead
  - Faster metric collection using native Linux APIs

## Historical Release

- Added comprehensive signal handling
  - Added signals.sh module for graceful process management
  - Proper cleanup of temporary files and background processes
  - Graceful handling of SIGINT, SIGTERM, and SIGHUP
  - Improved error reporting on abnormal termination
- Enhanced process management
  - Automatic cleanup of background processes
  - Improved temporary file handling
  - Safer resource management

## Historical Release

- Added version management system
  - Added version.sh module for version handling
  - Implemented GitHub API-based update checking
  - Added --version and --check-update flags
  - Version comparison and parsing utilities
- Enhanced documentation
  - Added version management documentation
  - Updated CLI flag documentation
  - Added update checking instructions

## Historical Release

- Added comprehensive theme system
  - New theme manager with support for custom themes
  - Added professional and friendly built-in themes
  - Theme cycling support with exclusion lists
  - User and system-wide theme directories
- Enhanced configuration
  - Added theme-related configuration options
  - Theme loading with fallback chain
- Improved documentation
  - Added theme creation guide
  - Documented theme system architecture
  - Added custom theme examples

## Historical Release

- Added comprehensive cross-platform support
  - New OS detection module with platform-specific capabilities
  - Native macOS support using ioreg, sysctl, and powermetrics
  - Initial BSD support with sysctl and procfs integration
  - Modular metric collection based on available system interfaces
- Updated installation process
  - Platform-aware module installation
  - Improved dependency handling
- Enhanced documentation
  - Platform-specific requirements and features
  - Cross-platform compatibility notes
  - Updated installation instructions

## Historical Release

- Added comprehensive GPU metrics collection with multi-vendor support
  - Temperature monitoring for NVIDIA, Intel, and AMD GPUs
  - Utilization tracking with driver-specific methods
  - GPU memory usage monitoring
  - Smart fallbacks for different hardware
- Added real-time I/O metrics
  - Network bandwidth monitoring (rx/tx rates)
  - Disk read/write rates
  - Process count tracking
- Added new mood templates for hardware states
  - GPU temperature and utilization
  - Network bandwidth usage
  - Process count warnings
- Updated configuration with new thresholds
  - GPU temperature and utilization limits
  - Network bandwidth thresholds
  - Process count warning levels
  - Disk I/O warning thresholds

## Historical Release

- Added robust error handling and logging system
- Added --debug flag for troubleshooting
- Added structured logging with timestamp and severity levels
- Added try_cmd helper for safer command execution
- Improved error messages with more context
- Added color-coded log output (auto-disabled in non-TTY)

- Added configuration system with support for both user (~/.config/moodfetch/config) and system-wide (/etc/moodfetch/config) settings
- Added configurable thresholds for warnings (battery, CPU, RAM, disk)
- Added example configuration file
- Made color scheme, ASCII art preferences, and metrics display configurable
- Updated installation to include example config file

## Historical Release

- Removed unused `gpu_model` metric probe to simplify codebase.
- Unified version number across CLI and CHANGELOG (now 0.3.2).
- Improved help message with full options table + tip for syntax check.
- Placeholders with empty values now default to "N/A" for clarity.

## Historical Release

- Removed unused `{gpu_model}` placeholder from templates and rendering logic.
- Cleaned utils.sh keys list to match active placeholders only.

## Historical Release

- Removed `clear` before printing output; mood now appears inline without screen wipe.
- Standardized missing metric values to `N/A` instead of `?`.
- Faster weather fallback with sarcastic offline message.
- Added `--compact-ascii` option to show smaller logo.
- Removed unused placeholder `{gpu_model}` from templates.
- Updated README with options table and contributing section.
- Added `install.sh` as alternative to Makefile installation.

## Historical Release

- Auto-detect non-TTY environments and disable ANSI colors automatically.
- Prevents ugly escape sequences when piping output to files or logs.

## Historical Release

- Made GPU probe more flexible.
- Added fallbacks: `glxinfo` and `vainfo` if `lspci` is unavailable.
- Gracefully leaves GPU field blank if no tools are present.

## Historical Release

- Improved Wi-Fi detection fallback.
- Now avoids false positives on systems without Wi-Fi hardware.
- `wifi_signal` stays empty if no Wi-Fi interfaces exist.

## Historical Release

- Added faster offline weather fallback when curl returns empty or internet is down.
- Weather now prints a default sarcastic line instead of stalling.

## Historical Release

- Auto-disable ANSI colors when output is not a TTY.
- "Mood" header now prints in plain text when piped or redirected.

## Historical Release

- Extended GPU model probe with multiple optional tools (`lspci`, `glxinfo`, `nvidia-smi`).
- Added graceful fallback when none available.

## Historical Release

- Improved Wi-Fi detection to avoid false positives on non-Wi-Fi systems.
- Added graceful fallback when no interface or signal data available.

## Historical Release

- Weather check now fast-fails if internet is offline, avoiding hangs when curl returns empty.
- Added offline fallback message for weather moods.

## Historical Release

- Replaced `--metrics` flag with `--verbose` for clarity.
- `--verbose` now shows metrics summary and keeps numbers inside mood text.

## Historical Release

- Added automatic stripping of numeric metrics from mood text unless `--metrics` is specified.
- Mood messages now stay sarcastic without exposing raw percentages by default.

## Historical Release

- Added `--no-ascii` flag to disable ASCII art logo in output.
- Updated help message to show available options.

## Historical Release

- Cleaned output: by default moods no longer show raw numbers.

## Historical Release

- Added basic CLI flags:
  - `--no-ascii` → skip ASCII art
  - `--metrics` → print metrics summary after mood
  - `--version` → show version

## Historical Release

- Improved performance of CPU/I/O probes by reducing sleeps and adding fast exits.
- Weather moods now use curl with short timeouts (1.5s) and fail fast if unreachable.

## Historical Release

- Refactor: modularize project into `moodfetch`, `metrics.sh`, `mood_engine.sh`, `templates.sh`, and `utils.sh`.

## Historical Release

- Added random witty fallback moods when all else is boring.

## Historical Release

- Added temperature moods.
- Added audio/volume moods (works if `pactl` or `amixer` is installed)
- Both new sensors act as late-stage fallbacks after network and disk checks.

## Historical Release

- Added process count moods.

## Historical Release

- Added time-of-day moods.
- Time-of-day moods trigger as the ultimate fallback.

## Historical Release

- Re-introduced uptime moods as the final fallback:
- Guarantees Moodfetch always prints something smart and expressive.

## Historical Release

- Added network connectivity moods:
- Network moods trigger when disk usage looks fine.

## Historical Release

- Added disk usage moods:
  - Spacious (<70%)
  - Crowded (<90%)
  - Suffocating (>=90%)
- Terminal now clears before showing ASCII art and mood.

## Historical Release

- Added RAM usage moods.
- Memory moods trigger when CPU load is normal:
  - Spacious (<50%)
  - Cluttered (<80%)
  - Jammed (>=80%)

## Historical Release

- Added CPU load moods (normalized by core count).
- Three sarcastic ranges:
  - Relaxed (<0.5)
  - Busy but fine (<1.0)
  - Overloaded (>=1.0)
- CPU moods are used when no battery is detected.

## Historical Release

- Added battery metrics with moods.
- Battery moods override uptime moods when available.

## Historical Release

- Added uptime metric in hours.
- Introduced sarcastic uptime-based moods:
  - Fresh (<1h)
  - Moderate (<24h)
  - Zombie (24h+)
- Added `README.md`.

## Historical Release - initial commit

- Initial release of Moodfetch.
