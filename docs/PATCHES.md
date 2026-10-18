# Patch reference

All patches apply in numeric order to ScummVM 2026.4.0 (`build.sh` does this). Paths are under `engines/director/` unless shown in full. "Diagnostic" patches only add logging or opt-in test aids (see DIAG-FLAGS.md). Old 4-digit numbers used in INVESTIGATION.md are mapped in PATCH-NUMBERS.md.

| # | Patch | Type | What it does | Files |
|---|---|---|---|---|
| 001 | director-sendSprite-apply-pending-go | fix | sendSprite applies a pending go, plus 15 early Director 6 fixes (see INVESTIGATION.md) | cast.cpp, lingo/lingo-builtins.cpp, lingo/lingo-builtins.h, lingo/lingo-bytecode.cpp, lingo/lingo-code.cpp, lingo/lingo-events.cpp, lingo/lingo-funcs.cpp, lingo/lingo-the.cpp, lingo/lingo.cpp, score.cpp, score.h, sprite.cpp |
| 002 | keypoll-bgAllKeys | fix | keypoll | events.cpp, lingo/xtras/k/keypoll.cpp, lingo/xtras/k/keypoll.h |
| 003 | data-cast-persistence | fix | data cast persistence | cast.cpp, cast.h, lingo/lingo-builtins.cpp |
| 004 | cuepassed-args | fix | cuePassed args | lingo/lingo-events.cpp, movie.h, sound.cpp |
| 005 | behavior-spritenum | fix | behavior spriteNum | lingo/lingo-events.cpp |
| 006 | charpostoloc-fileio-createfile | fix | charPosToLoc and FileIO createFile (dev B) | castmember/text.cpp, castmember/text.h, lingo/lingo-builtins.cpp, lingo/xlibs/f/fileio.cpp |
| 007 | sound-load-diagnostics | fix | sound load diagnostics (dev B) | castmember/sound.cpp, sound.cpp |
| 008 | text-bgcolor-palette | fix | text member bg colour from palette at draw time (dev B) | castmember/text.cpp, castmember/text.h |
| 009 | bitmap-rect-regpoint | fix | bitmap member rect and regPoint in D5+ coordinates | castmember/bitmap.cpp |
| 010 | moa-sound-diagnostics | fix | Moa sound play diagnostics (dev B) | sound.cpp |
| 011 | new-span-behaviors | fix | reload behaviors for identical-looking new sprite spans | lingo/lingo-events.cpp |
| 012 | sound-channel-activity-log | fix | sound channel activity log (dev B) | sound.cpp |
| 013 | mouseupoutside-on-release | fix | mouseUpOutSide on release outside clicked sprite | events.cpp |
| 014 | text-no-autoselect | fix | no auto-select-all for editable text fields without a Lingo selection (dev B) | castmember/text.cpp |
| 015 | behavior-handler-empty-result | fix | callBehaviorHandler: no pop when handler left no result | lingo/lingo-builtins.cpp |
| 016 | garygadget1-saved-cars-numToChar0 | fix | garygadget1 saved cars listed via quirks cache; numToChar(0) returns empty string | game-quirks.cpp, lingo/lingo-builtins.cpp |
| 017 | d6-hover-events-queued | fix | D6 mouseEnter/Leave from mouse moves go through the input queue (no nested Lingo); log D6 wait tempos | events.cpp, score.cpp |
| 018 | movie-script-order-mouseupscript | fix | D6: lowest-numbered movie script wins for events/handlers; mouseUpScript still runs on release outside the clicked sprite | events.cpp, lingo/lingo-bytecode.cpp, lingo/lingo-events.cpp, movie.h |
| 019 | textheight-line-height | fix | textHeight returns full line height (font height + leading), fixes name list always picking last line | castmember/text.cpp |
| 020 | duplicate-point-rect | fix | duplicate() and Datum::clone handle POINT/RECT (driving crash in 05.DXR) | lingo/lingo-builtins.cpp, lingo/lingo.cpp |
| 021 | sound-member-size | fix | the size of a sndH/sndS sound member is its sample data size (intro speech was cut after 1.6 s) | castmember/sound.cpp |
| 022 | diag-mullediag-warnings-sound-play-stop-curso | diagnostic | MULLEDIAG warnings (sound play/stop, cursor(), D6 tempos, LBSTART frames) - temporary, not a fix | lingo/lingo-funcs.cpp, score.cpp, sound.cpp |
| 023 | fileio-mode0-read | fix | FileIO openFile mode 0 opens for reading (car load) | lingo/xlibs/f/fileio.cpp |
| 024 | text-sync-from-widget | fix | the text of an editable member picks up what was just typed (car name field in 06.DXR lost every key) | castmember/text.cpp |
| 025 | diag-mullediag-for-the-05-map-sprite-and-30b | diagnostic | MULLEDIAG for the 05 map sprite and 30b* map bitmaps - temporary | castmember/bitmap.cpp, lingo/lingo-the.cpp |
| 026 | mdiag-diagnostics | diagnostic | MDIAG: one level-gated diagnostics facility (movie, go, calls, errors, windows, fileio, save, sound, input, load failures) | cast.cpp, castmember/bitmap.cpp, castmember/movie.cpp, director.cpp, director.h, lingo/lingo-builtins.cpp, lingo/lingo-code.cpp, lingo/lingo-events.cpp, lingo/lingo-funcs.cpp, lingo/lingo-object.cpp, lingo/lingo.cpp, lingo/xlibs/f/fileio.cpp, module.mk, mullediag.cpp, mullediag.h, score.cpp, sound.cpp, window.cpp |
| 027 | shape-to-bitmap-dims | fix | setting a member on a stretched shape sprite takes the new member's size (white full-screen shape over the driving map in 05.DXR) | channel.cpp |
| 028 | ignore-release-without-press | fix | ignore a mouse release with no press in the game window | events.cpp |
| 029 | diag-mulle-shots-stage-bmp-dumps-05-covering | diagnostic | MULLE_SHOTS stage BMP dumps, 05 covering-sprite log - temporary | lingo/lingo-the.cpp |
| 030 | mdiag-fold-temp-diag | diagnostic | fold temporary 05 diag lines into MDIAG sprite/shot areas | lingo/lingo-the.cpp, score.cpp |
| 031 | stxt-keep-nul-bytes | fix | STXT text is read as exactly strLen bytes, keeping NUL bytes (driving topology maps were cut at the first NUL) | stxt.cpp |
| 032 | utf8-keep-nul | fix | UTF-8 encoding keeps U+0000; NUL-append warning silenced (common/, outside the git tree) | common/str-base.cpp, common/str-enc.cpp |
| 033 | diag-mullediag-topology-size-blocked-count-te | diagnostic | MULLEDIAG topology size/blocked count - temporary | castmember/text.cpp |
| 034 | text-scrolltop | fix | scrollTop of text member scrolls the widget (reapplied when the widget is rebuilt) | castmember/text.cpp, castmember/text.h |
| 035 | selstart-cast-editable | fix | selStart/selEnd also reach widgets of members made editable via the cast (06 car name) | channel.cpp |
| 036 | printomatic-arity | fix | PrintOMatic: append*/setText/setMargins take a variable arglist (08 diploma print) | lingo/xlibs/p/printomatic.cpp |
| 037 | diag-mulle-autokey-keypoll-held-key-and-mulle | diagnostic | MULLE_AUTOKEY (KeyPoll held key) and MULLE_TOPOLOG (topology char reads) test aids - temporary | lingo/lingo-code.cpp, lingo/xtras/k/keypoll.cpp |
| 038 | sound-keep-looping | fix | sound member keeps its loop flag across unload/reload | castmember/sound.cpp |
| 039 | window-filename-reload | fix | setting the fileName of a window reloads the movie even when it is already loaded (MIAW reopen) | window.cpp, window.h |
| 040 | mulle-clicks-replay | fix | MULLE_CLICKS scripted input replay in DirectorEngine::pollEvent (diagnostics) | events.cpp |
| 041 | text-member-rect | fix | text member: set the rect of member updates its initial rect (08 diploma) | castmember/text.cpp |
| 042 | mdiag-save-load | diagnostic | MDIAG save: line when the data cast is restored from mulle-data.sav | cast.cpp |
| 043 | listp-point-rect | fix | listP is true for points and rects in D5+ (driving map borders and collision checks) | lingo/lingo-builtins.cpp |
| 044 | inverted-rect-no-assert | fix | inside()/intersect() treat inverted rects as empty instead of asserting (crash in rect.h) | lingo/lingo-builtins.cpp |
| 045 | save-skip-erased | fix | don't persist erased members in the Mulle data save | cast.cpp |
| 046 | diag-log-which-cursor-rendercursor-applies | diagnostic | log which cursor renderCursor applies | score.cpp |
| 047 | quiet-log-noise | fix | quiet routine Lingo log noise (go-self, no return value, unset globals) | lingo/lingo-code.cpp, lingo/lingo-funcs.cpp, lingo/lingo.cpp |
| 048 | keep-pending-jump | fix | don't let go-to-current-frame cancel a pending jump | lingo/lingo-funcs.cpp |
| 049 | mdiag-progression | diagnostic | MDIAG prog lines for Mulle progression handlers (dev-c) | lingo/lingo-code.cpp |
| 050 | save-on-window-close | fix | run Mulle Meck's save handler when the window is closed; MULLE_QUITAFTER test hook | director.cpp |
| 051 | behavior-default-props | fix | give behavior properties their getPropertyDescriptionList defaults | lingo/lingo-events.cpp |
| 052 | mdiag-behavior-defaults | diagnostic | log getPropertyDescriptionList defaults per behavior | lingo/lingo-events.cpp |
| 053 | getaprop-void | fix | getaProp on a non-list returns VOID instead of halting | lingo/lingo-builtins.cpp |
| 054 | mactext-latin1-keys | fix | --- a/graphics/macgui/mactext.h | graphics/macgui/mactext.cpp, graphics/macgui/mactext.h |
| 055 | editable-live-widget | fix | apply editable/editableText to a text field already on screen | castmember/text.cpp, castmember/text.h, lingo/lingo-the.cpp |
| 056 | builtin-noreturn-void | fix | builtin without a return value gives VOID instead of halting | lingo/lingo-code.cpp |
| 057 | mdiag-progression-flags | diagnostic | log Figge/mission progression flags; quiet no-cast getShape and behavior defaults | lingo/lingo-events.cpp, lingo/lingo-object.cpp, sprite.cpp |
| 058 | mdiag-transitions | diagnostic | log transitions | transitions.cpp |
| 059 | rollover-past-drag-sprite | fix | D6 mouseEnter/Leave go to the topmost sprite with a rollover handler | events.cpp, score.cpp, score.h |
| 060 | sound-after-palette-fade | fix | start a frame's sound after its blocking palette fade | score.cpp |
| 061 | keyboard-focus-editable | fix | D6 typing goes to the first editable field when none has focus | events.cpp, score.cpp, score.h |
| 062 | cue-names-pascal | fix | sound cue point names are Pascal strings | castmember/sound.cpp |
| 063 | mdiag-sound-stop-yard-sprites | diagnostic | who stops a sound and after how long; yard head/body sprite locs | lingo/lingo-the.cpp, sound.cpp |
| 064 | member-name-lingo-equality | fix | member name lookup falls back to Lingo string equality | cast.cpp |
| 065 | castlib-minus-one | fix | resolve D6 score sprites with castLib -1 in the movie cast, then shared | movie.cpp |
| 066 | key-pass-past-behavior | fix | a behavior without a key handler passes keyDown/keyUp on to the movie | lingo/lingo-events.cpp |
| 067 | editable-field-keep-size | fix | editable text keeps its score size; log editable field dims | channel.cpp |
| 068 | mdiag-sound-replace-length-sprites | diagnostic | sound replaced on a busy channel, sound length; 04/03 head and Figge sprites on change | score.cpp, sound.cpp |
| 069 | d6-score-sound-plays-out | fix | D6 score sounds play to their end after their span | sound.cpp |
| 070 | field-typing-sprite-level-pass | fix | a frame/movie keyDown that doesn't pass no longer eats typing into an editable field | lingo/lingo-events.cpp, lingo/lingo.cpp, lingo/lingo.h |
| 071 | mdiag-slow-blit | diagnostic | log sprite blits slower than 40 ms | window.cpp |
| 072 | mdiag-tempo-slow-frame | diagnostic | log D6 tempo changes and frames slower than 100 ms by stage | score.cpp |
| 073 | movie-change-hold-fresh-sound | fix | hold a D6 movie change while a just-started Lingo sound plays (max 2.5 s) | sound.cpp, sound.h, window.cpp, window.h |
| 074 | skip-noop-palette-fade | fix | skip a D6 palette fade whose colors are already on screen | score.cpp |
| 075 | fix-enterframe-diag-else | fix | fix 0066 diag that sent D6 enterFrame twice (dangling else) | score.cpp |
| 076 | text-forecolor-run-color | fix | text foreColor also sets the run color used when text is set later | castmember/text.cpp |
| 077 | mdiag-error-me-props | diagnostic | dump the receiver's properties on an uncaught Lingo error | lingo/lingo.cpp |
| 078 | d6-finished-puppet-releases-channel | fix | D6 finished puppet sound hands its channel back to the score | score.cpp, sound.cpp, sound.h |
| 079 | recreate-behaviors-other-span | fix | recreate D6 behaviors made for another span of the channel | channel.h, lingo/lingo-events.cpp, score.cpp |
| 080 | text-on-empty-sprite-size | fix | a text member set on a 0x0 placeholder sprite takes its own size | channel.cpp, sprite.cpp |
| 081 | data-cast-memory-snapshot-eval-hook | fix | keep the data cast in memory across movie changes; MULLE_EVAL test hook | cast.cpp, cast.h, window.cpp |
| 082 | hidden-cursor-no-ibeam | fix | macgui: keep a hidden cursor hidden over editable text | graphics/macgui/macwindowmanager.cpp |
| 083 | empty-channel-ends-lingo-changes | fix | D6 frame without a sprite in a channel ends Lingo changes to it | score.cpp |
| 084 | d6-looping-sound-stays-busy | fix | in D6 a looping sound stays busy while it plays | sound.cpp |
| 085 | d6-read-all-sprite-detail-offsets | fix | D6 score reads all listSize sprite-detail offsets | score.cpp |
| 086 | the-marker | fix | add the marker (D5+), the frame of the current marker | lingo/lingo-the.cpp, lingo/lingo-the.h |
| 087 | d6-new-span-ends-lingo-changes | fix | D6 Lingo changes to a sprite also end when its channel enters another span | score.cpp |
| 088 | go-same-movie-reloads-after-stopmovie | fix | a go to the playing movie loads it afresh once stopMovie ran | window.cpp |
| 089 | data-save-loads-members-first | fix | the Mulle data save loads each member before writing it | cast.cpp |
| 090 | span-end-clears-all-lingo-changes | fix | the end of a D6 sprite span ends every Lingo change to it | lingo/lingo-events.cpp, score.cpp, sprite.cpp, sprite.h |
| 091 | erase-offstage-member-now | fix | erase removes a member no sprite shows at once | lingo/lingo-builtins.cpp |
| 092 | empty-channel-has-no-span | fix | an empty D6 channel has no span; a channel going empty ends Lingo changes | score.cpp |

`patches/sdl/0001-cocoa-hide-cursor.patch` (macOS only): keeps the system cursor hidden in SDL2 2.30.12 when the game draws its own.
