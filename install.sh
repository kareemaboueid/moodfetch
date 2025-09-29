#!/usr/bin/env bash
set -e

PREFIX=${PREFIX:-/usr/local}
BINDIR="$PREFIX/bin"
SHAREDIR="$PREFIX/share/moodfetch"
SRCDIR="$(pwd)"

echo "Installing Moodfetch to $BINDIR and $SHAREDIR..."

mkdir -p "$BINDIR" "$SHAREDIR"
install -m 0755 "$SRCDIR/moodfetch" "$BINDIR/moodfetch"
install -m 0644 "$SRCDIR"/*.sh "$SHAREDIR/"
install -m 0644 "$SRCDIR/ascii-art.txt" "$SHAREDIR/"
[ -f "$SRCDIR/ascii-art-mini.txt" ] && install -m 0644 "$SRCDIR/ascii-art-mini.txt" "$SHAREDIR/"

echo "Moodfetch installed successfully."
