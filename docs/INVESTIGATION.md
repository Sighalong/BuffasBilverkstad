# Investigation log

Current state and open work: docs/STATUS.md and docs/BACKLOG.md. This file is the history of what was found and fixed; the patch for each fix is in `patches/` (numbered, one commit each in build/src). Sections marked "(open)" below were resolved later unless the text says otherwise.

## The disc

`Mulle-Meck_Bygger-Bilar_Svenska.iso` (114 MB) is a hybrid disc mastered with Toast 3.0.5:

- An Apple partition map with an **HFS (standard)** volume for classic Mac OS. Modern macOS can't mount HFS standard any more.
- An **ISO 9660** volume with the Windows version. You can mount it with:
  `hdiutil attach -readonly -nomount <iso>` and then `mount -t cd9660 /dev/diskN <dir>`.

Windows side contents: `DATA/` (MULLE32.EXE projector, DATA.CST save cast, FILEIO.X32),
`MOVIES/` (00.CXT, CDDATA.CXT, LBSTART.DXR, 02–94.DXR), `XTRAS/` (KeyPoll, PrintOMatic),
an InstallShield setup, and MULLEBIL.HLP.

## Runtime choice

ScummVM's Director engine detection table has this exact entry:

```
WINGAME1_l("garygadget1", "", "DATA/MULLE32.EXE", "t:a559c8b9d3bce8dd94d168d74509506d", 1512594, Common::SV_SWE, 600)
```

Our file matches it: the size is 1512594 and the md5 of the last 5000 bytes is a559c8b9…. ScummVM 2026.4.0 is a universal binary (arm64 + x86_64).
It's installed at `apps/ScummVM.app`. The game is registered under the target `garygadget1-win-sv`.

## Issue 1: "Xtra not found: fileio" (fixed)

`MULLE32.EXE` → `getCDPath` calls `new(xtra("fileio"))` to scan drives B–Z for `\data\Mulle.ico`.
On the CD, `FILEIO.X32` sits in `DATA/`, and the installer would copy it into an Xtras folder.
ScummVM only auto-loads Xtras found in an `Xtras/` folder.
**Fix:** copy `DATA/FILEIO.X32` → `XTRAS/FILEIO.X32`. ScummVM then maps the game folder as drive `B:\`,
so the CD check passes. No CD is needed.

## Issue 2: crash on the name screen (movie 10.DXR) (fixed, see Status below)

`10.DXR` ParentScript 91, `startMovie`:

```lingo
go(#next)
sendSprite(getProp(spriteList, #ScrollMain), #setText, getUsers(the users of gMulleGlobals))
```

Sprite 22 (ScrollMain) only exists from frame 2 on. The game expects `go(#next)` to switch frames immediately.
In ScummVM the channel is still empty at that point, so `b_sendSprite` falls back to calling
the behaviour handler `setText` as a global handler with **no `me`**. This causes
`cb_theassign: no me object` → `sort(VOID)` → `count(VOID)` → a Lingo error, and the debugger opens.

The relevant code is `engines/director/lingo/lingo-builtins.cpp`, `LB::b_sendSprite`. It is identical in 2026.4.0 and master
(checked 2026-10-17). Planned fix: when the target channel has no script instances and a frame change
is pending, create the instances from the pending frame (or skip the global fallback for behaviour
handlers, which real Director wouldn't call either).

### Status: fixed in the patched build

The fix is `Score::applyPendingJump()`: `b_sendSprite` applies a pending `go` before looking up the channel.

## Fixes in patches/0001 (all in engines/director)

| # | Symptom | Cause | Fix |
|---|---|---|---|
| 2 | `count(VOID)` on the name screen | `sendSprite` right after `go(#next)` hit an empty channel | `Score::applyPendingJump()`, called from `b_sendSprite` |
| 3 | `Could not evaluate initializer params` | `createScriptInstance` called `execute()` while another handler was running, which ran the outer handler too | `execute(callFrame)` plus a relative stack check (lingo-events.cpp) |
| 4 | `getAt` out of bounds, `STUB: scriptInstanceList` | `the scriptInstanceList of sprite` wasn't implemented | Implemented get/set (lingo-the.cpp) |
| 5 | `init` called with no `me` during beginSprite | beginSprite was sent channel by channel, before higher channels had instances | Create all instances first, then send beginSprite (lingo-events.cpp) |
| 6 | `new(#field, castLib "data")` went to behavior 49's `on new` | D6 score-script handlers were registered as globals | Only register them as globals for D<6 (lingo-bytecode.cpp) |
| 7 | `Call to undefined handler 'new'` | No `new(#type, castLib)` builtin | `LB::b_new` clones an existing member of that type |
| 33 (patch 0029) | Crash (SIGABRT, rect.h isValidRect) in the garage during prepareFrame | `inside()` built a Common::Rect from an inverted rect (scripts shrink snap rects by 25 px, which can invert them) | inside/intersect compare the coordinates directly and treat inverted rects as empty (lingo-builtins.cpp) |
| 32 (patch 0028) | Driving is wonky and never changes to the next map at the screen edge | `listP` returned false for points; the driving code uses `if listp(temp)` on checkBorders' point result and `if not listp(theCoordinate)` in quickCheck, so map borders were ignored and collision checks used the wrong coordinate | listP is true for POINT/RECT in D5+ (lingo-builtins.cpp). Verified with MULLE_AUTOKEY: the car crosses into the next map and follows its roads |
| 31 (patch 0027) | Car won't accelerate on the road after 0026 | Road cells are 0 bytes; String::encodeUTF8 appended each character as a C string, so U+0000 vanished and every later topology index shifted (roads read 240 = blocked). The per-NUL "Adding \\0 to String" warning then stalled the game | Encode byte by byte, silence that warning (common/str-enc.cpp, common/str-base.cpp). Verified with MULLE_AUTOKEY=38 and stage dumps: the car accelerates to ~65 km/h and follows the road to the map edge |
| 30 (patch 0026) | Driving ignores roads and never switches to the next map at the edge | The topology fields (30tNNNv0 and -2, 316 bytes per row, values 240 and up are blocked) hold NUL bytes, and Stxt used readString(0, strLen), which stops at the first NUL, so the rest read as 0 (free terrain) | Read exactly strLen bytes (stxt.cpp). Verified: 31284 chars per half, blocked counts match the raw data |
| 29 (patch 0025) | (defensive) The logo movie skips itself on a stray mouseUp | A Button Up with no Button Down in the game window (e.g. the launch/focus click) was delivered as mouseUp | Ignore a release with no press (events.cpp) |
| 28 (patch 0024) | Driving (05.DXR) is a fully white screen; only sound and throttle work | Channel 118 holds a stage-sized white shape (member 73, score stretch flag set). startMovie sets it to "Dummy" (an empty bitmap), but Channel::setCast kept the stretched 657x485 size, so Dummy was drawn as a white rectangle over everything | Shapes are sized by the score, so swapping a shape for a non-shape takes the new member's size (channel.cpp). Verified with a stage dump: the map, speedometer and fuel gauge render |
| 27 (patch 0022) | Can't type a name when saving a car (06.DXR) | `checkText` reads `the text of member "SavedCarName"` right after keyDown and writes it back, but the member was only synced from the edit widget on the next redraw, so each key was overwritten | `the text` of an editable member first syncs from its widget unless Lingo changed it since (castmember/text.cpp) |
| 26 (patch 0021) | Mulle's intro speech stops after "Hej mitt namn..." | The Sound object's `purge` stops a sound once `the ticks` pass 90 + size*60/11025, but `the size of member` for sndH/sndS sounds was the CASt record size (~1 KB), so speech was cut after ~1.6 s | The size is the sample data size (castmember/sound.cpp) |
| 25 (patch 0020) | Crash while driving out from the postbox (05.DXR) | `duplicate(point)` was rejected (only lists were allowed), and Datum::clone shared the point's storage | duplicate and clone accept POINT/RECT and deep-copy them (lingo-builtins.cpp, lingo.cpp) |
| 24 (patch 0018) | Garage: a part only lands after a second click, which then pops up "NOT FOUND!" | Patch 0013 sent only mouseUpOutSide when you release away from the clicked sprite, so the mouseUpScript (`virtualMouseUp`, which ends the drag) never ran | Also queue the primary mouseUp handler (events.cpp, `Movie::queuePrimaryInputEvent`) |
| 23 (patch 0018) | Door to the yard (04.DXR) hangs | 04 has two movie scripts with `on startMovie`; the hash-map order picked member 212 (`startMovie(gDir)`), which calls itself forever | The lowest member number wins, like the cast-window order (lingo-events.cpp, lingo-bytecode.cpp) |
| 22 (patch 0017) | Junkyard drops into the Lingo debugger ("sendSprite popped extra 1 values") | `execute()` polls events every 100 ops; a mouse move ran mouseEnter/Leave nested inside a running handler, and that nested execute() also ran the outer frames | Hover enter/leave from mouse moves go through `processInputEvent`, which queues them while Lingo runs (events.cpp) |
| 21 (patch 0015) | Junkyard crash (pop assertion) during the exitFrame broadcast | Nested sendSprite → callBehaviorHandler popped a result the handler never left | Compare stack depth before/after and return VOID instead of popping (lingo-builtins.cpp). Root cause of the missing value not yet known |
| 20 (patch 0013) | Dragging a name to the toilet doesn't delete it | D6 `mouseUpOutSide` was only sent on the *next* mouse press elsewhere, and releasing gave a plain mouseUp | On release outside the clicked sprite, send `mouseUpOutSide` to it instead of mouseUp (events.cpp) |
| 19 (patch 0011) | Junkyard: every pile shows the same items, door animation dead | A new sprite span that looks like the old one (all "Dummy") wasn't reloaded, so after the old span's behaviors were killed, none were created for piles 2-6 | `createScriptInstances` picks up the new span's range/behaviors from frame data and drops the old span's Lingo overrides (lingo-events.cpp) |
| 18 (patch 0009) | Garage parts never snap onto the car | `the rect of member` / `the regPoint of member` returned bitmap paint-space values (rect(158,245,...), point(320,240)). D5+ uses rect(0,0,w,h) and a regPoint relative to the top-left, so every snap area was offset | Convert in BitmapCastMember get/setField for D5+ (castmember/bitmap.cpp) |
| 17 (patch 0005) | Dropped part stays frozen at the drop point (drawn twice) | `the spriteNum of me` read the movie's *current* sprite, so the drag report (called from the ScreenObject loop) set member "Dummy" on sprite 0 | Store `spriteNum` on each behavior instance at creation (lingo-events.cpp) |
| 16 | Junkyard (02) crash on changing pile | `getPos(point, x)` was rejected, but Director treats points and rects as lists | `b_getPos` accepts POINT/RECT (lingo-builtins.cpp) |
| 15 | (audit #1) `the dragging/active/... of sprite n` returned VOID | SPRITEREF props only resolved built-in sprite fields | D6: fall back to the first behavior instance with that property, for get and set (lingo-the.cpp) |
| 14 | The custom cursor never changes shape | Any D6 sprite with a behavior counted as a mouse target, so the cursor sprite under the pointer swallowed every mouseEnter | `Sprite::respondsToMouse`: only behaviors with mouse handlers count (sprite.cpp) |
| 13 | Custom cursor invisible or frozen | D6 enterFrame/exitFrame were never sent to sprite behaviors, so cursor sprite 115 never followed the mouse | `broadcastEvent` for enter/exitFrame in D6, with per-channel sprite handlers in `queueEvent` (score.cpp, lingo-events.cpp) |
| 12 | Crash on entering the garage (03.DXR) | A behavior script with its own `on new me, x` (DrawCar) was queued by `LC::call` but never run before its result was popped | Run the queued frame with `execute(newFrame)` in `createScriptInstance` (lingo-events.cpp) |
| 11 | Empty-stack assertion when leaving the name screen (the real cause) | `func_goto` killed the old frame's behaviors synchronously, including the one running the handler, and their endSprite froze the wrong state | Skip that early kill for D6+, since `Score::update()` kills them before the jump anyway (lingo-funcs.cpp) |
| 10 | Empty-stack assertion when leaving the name screen | `go("IntroStart")` inside a `sendSprite` chain froze the Lingo state from a nested `execute()`, so the outer `sendSprite` popped from an empty stack | A nested `execute(targetFrame)` runs to completion, and only the outermost one freezes (lingo.cpp) |
| 9 | Game freezes after you enter a name (endless recursion) | `on save me` calls `save(castLib "data")`, and ScummVM routed that to the object's own `save` | `LC::call`: for D5+, a builtin wins over the caller's own same-named handler unless an object is passed first (lingo-code.cpp) |
| 8 | New player name rejected, then an assertion crash | The duplicated member had no CastMemberInfo, so the name couldn't be set; `deleteAt(list, 0)` asserted | Always create the info record; `deleteAt` raises a Lingo error instead |

## Useful commands

```bash
# Run with Lingo trace
apps/ScummVM.app/Contents/MacOS/scummvm --debugflags=lingoexec --debuglevel=2 garygadget1-win-sv
# Dump decompiled Lingo into ./dumps
apps/ScummVM.app/Contents/MacOS/scummvm --dump-scripts garygadget1-win-sv
```

## Dev B notes (KeyPoll, data-cast persistence, cuePassed)

- **KeyPoll** (patch 0002): `bgAllKeys()` returns Windows VK codes of held keys (up=38, down=40, since the game checks `machineType = 256`). `Window::processEvent` feeds `KeypollXtra::keyEvent`. `bgOneKey` no longer eats events from the queue.
- **save(castLib "data")** (patch 0003): writes all named text members to `saves/mulle-data.sav`; `Cast::loadCast` reapplies them when the cast is named "data" and recreates runtime members (`User<N>DB`). DATA.CST is reloaded for every movie, so this is also what carries state between movies.
- **cuePassed** (applied since; originally a diff; diff in the session notes folder): the event was never queued (`queueEvent` had no case for it, and `sound.cpp` passed the cue index as sprite id). Fix: queue it to every sprite's behaviors, then frame and movie scripts, and push args `(#sound<N>, cueNumber (1-based), cueName)`. Args travel via `Movie::_cueArgs`. Confirmed in a run: `spritecuePassed` fired from 03.DXR's MovieScript.
- **"Read past dataStream ... bitmap" x20**: harmless. They are 22-byte D6 bitmap records (`M_Right` etc., 16x16 1-bit cursor bitmaps) that end before the trailing `updateFlags` byte. They are not the cause of the black name field.

## Dev B: LBSTART jingle (member 106) is silent (resolved: not a bug, see "Start-up" sections below)

- The data is fine: 22050 Hz, 8-bit mono, 248514 frames (11.3 s), sample range 39..217. All sounds use the sndH/sndS (Moa) path. 106's header block has a garbage `soundHeaderType` string and a loop of 0..248514 (other sounds: 0..0); `looping` is still 0 when it is played, so the loop bounds are not used.
- It plays on score sound channel 2 (sound1 channels are fine). LBSTART's `exitFrame` holds on `soundBusy(2)`. In diag.log it held from tick 4572 to 5020, i.e. the movie left ~19.7 s after the sound started although the sound is only 11.3 s long. The user also needs a click to leave. So `isChannelActive(2)` stayed true after the audio should have ended: the stream appears not to be consumed by the mixer (or never ends), which matches "silent and stuck".
- Not yet explained. Next experiment: run `--debugflags=sound --debuglevel=5` through LBSTART (DirectorSound::playCastMember/stopSound lines, plus a mixer isSoundHandleActive log), and check whether the jingle ever becomes audible after waiting ~20 s.

### Dev B update: LBSTART jingle (final.log)

- Frames 1-9 of LBSTART advance ~1.5 s apart (704 ticks, ~11.7 s in total), which is as long as the jingle (11.3 s). Frame 9 then waits with no Lingo running and no `isChannelActive(2)` log line (that line only prints while the channel is active), so channel 2 had already finished. The hold is therefore a click wait (or delay) tempo on frame 9, not a sound wait; the earlier "stuck until click" is this tempo, not a stuck mixer stream.
- The earlier "stray mouseUp" seen in sound5.log was probably the user's own click in that run. In final.log there is a real Button Down/Up at (265,256) after frame 9.
- So the engine plays member 106 for its full length with real data (range 39..217). If the user truly hears nothing during the first ~12 s, the cause is not visible in the logs; ask whether the jingle is audible at all, or whether the missing audio is a later intro scene (10.DXR IntroStart).
- To confirm the frame-9 tempo: run with `--debugflags=events --debuglevel=5` and read "Score::updateNextFrameTime(): ..." at frame 9.

## Start-up white screen (lead, 2026-10-17)

MULLEDIAG frame logs show LBSTART frames 1-9 advance about every 90 ms with tempo 0, then a mouseUp (script 1, `go("Leave")`) jumps straight to frame 70, which cuts the jingle and loads 10.DXR. In the user's run the mouseUp came 90 ms after frame 9, about 4 s after launch. So the white screen with the watch cursor is most likely ScummVM's own engine start-up (fonts etc., 4-17 s). The user's click during it is queued and then skips the logo. In a smoke run with no click, a mouseUp also arrived after `SdlEventSource: corrected stale mouse position`. Next: check whether SDL synthesizes a click when the window activates.

### Start-up, confirmed with MULLE_SHOTS (2026-10-17)
With no click, LBSTART plays the full Levande Böcker logo animation (frames 9→32→54→69) for the length of the jingle (~11.4 s), then loads 10.DXR. The earlier "white screen" was the logo's first frames plus the user clicking, which skips it (Director behaviour). 10.DXR then holds about 8 s on frame 2 while music 287 plays before the intro speech starts. That is probably a sound-wait tempo, but it hasn't been confirmed yet.

## 2026-10-17 later
- P0040 cast.cpp saveRuntimeData skips members flagged by erase(): players deleted in the toilet no longer persist in mulle-data.sav (re-creating a deleted name now starts fresh).
- Double cursor: 00.CXT prepareMovie calls cursor(200) (when CustomCursorActive) and draws the hand as sprite 115; 04 ParentScript-29 uses system cursors 2/3/-1/0 directly. Backend hides a 0x0 cursor correctly. Diag commit adds MDIAG(2,"cursor") "apply default/sprite cursor type N" in Score::renderCursor; read it from the next play log to see which screen re-shows the arrow (kMacCursorOff vs Arrow).
- Start-up timing (smoke, no clicks): MULLE32.EXE 2.15 s, LBSTART loaded 2.9 s, logo ends at frame 69 at 12.3 s and loops (BehaviorScript-95: soundBusy(2)) until jingle 106 ends at 14.2 s; 10.DXR loaded 14.4 s and holds on BehaviorScript-9 (soundBusy(1)) while music 287 plays until 22.8 s, then Mulle speaks. All scripted waits. Only the first ~2.9 s (engine start) has no game picture.
- E2 makeOKToContinue: dead code (10.DXR MovieScript-67 #EnteredSomething is never sent; the scroller calls resultsFromScroller(gDir, ...) on the Dir object).
- P0041: `go the frame` self-loops not logged in MDIAG; "handler did not return value" and "global not defined" moved to debug levels 2/3.
- Play log (17 Oct, late): LBSTART -> 10 -> 03 -> 04 -> 05 -> 94, no crash. Engine cursor was Off (type 6) on every screen after cursor(200), so the double cursor is not the engine re-showing an arrow (check the macOS pointer vs the sprite-115 hand with the user).
- 94.DXR car show hung on frame 2: the judge SpriteAnim (waitForWhat #sound, doWhat #GoNextMarker) calls go(#next) every exitFrame after its speech, then the frame script (castLib 1 member 3) `go(the frame)` overwrote _nextFrame. P0042: func_goto ignores go-to-current-frame while another jump is pending (MDIAG go level 2 "keep pending jump"). Empty stand on frame 2 is expected (no DrawCar in frames 1-2).
- Double cursor = macOS system arrow + Mulle's hand (user confirmed). Engine cursor is Off and SDL is told to hide the system cursor inside the game area, but SDL2 2.30.12's Cocoa backend hides it only via cursor rects, which did not take. patches/sdl/0001-cocoa-hide-cursor.patch adds a balanced [NSCursor hide]/unhide in Cocoa_ShowCursor; tools/build-scummvm.sh applies patches/sdl/*.patch before building SDL. Built, smoke OK; needs the user's eyes.
- Phase 1 play (17 Oct): user confirms the double cursor is gone with patches/sdl/0001. 94 completes (0042). No fatals.
- Progress persistence: the game writes mulle-data.sav only via save(gMulleGlobals) at login (10.DXR), 06 car save, and kill(gMulleGlobals) from killall (credits 12 / Alt+F4 / Cmd-Q system keys). Closing the ScummVM window skipped all of these, so progress after login was lost. P0044 runs save(gMulleGlobals) after the main loop when gMulleGlobals is still an object (shouldQuit() is already reset there). Verified with MULLE_QUITAFTER=25: "save(gMulleGlobals) on window close", file written, content unchanged at the name screen. SIGTERM does not quit ScummVM.

## 2026-10-17 Phase 2 play findings
- 85 dog crash: SpriteAnimBH (00.CXT #106) sprite with empty initializer params. Director fills props from getPropertyDescriptionList #default; 0045 does that (0046 logs it). 0047: getaProp on a non-list returns VOID instead of halting.
- 06 car name typing: the game sets editableText/editable while the field is on screen; the engine only applied it at widget creation. 0049 updates the live widget and gives it focus.
- Å/Ä/Ö: MacText accepted only ASCII 0x20–0x7f. 0048 (graphics/, diff vs tarball) accepts Latin-1 0xA0–0xFF.
- Intro: log shows 10.DXR IntroStart played sound 289 and the user's click 1 s later skipped to 03 (behaviour 76 mouseUp). Need the user's description of the missing intro.
- Smoke tests now also save on exit (0044), so they touch saves/.

## Round 7 results / round 8 fixes (2026-10-18)
- Intro stall behind the barn: 10.DXR frame 64 (and frame 2) has a "normal" palette fade at speed 0 to the palette already on screen; the engine ran it as an 8.2 s blocking fade. 0068 skips fades where no color differs. Verified in play: frames 7-71 now take 8 s instead of 16 s.
- Ignition (04 frame 49): kickEngine starts the engine sound and goes to 05 at once; on CD the load time kept the screen up. 0067 holds a D6 movie change up to 2.5 s while a puppet sound started <300 ms ago plays. Not yet verified in play.
- 0066: diags for tempo changes and slow frames by stage (render area). 0064 typing fix, 0065 slow-blit diag installed.
- Junkyard (02) door exits work on mouseEnter, so background clicks without pointer movement don't open them.
- Shots include the custom hand cursor; a "thing on Mulle's head" in a shot can be the cursor.
- Open: Mulle's head in 02 on first entry (user's description pending), racetrack timing, mud-rescue video, repeated medals (Dev B), Figge.
- Intro music part 2 (10.DXR f79, sound2 member 290, 19 s) was ignored: the name screen's click sounds left ch 2 a puppet. 0072: a D6 finished puppet sound returns the channel to the score. Verified in smoke (start member 290 at f79).
- Junkyard head on re-entry: starting 02 at label j6 (frame 51), load-time Lingo instantiated behaviors from frame 1's sprites (span 1-10) and kept them for span 51-60; SpriteAnimBH then used j1's loc/params. 0073 drops instances made for another span. Verified live; channels 10-18 (doors, parts) were affected too. Likely also the empty FrameList in 82/84/85 (entered at labels): to verify in round 8.
- Race board text black on black: 0070 (foreColor now updates the STXT run color). Unverified.
- Junkyard/garage doors open on mouseEnter: testing with computer use needs full-screen mouse_move, not background clicks.
- tools/smoke-test.sh picks fightTEST on the name screen (MULLE_CLICKS) and runs until 03; saves restored automatically.
- 0074: text member put on a 0x0 placeholder sprite takes the member's size (race board field sprite was 0x0). 0075: the data cast survives movie changes in memory (it was reloaded from the save file on every movie load, losing unsaved changes); MULLE_EVAL test hook.
- Scene jump sweep (tools/jump.sh, tools/scene-sweep.sh): direct jumps run scenes in their "testing" mode (no world object), so they are not valid tests of real play; the user asked to stop using them. Findings kept: 85/84 sprite 38 has an empty initializer string (score entry), falls back to #Standard, likely original. An attempt to keep Lingo sprite changes across in-span jumps (86 loop) broke Lingo-drawn cars in 03 and was reverted.
- Open: ignition screen shows car sprites stacked underneath (user report, not reproduced), Figge/Ferre conversation glitches, race hi-score names (CustomRacingDB empty in the user's save).

## 2026-10-18: patch numbering unified
patches/ did not reproduce the build: 6 diag commits were never exported and 4 old patches (0030, 0031, 0057, 0066) failed on clean source. It is now the BuffasBilverkstad set (001-084, git order), checked: applied to clean 2026.4.0 it matches the build tree exactly. Old numbers map via docs/PATCH-NUMBERS.md (e.g. old 0077 = 083, 0078 = 084). Next patch: 085.

## 2026-10-18: car over the ignition picture, race board not saved
- 087 (mellemuck fix 25): in D6, Lingo's changes to a sprite end when the channel enters another span, not only an empty one (083). The car channels sit in placeholder spans, so the car stayed over the next span's ignition picture. Also counts a span change as dirty in Channel::isDirty.
- Race board: CustomRacingDB/Field1/Field2 were empty in every save since the earliest backups. ObjectRacingScript creates them (with [186: "MIA M", 232: "FIGGE F"]) only when `the number of member` is -1, so an early broken save stuck: value("") is VOID, showTime shows 0:00 and a finished race can't update the list. Dropped the three from saves/mulle-data.sav (backup in build/saves-backup-round10) so the game recreates them. Verify after a finished race that CustomRacingDB holds the list.
- 091 (mellemuck fixes 17, 54, 68): the save never loaded members before writing them. ObjectsDB (26 object ids on the disc) and the race board (CustomRacingDB/Field1/Field2, "MIA"/"FIGGE" records) were saved empty in every save since the first, and restoring put the empty text over the disc's. Now members are loaded before saving, empty saved text keeps the cast file's text (repairs old saves: smoke shows "1 empty kept"), the save keeps 9 rotating backups (mulle-data.sav.bak1 newest), and a cut-off save falls back to the newest whole backup. Smoke 2026-10-18: reached 03.
- 088-090 (Dev C proposals, mellemuck 67, 56+57, 58): a go to the playing movie reloads it after stopMovie (pause menu go(1,"03") in 03 lost gDir); a borderless window (album file dialog, movie 13) keeps its content and gets clicks at the content offset; reopening a closed window with its movie skips stopMovie. 089 needed a pristine baseline commit for graphics/macgui/macwindow.cpp (98819c6, not a patch). 06/13 dialog untested in play.
- 092 (mellemuck 122): FileIO is opened at start for garygadget1, so a straight copy of the disc (FILEIO.X32 only in DATA/) starts. Not tested without our XTRAS copy.
- Smoke 2026-10-18 13:48 on 088-092: reached 03; save backups rotate .bak1/.bak2 (mellemuck's skipped-.bak2 bug not seen). patches/ 001-092 applied in number order reproduce the build tree exactly (091 was committed before 088-090; independent files).
- 093 (mellemuck 49, quit part only): closing the window with the game's exitLock on quits without ScummVM's "game prevents quitting" dialog; the save-on-close (our earlier patch) still runs. Checked with MULLE_QUITAFTER=20: MDIAG "window closed with the exitLock on", then a 25-member save. The rest of 20+49 (save slots, own pause menu, keymaps) is a feature on mellemuck's own save format: not ported.
- 2026-10-18 learn-only rewrite: mellemuck is a reference only (no copied code, no added features). Old 085-093 dropped (build/attic/patches-dropped-085-093, git tag before-rewrite-085). New, our own code: 085 reads all listSize sprite-detail offsets; 086 adds `the marker` as a Lingo entity; 087 ends Lingo sprite changes when a channel enters another span (extends 083, no isDirty change); 088 go to the playing movie reloads after stopMovie; 089 data save loads members first and keeps cast-file text for empty saved text. Dropped as added features or not needed: borderless dialog/closed-window reopen (old 089/090), save backups (part of old 091), FileIO from a plain disc copy (old 092), quit without the exitLock dialog (old 093). Smoke reached 03; patches/ 001-089 reproduce the tree.
- 090: car over the ignition picture, real cause. In 92 (and the other destinations) the car channels 35-73 are EMPTY at frames 97-101 (sprite-detail index 0), so 083's empty-channel release ran, but releaseAutoPuppet only clears flags that have a copy-back bit (cast, loc, ink, colours, width, height, moveable). Any other Lingo flag (rect, locH, locV, blend, thickness, bbox) left _autoPuppet non-zero, isDirty skipped the comparison and the car stayed. A full mask now clears every flag. Also: the Leave frame (DestFinalBH) plays the engine sound and goes to 05 at once; our 067 hold keeps that frame up to 2.5 s, which is why the car was so visible. MDIAG "span end clears Lingo changes" confirms it in play. Smoke reached 03.
- 090 amended (Dev D risk): the full clear is Sprite::endLingoChanges(), only on span-end paths; backward jumps keep their copy-back mask.
- 091: erase removes a member no sprite shows at once (ScummVM deferred it to a redraw that never came for off-stage members; a deleted player's User<name>DB came back for a new player of the same name). From Dev C's audit docs/MELLEMUCK-AUDIT2.md (other open: input mid-Lingo (41), white 0x0 bitmap (35), latent 24/51/120). Smoke reached 03.
- 092 (2026-10-18, round 11 screenshot: car still over the ignition): the real root. A frame sprite with no sprite-detail entry (empty channel) kept the previous span's _spriteInfo (loadFrameSpriteDetails only loaded info when the index was non-zero), so in 92's Leave frame the empty car channels 35-73 still "had" span 1-96 and 083/090 never fired. Now an empty channel gets SpriteInfo() (-1/-1), emptiness is tested by the missing detail index, and only a channel that had a span (_startFrame > 0) ends Lingo changes when it goes empty. Smoke reached 03; span-end lines fire in 03 (ch 25 locH 0x400, ch 9, ch 113). NOT yet verified in play: the 92/86 Leave frame, and that the garage (03) car still draws.
