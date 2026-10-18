# Buffas Bilverkstad

Patches for [ScummVM](https://www.scummvm.org)'s Director engine that make the Swedish 1997 CD-ROM
**Mulle Meck bygger bilar** (English: *Gary Gadget: Building Cars*, ScummVM target `garygadget1-win-sv`)
playable on modern systems, including Apple Silicon Macs, with no CD in the drive.

The game is a Macromedia Director 6 project. Stock ScummVM 2026.4.0 detects the disc but gets stuck at
the name-entry screen. This repository holds a series of engine patches against ScummVM 2026.4.0 that fix
the Director 6 behaviour the game depends on: sound channels, sprite spans, editable text fields, saved
data casts, cursor handling, palette fades and more. The game plays through its main loop: name screen,
garage, junkyard, yard, driving and destinations.

> **No game data is included.** This repository contains only source patches, build scripts and notes.
> It contains no files from the original CD (no `.DXR`, `.CXT`, `.EXE`, `.X32`, sounds, movies or images)
> and no ISO. You need your own legally obtained copy of the game. *Mulle Meck* and the game belong to their respective
> rights holders; this project is not affiliated with them or with the ScummVM team.

**Just want to play?** Follow the step-by-step [install guide](INSTALL.md) for Mac, Windows or Linux. No programming needed.
The rest of this page is the technical version.

## Contents

| Path | What it is |
|---|---|
| `INSTALL.md` | Step-by-step install guide for players (Mac, Windows, Linux) |
| `patches/*.patch` | Engine patches, applied in numeric order to ScummVM 2026.4.0 (`diag-`/`mdiag-` ones add opt-in diagnostics) |
| `patches/sdl/` | One macOS-only SDL2 fix (hidden Cocoa cursor) |
| `build.sh` | Downloads the pinned sources (checksum-verified), applies the patches, builds a Director-only ScummVM |
| `run.sh` | Starts the game with a project-local config and saves |
| `tools/package-macos.sh` | Makes the macOS release zip from a build (checks that no local path ships) |
| `tools/` (others) | Log helpers for debugging (`cap-log.pl`, `log-summary.sh`) |
| `docs/PATCHES.md` | One line per patch: what it fixes and which files it touches |
| `docs/INVESTIGATION.md` | Full investigation log (how each bug was found) |
| `docs/PATCH-NUMBERS.md` | Maps the old 4-digit development numbers to the current ones |
| `docs/DIAG-FLAGS.md` | Opt-in diagnostics and test hooks for developers (MDIAG levels, `MULLE_*` variables) |
| `CHANGELOG.md` | Release history |

## 1. Get the game files from your CD or ISO

You need these folders from the Windows side of the disc, copied into one folder (called `game/` below):

```
game/
  DATA/      (MULLE32.EXE, *.DXR, *.CXT, FILEIO.X32 ...)
  MOVIES/
  XTRAS/
```

Then copy `DATA/FILEIO.X32` into `XTRAS/` as well (the game looks for the FileIO Xtra there).
After copying, the CD or ISO is no longer needed.

**macOS**
1. Double-click the `.iso` (or insert the CD). It appears in Finder under *Locations*. If double-clicking
   doesn't mount it, run `hdiutil attach /path/to/disc.iso` in Terminal.
2. Copy `DATA`, `MOVIES` and `XTRAS` into a new `game` folder, then eject the disc.

**Windows**
1. Right-click the `.iso` → *Mount* (Windows 8 and later), or insert the CD. It gets a drive letter.
2. Copy `DATA`, `MOVIES` and `XTRAS` from that drive into a new `game` folder, then eject the drive.

**Linux**
```bash
mkdir -p ~/mnt/mulle
sudo mount -o loop,ro /path/to/disc.iso ~/mnt/mulle   # or: udisksctl loop-setup -f disc.iso
cp -r ~/mnt/mulle/DATA ~/mnt/mulle/MOVIES ~/mnt/mulle/XTRAS ~/game/
sudo umount ~/mnt/mulle
```
Folder names on the disc may be in lower case on Linux. That's fine: ScummVM matches them case-insensitively.

## 2. Get the engine

**Ready-made (macOS, Apple Silicon).** Download `BuffasBilverkstad-<version>-macOS-arm64.zip` from the
[Releases](https://github.com/Sighalong/BuffasBilverkstad/releases) page and unzip it. It contains
`Buffas Bilverkstad.app` (the patched ScummVM, Director engine only) and `run.sh`. The app is not notarized, so
the first time, right-click it → *Open* (or run `xattr -dr com.apple.quarantine "Buffas Bilverkstad.app"`).
Then use *Add Game…* and pick your `game` folder, or run `./run.sh /path/to/game` next to the app.

**Build it yourself** (all platforms):


**macOS** (Apple Silicon or Intel). Needs only the Xcode command line tools (`xcode-select --install`), no Homebrew:
```bash
./build.sh
```
This builds a static SDL2 and a Director-only ScummVM in `build/` (a few minutes).

**Linux.** Install a compiler and SDL2 dev files (Debian/Ubuntu: `sudo apt install build-essential libsdl2-dev curl`), then:
```bash
./build.sh
```

**Windows.** Use [MSYS2](https://www.msys2.org) (MINGW64 shell):
```bash
pacman -S --needed base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-SDL2 curl
./build.sh
```
If you build ScummVM another way, apply `patches/*.patch` in order to a ScummVM 2026.4.0 source tree
(`patch -p1 < patches/NNN-name.patch`) and build it with the Director engine enabled.

## 3. Play

```bash
./run.sh /path/to/game
```
`run.sh` uses `build/scummvm-2026.4.0/scummvm` when you built it yourself, or `Buffas Bilverkstad.app` when it sits next to it.
Config (`scummvm.ini`) and saves (`saves/`) are created next to `run.sh`, so nothing is written elsewhere.
On Windows, start the built `scummvm.exe` and add the `game` folder with *Add Game…* (`run.sh` is
written for macOS and Linux and is untested under MSYS2).

You can also use the built `scummvm` binary like any ScummVM: start it, choose *Add Game…*, select your `game` folder.

## Status and known issues

Early release: the core loop is playable from start to end (name screen, intro, garage, junkyard, yard,
driving, destinations and back, credits). Known issues:
- Not every destination has been played through yet (82-84, 87-91 and 93 are untested).
- Some conversations (Figge, Ferre) may still be cut short.
- Race-track high-score names may not be shown.
- Quitting asks a "quit anyway?" question while a scene is playing.
- Printing the diploma (PrintOMatic Xtra) does nothing.
- Startup can show a white window for a few seconds before the logo.

The patches also include diagnostics used during development (`MDIAG` log lines, and the `MULLE_SHOTS`,
`MULLE_CLICKS` and `MULLE_EVAL` environment variables). These are inactive unless set; see `docs/DIAG-FLAGS.md`. The full investigation history is in `docs/INVESTIGATION.md`; older entries use 4-digit development
numbers, mapped in `docs/PATCH-NUMBERS.md`.

## Acknowledgements

- The [ScummVM](https://www.scummvm.org) team for the Director engine this builds on.
- dankar89's [mellemuck](https://github.com/dankar89/mellemuck) notes, which pointed to three of the bugs fixed
  here (patches 085, 086, 091). The fixes themselves are our own code.

## License

ScummVM is licensed under the GNU General Public License version 3 or later. These patches modify ScummVM
and are released under the same license; see [LICENSE](LICENSE). The SDL patch is a change to SDL2 (zlib license).
