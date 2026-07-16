# Time Expedition Act 0 R2 Design

**Status:** Approved from the first human beta debrief

**Chapter:** Act 0: The Model

**Engine:** Godot 4.7, 2D, GDScript

## Purpose

This revision turns the existing opening chapter from a short fetch-and-guess
tutorial into the first complete specimen of *Time Expedition's* adventure
grammar. The player should inhabit the Time Traveller's laboratory, learn his
character through observation, distinguish useful experimental components from
plausible alternatives, and calibrate the model by evidence rather than by
enumerating settings.

The reusable loop is:

> Observe -> infer -> choose -> manipulate -> interpret feedback -> revise.

Act 0 remains a compact prologue. It does not become a generic quest engine or
an exhaustive simulation of the house. Its job is to prove the quality bar and
interaction pattern that later expeditions will reuse.

## Beta Findings

The first external playthrough established four material defects:

1. The Time Traveller reads at approximately stool height against the room.
2. Eight widely spaced hotspots leave the laboratory visually rich but
   mechanically thin, and most observations are only one short sentence.
3. Exactly three collectible objects correspond to exactly three empty
   fittings, making assembly a conspicuous fetch quest.
4. Calibration accepts one hard-coded pair from a 5-by-5 setting space, while
   all 24 wrong pairs produce the same response. The optimal strategy is
   therefore grinding rather than reasoning.

These are connected design problems. R2 addresses them as one coherent
specimen rather than as isolated patches.

## Considered Approaches

### A. Enrichment only

Add more descriptive prose and enlarge the character, while retaining the
three-item assembly and calibration rules. This is the cheapest option, but it
does not repair the chapter's core decision-making and would teach the wrong
pattern for later episodes.

### B. Clue-driven laboratory specimen (selected)

Keep the existing scene, state machine, workbench, and excursion payoff, but
increase interaction density, add three plausible alternative components, make
calibration clues discoverable in the room, and make every failed test
diagnostic. This changes the player's mental activity without expanding Act 0
into a new engine.

### C. General adventure-system rewrite

Introduce verbs, item-on-object use, dialogue trees, combination recipes, and a
general puzzle graph before revising the chapter. This could support the whole
game eventually, but it is premature and would delay learning whether the
basic authored loop is enjoyable.

## Player Experience

The revised chapter should take a first-time player approximately 15 to 25
minutes. A curious player can spend longer reading optional observations. The
emotional progression remains curiosity, concentration, uncertainty, wonder,
and anticipation.

The player can finish without examining every optional atmospheric object.
Opening the three candidate stations always gathers both plausible alternatives
for that function, so assembly necessarily presents six candidates rather than
allowing a lucky player to recreate the original three-item fetch. A careful
player who follows the evidence can select all three correct components and
calibrate the machine successfully on the first attempt. A less careful player
can recover through specific, interpretable feedback without a reset or soft
lock.

## Physical Scale

The Time Traveller must read as a lean adult man approximately 5 feet 10 inches
tall within the illustrated room.

- The 512-pixel character cells use a visual scale of `0.62` rather than
  `0.34`.
- The sprite uses position `Vector2(0, -151)`, keeping his shoes on the existing
  floor root while placing the top of his silhouette approximately 275 pixels
  above it.
- The collision capsule uses radius `26`, height `168`, and centre position
  `Vector2(0, -84)`, growing with the visual body while remaining foot-aligned.
- The interaction detector uses a `260`-by-`260` rectangle centred at
  `Vector2(0, -120)`, so the larger figure can focus tabletop and wall-mounted
  objects without standing at implausible distances.
- Camera limits, floor height, walking speed, and the 3200-pixel room width do
  not change.

Scale acceptance is visual as well as numeric: in room captures, his standing
height must be clearly greater than the stools and roughly twice the height of
the low work stools nearest the main bench. His feet must not slide below the
floor, and interaction prompts must remain stable.

## Laboratory Exploration

### Interaction density

The room contains fourteen focused hotspots distributed across its full width.
Existing background details are used as anchors; R2 does not replace the
panorama.

Three hotspots provide paired candidate components:

1. The precision cabinet yields ivory guide bars and brass guide rails.
2. The optical bench yields a crystalline prism and smoked-glass lens.
3. The regulator tray yields paired control levers and a clockwork escapement.

Eleven hotspots deepen the room or provide deductions:

1. Open laboratory notebook.
2. Wall diagrams and trial sketches.
3. House clock and trial chronometer.
4. Chemical glassware and residue.
5. Model bench.
6. Frame-mounted spirit level.
7. Rain-lit Richmond window.
8. Abandoned displacement rig, explicitly an earlier field apparatus rather
   than the later full-scale Time Machine.
9. Adjustable gas lamp.
10. Drafting stool and discarded calculation sheet.
11. Sealed specimen cabinet.

Each hotspot has a specific verb and name. Collection hotspots have an
authored post-collection observation. Optional inspections use two or three
substantial sentences where the subject warrants them, preserving a dry,
empirical first-person voice rather than padding every object to a fixed
length.

### Stateful observations

The stateful observation matrix is bounded and explicit:

| Hotspot | States with distinct text |
| --- | --- |
| notebook | initial discovery; after either datum; calibration |
| model bench | fewer than six candidates gathered; all six gathered; calibration |
| house clock | first inspection and datum recording; repeat inspection |
| spirit level | first inspection and datum recording; repeat inspection |
| abandoned displacement rig | discovery/assembly; calibration |

The excursion and completion phases intentionally suppress free workshop
interaction while the authored return and handoff play. No completion-phase
hotspot variant is required. Repeated paired collection cannot duplicate
inventory or erase the richer post-collection description.

Observations remain dismissible and do not create mandatory dialogue chains.
Critical deductions are copied to the journal. Optional atmosphere is not
misrepresented as a puzzle prerequisite.

## Component Reasoning

### Candidate properties

The six inventory descriptions expose properties rather than labelling objects
as correct or incorrect:

| Candidate | Relevant property | Puzzle role |
| --- | --- | --- |
| Ivory guides | light, smooth, electrically inert | correct longitudinal guides |
| Brass rails | precisely machined but heavy and conductive | plausible guide decoy |
| Crystalline prism | transparent, faceted, clean spectral division | correct optical core |
| Smoked lens | optical glass that absorbs rather than divides light | plausible optical decoy |
| Paired levers | light common yoke with white departure handle | correct actuator |
| Escapement | precise regulator with friction and periodic arrest | plausible control decoy |

The notebook records the three required functions and their material
constraints, but does not list item names. A player can therefore infer each
choice by comparing observations and inventory descriptions.

### Assembly interaction

The workbench tray presents all six candidates in a stable six-position row
after the three paired candidate stations have been opened. Selecting a
candidate permits an attempt in any unfilled fitting. Acceptance retains the
exact matching contract: only ivory guides fit the guide sockets, only the
crystalline prism fits the optical cradle, and only the paired control levers
fit the actuator pivots. A component that is correct for one function is still
rejected from either of the other two fittings with geometry-specific feedback.

A correct component seats permanently for the session. An incorrect component
returns to the tray and produces a reason specific to the candidate and
fitting, such as excess conductivity, absorbed light, mechanical friction, or
incompatible geometry. The response teaches a property; it does not merely say
"wrong". No item is consumed, destroyed, or made unavailable by an error.

Assembly unlocks calibration when the three required fittings are filled. The
three alternatives remain in inventory as evidence of the player's search and
as a precedent for later adventure episodes, where carrying a plausible but
irrelevant object may matter elsewhere.

## Calibration Reasoning

### Discoverable clues

The calibration target remains spatial alignment `0` and temporal bias `+1`,
but the journal no longer displays those values before the player discovers
them.

- Inspecting the frame-mounted spirit level records the spatial datum: the
  bubble rests between the two central scratches, establishing equilibrium at
  zero.
- Inspecting the house clock and trial chronometer records the temporal datum:
  the coherent trial led ordinary time by one engraved division, establishing
  a positive bias of one.
- The notebook points the player toward those two measuring instruments and
  records why both values are required.

The journal sketch reveals each value independently as its deduction is made.
Before discovery, it shows a named blank rather than the solution.

### Diagnostic experiments

Both controls have the exact domain `[-2, -1, 0, +1, +2]` and reset to `(0, 0)`
at the start of a session. Pulling the lever with an incorrect setting produces
one of eight diagnoses, derived from the sign pair
`(sign(spatial - 0), sign(temporal - 1))`:

| Spatial relation | Temporal relation | Machine evidence |
| --- | --- | --- |
| negative | correct | field drags left; temporal tone holds |
| positive | correct | field drags right; temporal tone holds |
| correct | low | frame remains centred; cadence lags |
| correct | high | frame remains centred; cadence races |
| negative | low | leftward drag and lagging cadence |
| negative | high | leftward drag and racing cadence |
| positive | low | rightward drag and lagging cadence |
| positive | high | rightward drag and racing cadence |

The observation band supplies the Time Traveller's interpretation. The
workbench status supplies a compact instrument reading, for example `FIELD:
RIGHT | RATE: SLOW`. The first misfire adds a journal note explaining that
directional pull diagnoses spatial error and cadence diagnoses temporal error.

Thus a player who missed the room clues can still converge intelligently. The
24 incorrect pairs no longer collapse to one indistinguishable response.
Brute-force enumeration remains technically possible as an accessibility
fallback, but it is slower and less informative than deduction.

## Interface Changes

### Inventory

The instrument satchel becomes a three-column grid supporting six candidates
within its existing bounded overlay. Each entry retains icon, name, and concise
property description. Text must remain inside the 1280-by-720 logical viewport
at all verified window sizes.

### Journal

The left page retains scrollable authored entries. The right experiment sketch
is generated from discovered journal IDs:

- spatial datum unknown or `0`;
- temporal datum unknown or `+1`;
- white lever remains identified as departure.

The journal must never reveal an undiscovered calibration value.

### Workbench

The close-up retains three fittings, stepped controls, excursion presentation,
and the closing cloth. Its tray expands to six compact candidates without
changing the machine's visual footprint. Calibration status has a stable
minimum height sufficient for the longest diagnostic at all target viewports.

## Technical Design

The existing boundaries remain authoritative:

- `GameSession` owns mutable item, journal, and flag state.
- `ContentRegistry` owns immutable item, observation, and journal resources.
- `WorkshopDirector` owns collection mappings, phase transitions, component
  acceptance, clue flags, and calibration diagnosis.
- `Act00Workshop` wires semantic events to HUD, audio, prop visibility, and
  workbench presentation.
- `ModelWorkbench` owns token controls, fitting controls, status presentation,
  and excursion visuals.

R2 extends these units rather than adding a generic puzzle framework.

### Stable content

All six items, new journal entries, and new observations use stable
`act00.<domain>.<name>` IDs and are produced deterministically by
`tools/build_content.gd`. New decoy icons are deterministic repository-owned
art derivatives with provenance. Runtime content does not depend on network or
AI services.

### Calibration contract

`WorkshopDirector` exposes the current two-dimensional signed calibration
relation and the stable diagnostic observation ID selected for the most recent
misfire. Tests can therefore verify all 25 settings without inspecting prose.
The successful pair is the sole zero-error state.

## Testing

Behavioral changes follow red-green TDD. Automated coverage must include:

- exact player visual, collision, and interaction scale contract;
- fourteen unique workshop action IDs and stable focus geometry;
- six unique inventory items and valid art references;
- idempotent collection of required and alternative components;
- all required-versus-decoy placement outcomes and reason-specific feedback;
- conditional journal sketch values before and after each clue;
- all 25 calibration settings, with one success and 24 non-empty diagnoses;
- exactly eight diagnostic IDs, each bound to the exact relation row in the
  diagnostic table, with every wrong setting mapping to the ID for its sign
  pair;
- the exact stateful-observation matrix for notebook, bench, clock, spirit
  level, and abandoned displacement rig;
- existing out-of-order, overlay, pause, restart, reduced-motion, excursion,
  return, and chapter-handoff paths;
- deterministic content and art regeneration.

Visual QA covers the existing three viewports. Captures add representative
states for adult player scale, dense focus prompts, six-item inventory, six-item
workbench tray, undiscovered journal clues, discovered journal clues, and at
least two contrasting misfire diagnoses.

## Acceptance Criteria

R2 is ready for the next human beta playthrough when:

- the Time Traveller reads as an adult and remains correctly foot-aligned;
- all fourteen hotspots are reachable and their prompts do not flicker or
  overlap incoherently;
- optional inspection materially enriches the room and the protagonist;
- six candidate components can be collected without duplication;
- component choice is inferable from recorded properties;
- every wrong assembly attempt explains a relevant incompatibility;
- neither calibration value appears in the journal before its clue is found;
- a clue-following player can derive `(0, +1)` before the first test;
- every wrong calibration produces directionally useful machine feedback;
- no path consumes an item, resets progress, soft-locks, or bypasses the return
  acknowledgement;
- the original four-second absence, fifteen-second onboard reading, cloth
  cover, clock strike, bell, and closing card remain intact;
- the complete verification suite, clean-archive verification, and visual QA
  pass; and
- an independent whole-branch review reports no unresolved Critical or
  Important findings.

## Explicit Non-Goals

R2 does not add dialogue trees, NPCs, item combinations, multiple solutions,
save files, controller support, voice acting, another room, the dinner-party
demonstration, or a reusable quest/puzzle language. Those decisions should be
informed by the next beta playthrough rather than anticipated here.
