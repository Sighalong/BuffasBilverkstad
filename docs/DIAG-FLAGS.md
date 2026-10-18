# Diagnostics and test hooks

For developers. All of this is off or quiet unless you turn it on; players don't need any of it.

## MDIAG log lines

The patches add one-line event logs: `MDIAG <ms> <area>: ...` (as ScummVM warnings, on stderr).
Areas: `movie`, `go`, `call` (undefined handler, sendSprite miss), `error` (uncaught Lingo error, call stack and
`me` properties), `window` (MIAW), `fileio`, `save`, `sound`, `input` (mouse/key), `loadfail`, `render`, `trans`,
`prog` (game progress flags), `shot`, `replay`.

The level comes from `mdiag` in the `[scummvm]` section of `scummvm.ini`:

| `mdiag=` | Logs |
|---|---|
| `0` | nothing |
| `1` (default) | the events above |
| `2` | also hover, cursor, tempo/frame and slow-frame detail |

## Running with a log

```bash
./run.sh /path/to/game --trace    # Lingo trace (--debugflags=lingoexec --debuglevel=2) + MDIAG, into build/run.log
./run.sh /path/to/game 2>&1 | tee build/run.log    # MDIAG and warnings only (small)
```
`--trace` logs can get very large. `tools/cap-log.pl` (used by `--trace`) keeps the first 20 MB and the last
200,000 lines. Summarise a log with (`log-summary.sh` needs zsh, standard on macOS):
```bash
tools/log-summary.sh [log]          # movies loaded, first fatal error, warning types, MDIAG counts per area, last MDIAG lines
tools/log-summary.sh --diff A B     # what changed between two logs
```

## Environment variables

Set these when starting `run.sh` or `scummvm`, e.g. `MULLE_SHOTS=/tmp/shots ./run.sh /path/to/game`.

| Variable | Effect |
|---|---|
| `MULLE_SHOTS=<dir>` | Saves the stage as `<movie>-f<frame>-<ms>.bmp` in `<dir>` (the folder must exist) at most every 2 s, and logs `MDIAG shot:`. |
| `MULLE_CLICKS=<steps>` | Scripted input, see below. |
| `MULLE_EVAL=<movie>\|<Lingo>` | Runs the Lingo once, 1.5 s after a movie whose name starts with `<movie>` started. Chain steps with `\|\|`: `03\|...\|\|05\|...` (each runs once, in order). `;` inside the Lingo becomes a line break. Example: `MULLE_EVAL='03\|go(1, "92")'`. A scene reached this way skips the game's normal setup, so it's a test aid only, not a way to play. |
| `MULLE_QUITAFTER=<s>` | Posts a quit event after `<s>` seconds, the same as closing the window (tests save-on-quit). |
| `MULLE_AUTOKEY=<vk>` | The KeyPoll Xtra reports this Windows virtual-key code as held (e.g. `38` = Up). |
| `MULLE_TOPOLOG=1` | Logs up to 400 character reads from very long strings (the driving maps' road topology). |

### MULLE_CLICKS format

Steps are separated by `;`. Each step waits for its delay, counted from when the previous step finished:

| Step | Meaning |
|---|---|
| `x,y,ms` | Left click at stage position `x,y`, `ms` milliseconds after the previous step. |
| `x,y,ms,r` | Right click. |
| `key:<c>,ms` | Key press of character `<c>` (`key:enter` = Return). |
| `@<movie> <step>` | Wait until the current movie's name starts with `<movie>` before counting the delay. |

Example (pick the first name on the name screen and press Return):
```bash
MULLE_CLICKS='@10 396,146,1500;key:enter,1300' ./run.sh /path/to/game
```
Each click is sent as a mouse move, a press and a release, a few frames apart, through the same path as real
input. Each step logs `MDIAG replay: step n/N`. Positions depend on the game state, so take them from the
`MDIAG input:` lines of a real run.
