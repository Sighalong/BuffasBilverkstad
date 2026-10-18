# Buffas Bilverkstad

[![Latest release](https://img.shields.io/github/v/release/Sighalong/BuffasBilverkstad)](https://github.com/Sighalong/BuffasBilverkstad/releases/latest)
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue)](LICENSE)

Play the 1997 Swedish CD-ROM game **Mulle Meck bygger bilar** (English: *Gary Gadget: Building Cars*) on
modern computers, including Apple Silicon Macs, with no CD in the drive.

Buffas Bilverkstad is a set of patches for the Director engine in [ScummVM](https://www.scummvm.org) 2026.4.0.
Stock ScummVM recognises the game but gets stuck at the name screen. With these patches, the whole game loop
plays: the name screen, garage, junkyard, yard, driving and destinations.

> **Just want to play?** Follow the step-by-step **[install guide](INSTALL.md)** for Mac, Windows or Linux.
> No programming needed.

> [!IMPORTANT]
> **No game data is included.** You need your own legally obtained copy of the game, on CD or as an ISO.
> This repository contains only source patches, scripts and documentation: no files from the original disc and
> no disc image. *Mulle Meck* belongs to its respective rights holders. This project is not affiliated with them
> or with the ScummVM team.

## Contents

- [Quick start](#quick-start)
- [Requirements](#requirements)
- [Preparing the game files](#preparing-the-game-files)
- [Building from source](#building-from-source)
- [Running](#running)
- [Status and known issues](#status-and-known-issues)
- [How it works](#how-it-works)
- [Repository layout](#repository-layout)
- [Reporting problems](#reporting-problems)
- [Acknowledgements](#acknowledgements)
- [License](#license)

## Quick start

**macOS (Apple Silicon):**
1. Download `BuffasBilverkstad-<version>-macOS-arm64.zip` from
   [Releases](https://github.com/Sighalong/BuffasBilverkstad/releases/latest) and unzip it.
2. Open `Buffas Bilverkstad.app`. It isn't notarized, so the first time, allow it under *System Settings →
   Privacy & Security → Open Anyway*.
3. Click *Add Game…*, choose your [game folder](#preparing-the-game-files), then click *Start*.

**Other platforms:** [build from source](#building-from-source), then run:

```bash
./run.sh /path/to/game
```

## Requirements

| | Ready-made download | Build from source |
|---|---|---|
| **macOS** | Apple Silicon (arm64) | Apple Silicon or Intel, with the Xcode command line tools |
| **Linux** | not available | A C++ compiler, `make`, `patch`, `curl` and the SDL2 development files |
| **Windows** | not available | [MSYS2](https://www.msys2.org) with the MINGW64 toolchain and SDL2 |

macOS builds are tested. Linux and Windows builds are untested so far.

## Preparing the game files

You need three folders from the disc, copied into one folder (called `game/` here):

```
game/
├── DATA/      MULLE32.EXE, *.DXR, *.CXT, FILEIO.X32, ...
├── MOVIES/
└── XTRAS/     plus a copy of DATA/FILEIO.X32
```

**From an `.iso` (any system with bsdtar, including every Mac):** no mounting needed.

```bash
tools/copy-game-from-iso.sh disc.iso game
```

It copies `DATA`, `MOVIES` and `XTRAS` and puts the extra copy of `FILEIO.X32` in place. In the macOS release zip
the same script is the double-clickable `Copy game from ISO.command`. Modern macOS can't mount this ISO: the disc
is a Mac/PC hybrid, and macOS no longer reads its classic HFS side.

**By hand (CD, or a mounted ISO on Windows or Linux):**

1. Mount the ISO or insert the CD:
   - **Windows:** right-click the `.iso` and choose *Mount*.
   - **Linux:** open it with your file manager, or run `sudo mount -o loop,ro disc.iso /mnt`.
2. Copy `DATA`, `MOVIES` and `XTRAS` into `game/`.
3. Copy `DATA/FILEIO.X32` into `XTRAS/`. The game looks for its FileIO Xtra there.
4. Unmount the disc. It is no longer needed.

Folder names may show in lower case on Linux. That's fine, because ScummVM matches them case-insensitively.

## Building from source

`build.sh` downloads the pinned ScummVM 2026.4.0 source (and on macOS, SDL2 2.30.12) and checks their
SHA-256 sums. It then applies `patches/*.patch` in order and builds a Director-only ScummVM into `build/`.
Nothing is installed system-wide.

**macOS.** Homebrew isn't needed. SDL2 is built statically with a small cursor fix.
```bash
xcode-select --install   # once, if you don't have the command line tools
./build.sh
```

**Linux (Debian/Ubuntu shown):**
```bash
sudo apt install build-essential libsdl2-dev curl
./build.sh
```
Fedora: `gcc-c++ make patch SDL2-devel curl`. Arch: `base-devel sdl2 curl`.

**Windows (MSYS2 MINGW64 shell):**
```bash
pacman -S --needed base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-SDL2 curl
./build.sh
```

Set `JOBS=4 ./build.sh` to limit parallel jobs. Reruns are incremental.

**Using your own ScummVM tree.** Apply the patches in numeric order to a ScummVM 2026.4.0 source tree, then
build with the Director engine enabled:
```bash
for p in patches/*.patch; do patch -p1 < "$p"; done
```

**Packaging (macOS).** `tools/package-macos.sh v0.1.1` turns a build into the release zip and its `.sha256`.
It refuses to package if a local path or user name would ship.

## Running

```bash
./run.sh /path/to/game            # play
./run.sh /path/to/game --trace    # play and write a Lingo trace to build/run.log
```

- `run.sh` uses `build/scummvm-2026.4.0/scummvm` if you built it. Otherwise it uses `Buffas Bilverkstad.app`
  when the app is in the same folder.
- `run.sh` keeps everything next to itself: the config in `scummvm.ini` and saved games in `saves/`.
- The patched binary also works like any other ScummVM: start it, choose *Add Game…* and select the game folder.
- On Windows, start `build/scummvm-2026.4.0/scummvm.exe` from the MINGW64 shell (it needs the MSYS2 DLLs on
  `PATH`). `run.sh` is untested under MSYS2.

## Status and known issues

This is an early release. The game is playable from start to end: name screen, intro, garage, junkyard, yard,
driving, destinations and the credits.

Known issues:
- Not every destination has been played through (82–84, 87–91 and 93 are untested).
- Some conversations (Figge, Ferre) may be cut short.
- Race-track high-score names may not be shown.
- Quitting while a scene is playing asks a "quit anyway?" question.
- Printing the diploma (PrintOMatic Xtra) does nothing.
- Startup may show a white window for a few seconds before the logo.

See [CHANGELOG.md](CHANGELOG.md) for what changed in each release.

## How it works

The game is a Macromedia Director 6 project (ScummVM target `garygadget1-win-sv`). The patches fix the
Director 6 behaviour it relies on, including:
- sound channels
- sprite spans and behaviors
- editable text fields
- the saved-data cast
- cursors
- palette fades
- several Lingo built-ins

Every patch is a plain diff against ScummVM 2026.4.0 with a descriptive header:

- [docs/PATCHES.md](docs/PATCHES.md) has one line per patch: what it fixes and which files it touches.
- [docs/INVESTIGATION.md](docs/INVESTIGATION.md) is the full log of how each bug was found.
  Older entries use 4-digit development numbers; [docs/PATCH-NUMBERS.md](docs/PATCH-NUMBERS.md) maps them to the current ones.
- [docs/DIAG-FLAGS.md](docs/DIAG-FLAGS.md) covers the opt-in diagnostics for developers: `MDIAG` log lines and
  the `MULLE_*` test variables. They are inactive unless you turn them on.

## Repository layout

| Path | Purpose |
|---|---|
| `INSTALL.md` | Step-by-step install guide for players |
| `build.sh` | Downloads, verifies, patches and builds |
| `run.sh` | Starts the game with a project-local config and saves |
| `patches/NNN-*.patch` | Engine patches, applied in numeric order (`diag-`/`mdiag-` patches add opt-in diagnostics) |
| `patches/sdl/` | macOS-only SDL2 fix (hidden Cocoa cursor) |
| `tools/package-macos.sh` | Builds the macOS release zip |
| `tools/cap-log.pl`, `tools/log-summary.sh` | Log capping and summaries for debugging (`log-summary.sh` needs zsh) |
| `docs/` | Patch list, investigation log, diagnostics |
| `CHANGELOG.md` | Release history |

## Reporting problems

Open an [issue](https://github.com/Sighalong/BuffasBilverkstad/issues) and include:
- your OS and version
- the release or commit you used
- what you did just before the problem

A log helps a lot. `./run.sh /path/to/game 2>&1 | tee run.log` captures the `MDIAG` event lines. Logs never contain
game data. They may contain the folder paths on your computer, so check them before posting.

## Acknowledgements

- The [ScummVM](https://www.scummvm.org) team, for the Director engine this builds on.
- dankar89's [mellemuck](https://github.com/dankar89/mellemuck) notes, which pointed to three of the bugs fixed
  here (patches 085, 086 and 091). The fixes are our own code.

## License

ScummVM is licensed under the GNU General Public License, version 3 or later. These patches modify ScummVM and
are released under the same license (see [LICENSE](LICENSE)). The SDL patch modifies SDL2, which uses the zlib
license.
