# Act 0 Playtest Evidence

Date: 10 July 2026
Engine: Godot `4.7.stable.official.5b4e0cb0f`
Host: Barry's Apple Silicon Mac mini

## Automated Verification

- Deterministic art build: PASS
- Deterministic audio build: PASS
- Deterministic content build: PASS
- Headless Godot import: PASS
- Bounded main and workshop startup: PASS
- Complete GDScript test suite: PASS, 912 assertions
- Generated-surface diff and untracked-generated-file gate: PASS
- Second full `scripts/verify.sh` run: PASS with the same 912 assertions

## Viewports

The repository QA harness captured 15 states at each viewport into `/private/tmp/time-expedition-qa-final/`, outside the repository. Each run completed warning-clean and rejected flat screenshots before writing them.

| Viewport | Text and overlays | Camera and room | Workbench | Effects |
| --- | --- | --- | --- | --- |
| 1280x720 | PASS | PASS | PASS | PASS |
| 1440x900 | PASS | PASS | PASS | PASS |
| 1920x1080 | PASS | PASS | PASS | PASS |

Each viewport inventory contains: cold open; left, centre, and right room; left, centre, and right focus; observation; inventory; journal; workbench; pause; normal temporal absence; closing card; and reduced-motion temporal absence.

## Playthroughs

- Canonical misfire, corrected calibration, and success: PASS
- Components-before-notebook with repeated bench reopening: PASS
- Wrong-slot, repeated collection, and repeated lever resistance: PASS
- Inventory, journal, pause, resume, and restart path: PASS
- Reduced-motion completion: PASS

The authored matrix uses real main/workshop scenes, parses input where appropriate, reaches the closing card for every listed path, and checks the four-second absence plus the fifteen-versus-four-second return observation in normal and reduced modes.

## Visual Findings

- Camera snapping in the QA harness keeps the focused player and target in-frame at all three resolutions.
- The workbench and pause modal hide the inert journal/inventory toolbar, leaving one unambiguous top-right close control.
- The closing card now renders above the temporal screen-texture layer rather than producing a flat capture buffer.
- Text fits its parent surfaces; modal layers do not conflict; workbench geometry remains stable; and normal/reduced temporal states are visually distinct.

## Residual Scope

Save files, controller support, localisation, voice acting, combat, hazards, branching dialogue, web export, the dinner-party demonstration, and later time periods are intentionally outside Act 0.

The headless Godot test runner still prints the pre-existing post-suite cleanup note about four ObjectDB instances and two resources after its PASS result. The non-headless QA harness itself was rerun warning-clean at all three viewport sizes.
