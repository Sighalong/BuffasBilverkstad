# Changelog

## v0.1.2 (2026-10-18)

Same engine as v0.1.1 (patches 001-092); install fix only.


- macOS: new `Copy game from ISO.command` in the release zip (`tools/copy-game-from-iso.sh`) copies the game out of the `.iso` without mounting it. Modern macOS can't mount the disc's classic HFS side, so double-clicking the `.iso` showed nothing. INSTALL.md and README updated.

## v0.1.1 (2026-10-18)

Same engine as v0.1.0 (patches 001-092, no engine changes); docs and launcher fixes only.

- Docs: DIAG-FLAGS.md now covers every `MULLE_*` test variable and the MDIAG levels; the outdated INPUT-REPLAY.md was removed; notes on dev-only references in INVESTIGATION.md and PATCH-NUMBERS.md; README fixes (patch file names, Windows).
- run.sh creates `build/` for `--trace` logs (needed when running from the release zip).

## v0.1.0 (2026-10-18)

First public release: 92 patches against ScummVM 2026.4.0, plus one macOS SDL2 cursor fix.

- Core loop playable from start to end: name screen (with Å/Ä/Ö), intro, garage, junkyard, yard, driving and map switching, destinations, credits.
- Director 6 sound: score and puppet sounds play out, and looping sounds stay busy, so conversations aren't cut. Sounds start after palette fades, and a fresh sound holds a movie change.
- Director 6 sprites: Lingo changes end with the sprite span, behaviors are recreated for a new span, and empty channels have no span (no stray car on the ignition screen).
- Editable text fields: typing, caret, keyboard focus, colours, scrollTop and line height.
- Saving: the Mulle data cast is kept in memory across movies and saved on quit. Erased players stay erased.
- Fixed crashes: point/rect duplicate, inverted rects, builtins with no result, getaProp on VOID.
- Opt-in diagnostics (`MDIAG` log lines, `MULLE_SHOTS`, `MULLE_CLICKS`, `MULLE_EVAL`), inactive unless set.
- macOS arm64 app package (Director engine only), not notarized.

Per-patch details: docs/PATCHES.md.
