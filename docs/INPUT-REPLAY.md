# Feasibility: scripted input so smoke tests reach 03/04 unattended (not implemented)

**Verdict: feasible, ~40 lines in one engine file; do not use ScummVM's event recorder.**

## Why not the event recorder
- `ENABLE_EVENTRECORDER` is `#undef`'d in our config.h: needs a rebuild with `--enable-eventrecorder` plus a recorded
  `.r` file made by a human run. Replay is time/random-seed locked (`--record-mode=playback`), so any engine fix that
  changes timing or frame counts desyncs it, and it forces a fixed-seed/no-audio-sync mode. Fragile for a moving target.

## Hook that already exists
`DirectorEngine::pollEvent` (events.cpp:47) first drains `_injectedEvents` (used by the UnitTest XObject), then falls
back to the real event manager. `processSysEvents` consumes events only through it, so injected events take the same
path as real ones (mouse down/up -> `Movie::processSysEvent`, hover enter/leave from position, MDIAG `input:` lines).

## Proposed design (env var `MULLE_CLICKS`)
- Format `"x,y,t[,k];..."`: x,y in stage coords, t = ms since the script started or since the last movie load
  (prefer "after movie 03 loaded" via an optional `@03` prefix, since load times vary); k = `l`(default)|`r`|key char.
- In `pollEvent`, before the real manager: if the script is armed and `getMillis() >= next.t`, push in order
  `EVENT_MOUSEMOVE(x,y)`, then (next call, 50-100 ms later) `LBUTTONDOWN`, then `LBUTTONUP`, setting `event.mouse`.
  Keep a small state machine (`move -> down -> up`) so each click is 3 events spread over >=2 frames; Lingo needs a
  frame between down and up or `mouseDown`/`mouseUp` handlers on one sprite can both fire in the same tick.
- Parse once lazily (static), log one `MDIAG 1 replay: click x,y` per step so log-summary shows where it stopped.

## Gaps / risks
- Clicks must be at the right sprite positions: take them from the MDIAG `input:` lines of one human run
  (sprite id + x,y) rather than guessing; name entry also needs key events (`EVENT_KEYDOWN` with `kbd.ascii`) and text focus.
- `Window::getMousePos()` reads `g_system->getEventManager()->getMousePos()`, not the event: also `warpMouse(x,y)` on each injected move.
- Screen-only dependencies (waits for jingle/animation) make fixed delays flaky: gate each click on "movie N loaded"
  or on an MDIAG-visible state, and accept a timeout -> test reports "stopped at step k".
- smoke-test.sh would just export `MULLE_CLICKS` and compare reached movies (log-summary --diff); no changes to the app.
Effort: ~1 h hook + ~15 min harvesting coordinates; no build-system change.
