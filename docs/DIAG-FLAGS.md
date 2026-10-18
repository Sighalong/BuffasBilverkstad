# Diagnostics for the one batched play-test run (patches 0030-0031)

Each event is one line `MDIAG <ms> <area>: ...` in the normal log. Areas: movie, go, call (undefined handler,
sendSprite miss), error (uncaught Lingo error + call stack), window (MIAW), fileio, save, sound, input
(mouse/key, now|queued), loadfail, shot; level 2 adds hover, cursor(), tempo/frame and 05 map sprite lines.

## Run (level 1 is the default, no flags needed)
```
tools/run-game.sh --trace      # = --debugflags=lingoexec --debuglevel=2, log in build/run.log
```
Without --trace only MDIAG/warnings are kept: `tools/run-game.sh 2>&1 | tee build/run.log` (small, whole session).
Level 2: put `mdiag=2` in the `[scummvm]` section of scummvm.ini (0 = off). `MULLE_TAIL=1000000` keeps more trace lines.
`MULLE_SHOTS=<existing dir> tools/run-game.sh` saves `<movie>-f<frame>-<ms>.bmp` every 2 s (logs `MDIAG shot:`).

## Read it
```
tools/log-summary.sh [log]           # ends with MDIAG counts per area + last 15 MDIAG lines before the first fatal
tools/log-summary.sh --diff A B      # movies / MDIAG areas / fatals new or gone between two logs
tools/shots-summary.sh <dir>         # changed shots, ALL-WHITE/BLACK flags, <dir>/contact.png
tools/lingo-lint.sh                  # engine gaps vs the game's Lingo ("X of sprite" hits are behaviour props)
grep -a 'MDIAG [0-9]* fileio:' build/run.log     # one area
```
Play order: logo -> name screen -> 03 garage -> 04 yard (MIAW 18) -> 05 driving/map -> 06/13 save+load car -> quit.
Unattended: `tools/replay-test.sh [script] [secs] [target]` replays docs/replay-name-to-garage.txt via MULLE_CLICKS (patch 0037), log build/replay.log.
Scenarios: docs/replay-garage-to-driving.txt (to 05), `tools/replay-test.sh --persist` (M8 save/relaunch/restore). Exit 0 PASS, 1 FAIL, 2 fatal.
- MULLE_QUITAFTER=<s>: posts a quit event after s seconds (same path as closing the window); used to test save-on-close (P0044).
