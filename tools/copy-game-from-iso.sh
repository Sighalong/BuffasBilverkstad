#!/usr/bin/env bash
# Copy the game files out of a Mulle Meck bygger bilar .iso without mounting it.
#   copy-game-from-iso.sh [game.iso] [destination folder]
# The disc is a Mac/PC hybrid. Modern macOS can't mount its old Mac (HFS) side, so double-clicking the .iso
# shows nothing; the PC (ISO 9660) side is read directly with the tar that ships with macOS and Linux.
# Without arguments (e.g. double-clicked as "Copy game from ISO.command") it uses the .iso next to it or asks for
# one, and copies to ~/Documents/Mulle game.
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
ISO=${1:-}
DEST=${2:-$HOME/Documents/Mulle game}

ask_iso() {
	osascript -e 'POSIX path of (choose file with prompt "Choose your Mulle Meck bygger bilar .iso file:" of type {"iso", "public.iso-image", "public.disk-image"})' 2>/dev/null
}

if [[ -z $ISO ]]; then
	shopt -s nullglob nocaseglob
	found=("$HERE"/*.iso "$HERE"/../*.iso)
	shopt -u nullglob nocaseglob
	if ((${#found[@]} == 1)); then
		ISO=${found[0]}
	elif [[ $(uname) == Darwin ]]; then
		ISO=$(ask_iso) || { echo "No .iso chosen."; exit 1; }
	else
		echo "usage: $0 game.iso [destination folder]" >&2
		exit 1
	fi
fi
[[ -f $ISO ]] || { echo "Not found: $ISO" >&2; exit 1; }

# GNU tar can't read disc images; bsdtar (the tar on macOS) can
TAR=$(command -v bsdtar || command -v tar)
echo "Reading $ISO"
LIST=$("$TAR" -tf "$ISO" 2>/dev/null) || { echo "This file can't be read as a disc image." >&2; exit 1; }
for d in DATA MOVIES XTRAS; do
	grep -qix "$d" <<<"$LIST" || grep -qi "^$d/" <<<"$LIST" ||
		{ echo "This doesn't look like the Mulle Meck bygger bilar disc (no $d folder)." >&2; exit 1; }
done

if [[ -e $DEST ]] && [[ -n $(ls -A "$DEST" 2>/dev/null) ]]; then
	echo "The folder already exists and isn't empty: $DEST"
	echo "Move or delete it first, then run this again."
	exit 1
fi
mkdir -p "$DEST"
echo "Copying DATA, MOVIES and XTRAS to $DEST (this can take a minute)"
"$TAR" -xf "$ISO" -C "$DEST" DATA MOVIES XTRAS 2>/dev/null || "$TAR" -xf "$ISO" -C "$DEST" data movies xtras
chmod -R u+w "$DEST"

# The game needs FILEIO.X32 in XTRAS as well
fileio=$(find "$DEST" -maxdepth 2 -ipath '*/data/fileio.x32' | head -n 1)
xtras=$(find "$DEST" -maxdepth 1 -iname xtras | head -n 1)
[[ -n $fileio && -n $xtras ]] || { echo "FILEIO.X32 or XTRAS is missing from the disc." >&2; exit 1; }
cp "$fileio" "$xtras/"

echo
echo "Done. Your game folder is: $DEST"
echo "In Buffas Bilverkstad, click Add Game... and choose that folder."
