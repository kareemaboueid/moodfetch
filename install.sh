#!/usr/bin/env bash
set -e

PREFIX=${PREFIX:-/usr/local}
BINDIR="$PREFIX/bin"
SHAREDIR="$PREFIX/share/moodfetch"
SRCDIR="$(pwd)"

echo "Installing Moodfetch to $BINDIR and $SHAREDIR..."

mkdir -p "$BINDIR" "$SHAREDIR"
install -m 0755 "$SRCDIR/moodfetch" "$BINDIR/moodfetch"

# Core modules (always installed)
for module in utils.sh templates.sh metrics.sh mood_engine.sh config.sh logging.sh os_detect.sh version.sh signals.sh; do
    if [ -f "$SRCDIR/$module" ]; then
        install -m 0644 "$SRCDIR/$module" "$SHAREDIR/"
    else
        echo "Warning: Missing core module $module" >&2
    fi
done

echo "Moodfetch installed successfully."
