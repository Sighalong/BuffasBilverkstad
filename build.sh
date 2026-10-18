#!/usr/bin/env bash
# Build a patched, Director-only ScummVM for Mulle Meck bygger bilar.
# Downloads the pinned ScummVM (and on macOS, SDL2) sources into build/,
# applies patches/*.patch and compiles. Nothing is installed system-wide.
#
#   ./build.sh            build into build/scummvm-2026.4.0/scummvm
#   JOBS=4 ./build.sh     limit parallel jobs
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
B=$ROOT/build
SVM_VER=2026.4.0
SVM_URL=https://github.com/scummvm/scummvm/archive/refs/tags/v$SVM_VER.tar.gz
SVM_SHA=e9615bad3794121be740aef7270fe3bec75e9b372fbaadaf8a07bb8fe2aa016a
SDL_VER=2.30.12
SDL_URL=https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VER/SDL2-$SDL_VER.tar.gz
SDL_SHA=ac356ea55e8b9dd0b2d1fa27da40ef7e238267ccf9324704850d5d47375b48ea
OS=$(uname -s)
if [[ $OS == Darwin ]]; then JOBS=${JOBS:-$(sysctl -n hw.ncpu)}; else JOBS=${JOBS:-$(nproc 2>/dev/null || echo 4)}; fi

sha256() { if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi; }

fetch() { # url sha file
	[[ -f $3 ]] || curl -fL --retry 3 -o "$3" "$1"
	local got; got=$(sha256 "$3")
	[[ $got == "$2" ]] || { echo "checksum mismatch for $3: $got" >&2; exit 1; }
}

mkdir -p "$B"
cd "$B"
# Keep local build paths (and so the user name) out of the binaries
export CFLAGS="${CFLAGS:-} -ffile-prefix-map=$B=build"
export CXXFLAGS="${CXXFLAGS:-} -ffile-prefix-map=$B=build"

# ScummVM source, patched once (a .patched marker keeps reruns idempotent)
fetch "$SVM_URL" "$SVM_SHA" scummvm-$SVM_VER.tar.gz
if [[ ! -f scummvm-$SVM_VER/.patched ]]; then
	rm -rf scummvm-$SVM_VER
	tar xzf scummvm-$SVM_VER.tar.gz
	for p in "$ROOT"/patches/*.patch; do
		echo "apply ${p##*/}"
		patch -d scummvm-$SVM_VER -p1 -s --no-backup-if-mismatch < "$p"
	done
	touch scummvm-$SVM_VER/.patched
fi

CONF=(--disable-all-engines --enable-engine=director --enable-release --disable-debug)

if [[ $OS == Darwin ]]; then
	# Static SDL2 with a small Cocoa cursor fix, so the app needs no Homebrew.
	fetch "$SDL_URL" "$SDL_SHA" SDL2-$SDL_VER.tar.gz
	if [[ ! -x deps/bin/sdl2-config ]]; then
		rm -rf SDL2-$SDL_VER
		tar xzf SDL2-$SDL_VER.tar.gz
		for p in "$ROOT"/patches/sdl/*.patch; do patch -p0 -s < "$p"; done
		(cd SDL2-$SDL_VER && ./configure --prefix="$B/deps" --disable-shared --enable-static && make -j"$JOBS" && make install)
	fi
	export PATH=$B/deps/bin:$PATH
	CONF+=(--with-sdl-prefix="$B/deps")
fi

cd scummvm-$SVM_VER
[[ -f config.mk ]] || ./configure "${CONF[@]}"
make -j"$JOBS"
echo "Built $B/scummvm-$SVM_VER/scummvm"
