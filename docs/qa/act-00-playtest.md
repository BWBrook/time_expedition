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
- Complete GDScript test suite: PASS, 1,112 assertions
- Generated-surface diff and untracked-generated-file gate: PASS
- Final focused re-review `scripts/verify.sh` run: PASS with launcher/direct-harness regression and 1,112 assertions
- Canonical output and symlink-escape checks at both launcher and direct GDScript boundaries: PASS

## Viewports

The repository QA harness captured 23 states at each viewport into `/private/tmp/time-expedition-qa-final-controls.GDBn50/`, outside the repository. Each run completed warning-clean. The launcher passed a real Godot `--resolution` before the capture script, while the harness independently checked the aspect-fitted content texture, composited it onto the requested framebuffer, rejected flat content, enforced the exact ordered state inventory, and reloaded each PNG to confirm its saved dimensions.

| Requested framebuffer | Expected Godot content | Saved PNGs | Framing |
| --- | --- | --- | --- |
| 1280x720 | 1280x720 | 23 at 1280x720 | Full frame |
| 1440x900 | 1440x810 | 23 at 1440x900 | Centred, 45px black top and bottom letterboxes |
| 1920x1080 | 1920x1080 | 23 at 1920x1080 | Full frame |

| Viewport | Text and overlays | Camera and room | Workbench | Effects |
| --- | --- | --- | --- | --- |
| 1280x720 | PASS | PASS | PASS | PASS |
| 1440x900 | PASS | PASS | PASS | PASS |
| 1920x1080 | PASS | PASS | PASS | PASS |

Each viewport inventory contains: cold open; left, centre, and right room; left, centre, and right focus; observation; inventory; journal; pause; normal assembled, departure, clear absence, return pulse, returned discrepancy, cloth handoff, and closing card; and reduced-motion assembled, departure, clear absence, return pulse, and returned discrepancy.

ImageMagick independently reported the exact requested dimensions for all 69 frames. Pillow decoded all 69, found nontrivial variance in every image (minimum maximum-channel variance `215.95`), and confirmed that all 23 `1440x900` files have exactly 45 black rows above and below the centred content.

## Playthroughs

- Canonical misfire, corrected calibration, and success: PASS
- Components-before-notebook with repeated bench reopening: PASS
- Wrong-slot, repeated collection, and repeated lever resistance: PASS
- Inventory, journal, pause, resume, and restart path: PASS
- Reduced-motion completion: PASS

The authored matrix uses real main/workshop scenes, parses input where appropriate, reaches the closing card for every listed path, and checks the measured four-second absence plus the fifteen-versus-four-second return observation in normal and reduced modes. It also completes room interactions through the visible focus-command button, retains keyboard interaction coverage, verifies that inventory and journal overlays block real movement and interaction input, checks that return audio begins with reappearance, and proves that the workbench cannot be closed between successful lever acceptance and the final handoff.

## Visual Findings

- Camera snapping in the QA harness keeps the focused player and target in-frame at all three resolutions.
- The focused interaction surface is a clear, clickable command button; keyboard activation remains available without requiring tutorial copy.
- The workbench and pause modal hide the inert journal/inventory toolbar, leaving one unambiguous top-right close control.
- All three fitted components are visibly installed on the model, persist across workbench reopening, and disappear completely during the authored absence.
- The normal return has a distinct distortion pulse; reduced motion uses restrained fades; both settle on the readable fifteen-second chronometer discrepancy.
- The returned model remains visible under the acknowledgement observation, then the clock strike, full-span green cloth cover, door bell, and closing card play in order.
- The closing card now renders above the temporal screen-texture layer rather than producing a flat capture buffer.
- Three full contact sheets covered every frame; assembled, absence, return, discrepancy, cloth, and closing states were also inspected at full resolution.
- Text fits its parent surfaces; modal layers do not conflict; workbench geometry remains stable; square icon controls remain square; and normal/reduced temporal states are visually distinct.

## Residual Scope

Save files, controller support, localisation, voice acting, combat, hazards, branching dialogue, web export, the dinner-party demonstration, and later time periods are intentionally outside Act 0.

The final headless verification and the prior non-headless QA captures completed warning-clean. Captures were validated on the macOS OpenGL compatibility renderer; another platform or rendering backend could still expose presentation differences.
