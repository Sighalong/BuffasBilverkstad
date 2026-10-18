# Changelog

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
