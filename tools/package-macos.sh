#!/usr/bin/env bash
# Package the macOS build as "Buffas Bilverkstad.app" in a zip (run ./build.sh first).
#   tools/package-macos.sh v0.1.0   ->  build/pkg/BuffasBilverkstad-v0.1.0-macOS-<arch>.zip (+ .sha256)
# Checks that no local path or user name ended up in the package.
set -euo pipefail

VER=${1:?usage: tools/package-macos.sh <version tag, e.g. v0.1.0>}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SVM=$ROOT/build/scummvm-2026.4.0
[[ -x $SVM/scummvm ]] || { echo "build first: ./build.sh" >&2; exit 1; }
ARCH=$(lipo -archs "$SVM/scummvm")
NAME=BuffasBilverkstad-$VER-macOS-${ARCH// /-}
OUT=$ROOT/build/pkg
D=$OUT/$NAME
APP=$D/Buffas\ Bilverkstad.app

rm -rf "$D" "$OUT/$NAME.zip" "$OUT/$NAME.zip.sha256"
mkdir -p "$D/tools"

# ScummVM's own bundle layout (themes, fonts, engine data), with our binary
(cd "$SVM" && rm -rf ScummVM.app && make bundle-pack >/dev/null 2>&1 || true)
[[ -d $SVM/ScummVM.app/Contents/Resources ]] || { echo "bundle-pack failed" >&2; exit 1; }
mv "$SVM/ScummVM.app" "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$SVM/scummvm" "$APP/Contents/MacOS/scummvm"
chmod 755 "$APP/Contents/MacOS/scummvm"
strip "$APP/Contents/MacOS/scummvm"
P=$APP/Contents/Info.plist
plutil -replace CFBundleIdentifier -string io.github.sighalong.buffasbilverkstad "$P"
plutil -replace CFBundleName -string "Buffas Bilverkstad" "$P"
plutil -replace CFBundleDisplayName -string "Buffas Bilverkstad" "$P" 2>/dev/null ||
	plutil -insert CFBundleDisplayName -string "Buffas Bilverkstad" "$P"
codesign -s - --deep --force "$APP"

cp "$ROOT"/{LICENSE,README.md,INSTALL.md,CHANGELOG.md,run.sh} "$D/"
cp "$ROOT/tools/cap-log.pl" "$D/tools/"
cat > "$D/SOURCE.txt" <<EOF
Buffas Bilverkstad $VER: ScummVM 2026.4.0 (Director engine only) with the patches from
https://github.com/Sighalong/BuffasBilverkstad (tag $VER), licensed GPL-3.0-or-later (see LICENSE).
Complete corresponding source: that tag, https://github.com/scummvm/scummvm/archive/refs/tags/v2026.4.0.tar.gz
and SDL2 2.30.12 (zlib license); build with ./build.sh from the repository.
No game data is included. You need your own copy of Mulle Meck bygger bilar.
EOF

# Nothing personal or local may ship
if grep -rlaE "/Users/|/home/|$(id -un)" "$D"; then
	echo "local path or user name found in the package (above); not zipping" >&2
	exit 1
fi

(cd "$OUT" && ditto -c -k --keepParent "$NAME" "$NAME.zip" && shasum -a 256 "$NAME.zip" > "$NAME.zip.sha256")
echo "Packaged $OUT/$NAME.zip"
cat "$OUT/$NAME.zip.sha256"
