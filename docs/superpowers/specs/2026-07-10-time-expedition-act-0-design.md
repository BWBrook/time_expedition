# Time Expedition Act 0 Design

**Status:** Approved direction, written specification

**Chapter:** Act 0: The Model

**Engine:** Godot 4.7, 2D, GDScript

## Purpose

The first deliverable is a short, complete playable prologue to *The Time
Machine*. The player controls the unnamed Time Traveller in his Richmond
workshop before the novel begins, finishes the model Time Machine, and performs
its first successful test. The model returns from a brief temporal excursion,
so it remains available for the dinner-party demonstration that will open the
next chapter.

This slice establishes the project's identity: literary science fiction made
physical through observation, inference, and machinery. It must feel like the
opening of a real game rather than a collection of engine experiments.

## Player Promise

In one sitting of roughly 8 to 12 minutes, the player will:

1. Enter an inhabited Victorian workshop with an unfinished experiment already
   in progress.
2. Learn movement, inspection, inventory, journal, and focused manipulation
   through play.
3. Locate three visually distinct model components.
4. Assemble the components in a close-up workbench view.
5. Calibrate the machine from clues recorded in the Time Traveller's notebook.
6. Pull the departure lever and witness the model leave the present.
7. See the model return with physical evidence that time has passed for it.
8. End on the arrival of the dinner guests and the title *Time Expedition*.

The emotional progression is curiosity, concentration, uncertainty, wonder,
then anticipation. There is no combat, death, time pressure, or hard failure in
this chapter.

## Scope

### Included

- An opening cold-open card, one horizontally staged workshop location, the
  model workbench close-up, and a closing title card.
- Keyboard movement and interaction, plus keyboard and mouse operation of menus
  and the workbench close-up.
- Inspectable scenery that rewards curiosity without creating false puzzle
  dependencies.
- A three-item inventory and a journal that updates as deductions are made.
- One assembly puzzle, one calibration puzzle, and one authored activation
  sequence.
- A coherent first-pass art treatment, ambient sound, interaction sounds, and
  a short original musical or tonal cue for the successful test.
- A restartable session and a pause menu.
- Automated state, content, scene-instantiation, and happy-path smoke tests.
- Source and licence provenance suitable for an eventual open-source release.

### Excluded

- The dinner-party demonstration itself.
- The full-scale Time Machine, travel to 802,701 AD, Eloi, Morlocks, hazards,
  combat, stealth, branching dialogue, or another location.
- Save files, multiple profiles, controller support, localisation, voice acting,
  achievements, mobile builds, and web export.
- A general-purpose quest, dialogue-tree, crafting, or puzzle engine.
- Runtime ingestion of Wells' prose or any generative-AI service.

The excluded features remain possible later, but Act 0 will not build dormant
systems for them.

## Narrative Design

### Setting and voice

The chapter is set in Richmond, Surrey, in 1895, earlier on the evening of the
dinner described in Wells' novel. The protagonist remains "the Time Traveller"
and is never given a new canonical name.

Observations and journal entries use concise first-person late-Victorian prose.
They should suggest intelligence, impatience, dry humour, and empirical doubt,
without becoming an imitation stuffed with archaisms. Act 0 text is original;
it may use Wells' public-domain concepts and terminology but will not borrow
dialogue, visual designs, or inventions from later adaptations.

### Story beats

1. **Cold open:** A restrained card reads "Richmond, 1895. Before the
   demonstration." Workshop sound begins before the image appears.
2. **Unfinished proof:** The player finds the model frame on the central bench.
   Its three empty fittings and the open notebook establish the task without an
   objective pop-up.
3. **Material search:** The player recovers ivory guide bars from a measuring
   drawer, a crystalline prism from the optical bench, and the paired control
   levers from a tray of rejected mechanisms.
4. **Assembly:** In a full-screen close-up, the player places each component in
   its matching fitting. The machine visibly becomes the delicate framework
   later shown to the dinner guests.
5. **Calibration:** The notebook states two principles in words and sketches:
   spatial axes must rest at equilibrium, while temporal bias must sit one
   division forward. The player adjusts two controls until both indicators are
   correct.
6. **First attempt:** Pulling the lever before calibration produces a harmless
   mechanical shudder and a useful first-person observation. Nothing is lost or
   reset.
7. **Excursion:** With calibration correct, the white departure lever initiates
   a complete excursion. The model develops offset after-images, disappears
   with a pressure pulse, and leaves the bench empty for several seconds.
8. **Return:** The model reappears in the same footprint after four seconds.
   Its onboard chronometer has advanced fifteen seconds, eleven seconds more
   than the workshop clock. The journal records this discrepancy as evidence
   rather than certainty.
9. **Handoff:** The house clock strikes the appointed hour and the front bell
   rings. The Time Traveller covers the model with a cloth. Cut to the game
   title and "The demonstration awaits," with restart and quit commands.

## Interaction Design

### Workshop navigation

The workshop is a side-on 2D room approximately two and a half screen widths
wide. The player walks left and right with `A`/`D` or the arrow keys. `E` or
`Space` activates the nearest focused object. `Escape` pauses. Journal and
inventory have both compact icon buttons and keyboard shortcuts (`J` and `I`).

Only one interactable can be focused at once. Focus is indicated by a restrained
outline and a small interaction glyph with the object's verb and name, such as
"Inspect notebook" or "Open drawer". The system favours the closest object in
the character's facing direction to avoid focus flicker.

Inspection text appears in a fixed bottom band and can be advanced with the
interaction key or a mouse click. It never blocks movement after dismissal.
Critical information is also recorded in the journal, so rapidly dismissing a
line cannot make the chapter unsolvable.

### Inventory and journal

Inventory is a small full-width tray, not a grid of empty slots. It displays
only acquired objects, with an image, name, and one-sentence observation.
Workshop collection is automatic; the player does not need to select an item
before opening the assembly view.

The journal is a two-page overlay with dated observations on the left and the
current experiment sketch on the right. New entries appear with a subtle page
sound and a brief notebook icon pulse. The current assembly or calibration clue
is always visible when the relevant workbench phase is active.

### Model workbench

Interacting with the central bench opens a full-screen close-up, preserving a
hint of the workshop around its edges. This is the chapter's principal tactile
surface.

- During assembly, acquired components sit in a stable tray. Each can be
  dragged into one of three clearly shaped fittings. A correct component seats
  with a mechanical click; an incorrect one returns to the tray without a
  penalty. Keyboard focus, confirm, and cancel controls provide the same path
  as drag and drop.
- During calibration, two stepped controls adjust spatial equilibrium and
  temporal bias. Their target states are conveyed by needle position, engraved
  marks, and the notebook sketch, not colour alone.
- The departure lever cannot be pulled until all three components are fitted.
  If calibration is wrong, it remains physically operable but causes the
  harmless shudder response. This lets the player test a hypothesis instead of
  encountering a disabled button.
- `Escape` or a visible close icon returns to the workshop at any time. Assembly
  and calibration progress is retained for the session.

All puzzle actions are idempotent. Components cannot be destroyed, dropped, or
consumed incorrectly, and every prerequisite has an authored feedback line.

## Presentation

### Visual direction

The game uses an illustrated 2D side-view with readable silhouettes and modest
parallax, closer to an animated scientific plate than pixel art. The workshop
combines cool blue-grey window light, ivory paper and ceramic, dark neutral
iron, green oxidised copper, and selective warm lamplight. Brass and mahogany
are accents rather than the whole palette.

The room has three readable zones:

- drafting desk and notebook on the left;
- model bench and main apparatus at centre;
- optical instruments, drawers, and failed mechanisms on the right.

The Time Traveller is visually original: lean, shirtsleeved, waistcoated, and
slightly disordered from work. The model machine is based only on Wells'
description of a delicate metallic framework containing ivory, transparent
crystalline material, and levers. It must not resemble a recognisable machine
from a film, television production, illustration, or existing game.

Image generation will be used after interaction blocking to establish the
workshop composition, background layers, prop studies, and character reference.
Production assets must be stored in the repository, documented with prompts and
generation dates, and adjusted for visual continuity in-engine.

### Animation and effects

Movement animation is economical: idle, walk, turn, inspect, and workbench
poses. Workshop props use small loops such as clock motion, lamp flutter, and
moving gauge needles. Nothing should compete with interactable silhouettes.

The successful test is the only large effect. It combines temporal after-images,
brief chromatic separation, local light distortion, a pressure ripple through
papers and flame, disappearance, held silence, and a sharper inverse effect on
return. A reduced-motion toggle in the pause menu substitutes opacity and light
changes for screen displacement and chromatic motion.

### Audio

The ambient bed consists of clockwork, low gas hiss, distant house movement,
and intermittent rain or wind. Interaction sounds distinguish wood, metal,
glass, paper, and ivory. The machine test grows from dry mechanical ticks into
an unfamiliar harmonic tone, drops to silence while the model is absent, then
resolves on return. All audio will be original, generated from committed source
recipes, or obtained under a compatible licence with attribution.

## Technical Design

### Project structure

The Godot project lives at the repository root. Runtime files are grouped under
`game/`, production media under `assets/`, tests under `tests/`, and literary
source material under `source_material/`. Both `docs/` and `source_material/`
contain `.gdignore` files so Godot does not import non-runtime material.

Content identifiers use the stable form `act00.<domain>.<name>`, for example
`act00.item.crystal_prism` and `act00.journal.temporal_bias`. File names and
resource paths are lowercase snake case to avoid case-sensitive export defects.

### Components and boundaries

- **GameSession autoload:** Owns only mutable session state: story flags,
  acquired item IDs, journal entry IDs, and reset. It emits signals when those
  collections change. It never mutates shared content resources.
- **ContentRegistry:** Loads the Act 0 manifest and immutable item, observation,
  and journal resources. It validates unique IDs and references before play.
- **PlayerController:** Owns horizontal movement, facing, and focus selection.
  It knows nothing about story progression.
- **Interactable:** A reusable `Area2D` component exposing a stable action ID,
  focus presentation, and an interaction signal. Individual props provide data
  and visuals rather than duplicating input logic.
- **WorkshopDirector:** Owns the Act 0 state machine and translates interaction
  events into state changes, content responses, and visual commands. Its phases
  are `DISCOVERY`, `ASSEMBLY`, `CALIBRATION`, `EXCURSION`, and `COMPLETE`.
- **ModelWorkbench:** Owns drag-and-drop assembly, stepped calibration controls,
  machine visual state, and activation animation. It emits semantic events and
  does not directly change inventory or journal state.
- **GameHUD:** Owns the observation band, compact inventory, journal overlay,
  pause menu, and input-mode prompts. It reacts to session and director signals.
- **MainFlow:** Starts a fresh session at the cold open, loads the workshop, and
  transitions to the closing card. A separate global scene router is
  unnecessary for one location.

### Data flow

For a workshop action, input selects an `Interactable`, which emits its action
ID. `WorkshopDirector` evaluates that ID against the current phase and session
flags, resolves authored content through `ContentRegistry`, and updates
`GameSession`. Session and director signals then update props, workbench state,
and UI. The same path is used by automated smoke tests without synthesising
low-level key events.

For the close-up, `ModelWorkbench` emits component-placement, calibration, and
lever events. `WorkshopDirector` accepts or rejects the event, records the
result in `GameSession`, and commands the workbench response. This keeps puzzle
rules testable without rendering.

### Fault handling

- Missing or duplicate content IDs fail automated validation and emit a clear
  Godot error naming the offending ID and resource path.
- A missing optional visual uses an intentional neutral placeholder during
  development; missing required puzzle data prevents the chapter from starting.
- Premature or repeated interactions return authored observations and never
  corrupt state.
- Closing and reopening an overlay preserves session progress.
- Restart creates a clean `GameSession`; no disk persistence or network access
  occurs in Act 0.

## Literary Provenance and Licensing

The structured literary reference is the Standard Ebooks source repository for
H. G. Wells' *The Time Machine*, pinned for this project to commit
`9255fefede65b1fd3138d6a802cfd7cde431133c`, retrieved 10 July 2026. Project
Gutenberg eBook 35 is the independent plain-text cross-check. Raw source stays
outside runtime content and is not presented as an official Standard Ebooks or
Project Gutenberg edition.

The repository will contain a concise sources notice recording title, author,
original publication year, source URLs, pinned revision, retrieval date, and
licence status. Wells' original text is treated as public domain. Later
adaptations are not design references.

Project code is released under the MIT licence. Original narrative text and art
created for the project are released under CC BY 4.0. Third-party audio or fonts,
if introduced, require a compatible redistributable licence and explicit
attribution.

## Testing and Verification

The slice uses a small repository-owned headless test harness rather than a
third-party Godot add-on. Tests run through Godot itself and fail the process on
any assertion or engine error.

Automated coverage includes:

- content manifest loading, unique IDs, and valid cross-references;
- inventory and journal idempotency;
- all WorkshopDirector phase transitions, including premature and repeated
  actions;
- correct and incorrect workbench placement and calibration outcomes;
- clean instantiation and teardown of every shipped scene;
- a semantic happy-path smoke sequence from new session to `COMPLETE`;
- restart returning every mutable value to its initial state.

The standard verification sequence is:

```bash
godot --headless --path . --import
godot --headless --path . --quit-after 1
godot --headless --path . --script res://tests/run_all.gd
```

Visual verification covers 1280x720, 1440x900, and 1920x1080 windows. It checks
that the playfield is framed correctly, text does not overlap, overlays remain
within safe margins, focus indicators are legible, and both normal and
reduced-motion activation sequences remain coherent. A final human playthrough
checks discovery, puzzle readability, pacing, prose, and emotional payoff.

## Acceptance Criteria

Act 0 is complete when all of the following are true:

- A clean clone opens in Godot 4.7 and runs without editor intervention.
- The chapter can be completed from the cold open to the closing card using only
  the controls presented by the game.
- A first-time player can infer the three components and calibration state from
  the workshop and journal, without outside instructions.
- Every out-of-order action gives useful feedback and no sequence can soft-lock.
- Installed components, calibration, disappearance, absence, return, and the
  eleven-second discrepancy are all visibly communicated.
- The returned model is narratively available for the next chapter's dinner
  demonstration.
- The art and audio form a coherent draft presentation rather than exposed
  debug geometry or silent placeholder screens.
- Reduced motion preserves all required information.
- Headless import, startup, and all automated tests pass from the command line.
- Source, generated-asset, and licence provenance is present and internally
  consistent.

## Next Chapter Boundary

The closing bell is the contract with the next milestone. Act 1 can add the
dinner guests, dialogue, and the public demonstration while reusing the model,
session data conventions, content registry, interaction language, journal, and
presentation systems proven here. No Act 1 implementation is part of this
specification.
