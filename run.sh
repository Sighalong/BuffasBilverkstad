#!/usr/bin/env bash
# Run the game with the patched build. Config and saves stay next to this script.
#   ./run.sh /path/to/game        (the folder holding DATA/, MOVIES/, XTRAS/)
#   ./run.sh /path/to/game --trace   also write a Lingo trace to build/run.log
set -uo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
GAME=${1:?usage: ./run.sh /path/to/game [--trace]}
shift
SVM=$ROOT/build/scummvm-2026.4.0/scummvm
[[ -x $SVM ]] || SVM="$ROOT/Buffas Bilverkstad.app/Contents/MacOS/scummvm"
[[ -x $SVM ]] || { echo "build first (./build.sh) or put Buffas Bilverkstad.app next to run.sh" >&2; exit 1; }
mkdir -p "$ROOT/saves"
INI=$ROOT/scummvm.ini
[[ -f $INI ]] || printf '[scummvm]\nsavepath=%s\nenable_unsupported_game_warning=false\n' "$ROOT/saves" > "$INI"
ARGS=(--config="$INI" --path="$GAME")

if [[ ${1:-} == --trace ]]; then
	shift
	"$SVM" "${ARGS[@]}" --debugflags=lingoexec --debuglevel=2 "$@" garygadget1-win-sv 2>&1 |
		"$ROOT/tools/cap-log.pl" "$ROOT/build/run.log" 20000000 200000
	exit
fi
exec "$SVM" "${ARGS[@]}" "$@" garygadget1-win-sv
