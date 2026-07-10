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
- Complete GDScript test suite: PASS, 931 assertions
- Generated-surface diff and untracked-generated-file gate: PASS
- Final re-review `scripts/verify.sh` run: PASS with the launcher regression and 931 assertions
- Canonical output and symlink-escape checks at both launcher and direct GDScript boundaries: PASS

## Viewports

The repository QA harness captured 15 states at each viewport into `/private/tmp/time-expedition-qa-viewport-final/`, outside the repository. Each run completed warning-clean. The launcher passed a real Godot `--resolution` before the capture script, while the harness independently checked the aspect-fitted content texture, composited it onto the requested framebuffer, rejected flat content, and reloaded each PNG to confirm its saved dimensions.

| Requested framebuffer | Expected Godot content | Saved PNGs | Framing |
| --- | --- | --- | --- |
| 1280x720 | 1280x720 | 15 at 1280x720 | Full frame |
| 1440x900 | 1440x810 | 15 at 1440x900 | Centred, 45px black top and bottom letterboxes |
| 1920x1080 | 1920x1080 | 15 at 1920x1080 | Full frame |

| Viewport | Text and overlays | Camera and room | Workbench | Effects |
| --- | --- | --- | --- | --- |
| 1280x720 | PASS | PASS | PASS | PASS |
| 1440x900 | PASS | PASS | PASS | PASS |
| 1920x1080 | PASS | PASS | PASS | PASS |

Each viewport inventory contains: cold open; left, centre, and right room; left, centre, and right focus; observation; inventory; journal; workbench; pause; normal temporal absence; closing card; and reduced-motion temporal absence.

ImageMagick independently reported the exact requested dimensions for all 45 frames. Pillow decoded all 45, found nontrivial variance in every image (minimum maximum-channel variance `215.95`), and confirmed that all 15 `1440x900` files have exactly 45 black rows above and below the centred content.

The final boundary-only re-review did not regenerate screenshots. A fresh ImageMagick audit confirmed that the existing archive still contains exactly 15 files at each recorded size, 45 total.

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
- Three full contact sheets covered every frame; focus, observation, inventory, journal, workbench, pause, normal/reduced temporal, and closing states were also inspected at full resolution for every viewport.
- Text fits its parent surfaces; modal layers do not conflict; workbench geometry remains stable; square icon controls remain square; and normal/reduced temporal states are visually distinct.

## Residual Scope

Save files, controller support, localisation, voice acting, combat, hazards, branching dialogue, web export, the dinner-party demonstration, and later time periods are intentionally outside Act 0.

The final headless verification and the prior non-headless QA captures completed warning-clean. Captures were validated on the macOS OpenGL compatibility renderer; another platform or rendering backend could still expose presentation differences.
