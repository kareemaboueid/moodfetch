#!/usr/bin/env bash
set -e

PREFIX=${PREFIX:-/usr/local}
BINDIR="$PREFIX/bin"
SHAREDIR="$PREFIX/share/moodfetch"
SRCDIR="$(pwd)"

echo "Installing Moodfetch to $BINDIR and $SHAREDIR..."

# Create installation directories
mkdir -p "$BINDIR" "$SHAREDIR/core" "$SHAREDIR/metrics" "$SHAREDIR/config"

# Install main executable
install -m 0755 "$SRCDIR/moodfetch" "$BINDIR/moodfetch"

# Install core modules
for module in utils.sh logging.sh signals.sh update_notifier.sh; do
    if [ -f "$SRCDIR/src/core/$module" ]; then
        install -m 0644 "$SRCDIR/src/core/$module" "$SHAREDIR/core/"
    else
        echo "Warning: Missing core module $module" >&2
    fi
done

# Install metrics modules  
for module in templates.sh metrics.sh mood_engine.sh os_detect.sh; do
    if [ -f "$SRCDIR/src/metrics/$module" ]; then
        install -m 0644 "$SRCDIR/src/metrics/$module" "$SHAREDIR/metrics/"
    else
        echo "Warning: Missing metrics module $module" >&2
    fi
done

# Install configuration
if [ -f "$SRCDIR/config/config.sh" ]; then
    install -m 0644 "$SRCDIR/config/config.sh" "$SHAREDIR/config/"
else
    echo "Warning: Missing config module config.sh" >&2
fi

echo "Moodfetch installed successfully."
