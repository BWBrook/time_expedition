# Act 0 Playtest Evidence

Date: 16 July 2026
Engine: Godot `4.7.stable.official.5b4e0cb0f`
Host: Barry's Apple Silicon Mac mini

## Automated Verification

- Complete GDScript test suite: PASS, 2,155 assertions.
- R2 resistance paths: PASS. Each paired station is idempotent; counts are 2,
  4, and 6 candidates, with exactly six unique session items at completion.
- Exact assembly contract: PASS. Only ivory guides, crystalline prism, and
  paired control levers fit; rejected decoys preserve selection, availability,
  placements, and recoverability.
- Clue order paths: PASS. Clock and spirit-level clues work independently both
  before and after collection; journal sketch values reveal only the discovered
  datum.
- Diagnostic resistance: PASS. Relations `(-1,+1)` and `(+1,-1)` remain in
  `CALIBRATION` with exact IDs `act00.observation.misfire.left_fast` and
  `act00.observation.misfire.right_slow`, and statuses `FIELD: LEFT | RATE:
  FAST` and `FIELD: RIGHT | RATE: SLOW`.
- Restart resistance: PASS. Items, clue journals, placements, and
  `last_calibration_feedback_id` clear after restart.
- Existing canonical, out-of-order/reopened bench, pause/modal, normal and
  reduced-motion excursion, return, cloth, and closing paths: PASS.
- Capture launcher and direct output boundary checks remain covered, including
  canonicalisation, symlink escape rejection, exact ordered labels, PNG reload,
  fitted content sizing, and flat-image rejection.

## R2 Capture Matrix

The harness retains the existing 23 labels in relative order and inserts these
nine states after `pause` and before `normal_assembled`, for exactly 32 unique
labels:

`adult_scale_left`, `dense_focus_centre`, `inventory_six_candidates`,
`journal_clues_hidden`, `journal_spatial_only`, `journal_clues_complete`,
`workbench_six_candidates`, `misfire_left_fast`, `misfire_right_slow`.

The deterministic setup uses only the final paired actions
`collect_guides_and_rails`, `collect_prism_and_lens`, and
`collect_levers_and_escapement`. The hidden journal capture uses a fresh session
with only the experiment entry; the spatial-only and complete captures then add
the spatial and temporal datum entries independently. Misfire captures are
dismissed before the next diagnostic and leave the assembled machine in
`CALIBRATION` for the successful temporal path.

## Viewport Evidence

Final evidence was captured outside the repository at three viewport sizes:

- Evidence directory: `/private/tmp/time-expedition-act0-r2-final.cucRKn/`
- Contact sheets: one each under `1280x720/`, `1440x900/`, and
  `1920x1080/`.
- Saved PNGs: 32 per viewport, 96 total.
- Dimensions: every file exactly matches its named viewport.
- Pillow variance: global minimum maximum-channel variance 215.89; flat images
  0.
- Letterbox contract: all 32 captures at 1440x900 have exactly 45 black rows
  above and below the 1440x810 content area.

The contact sheet and focused full-resolution states were inspected for adult
scale and grounded feet, dense focus/prompt coherence, six-cell inventory,
journal secrecy and reveal, six-token workbench layout, contrasting diagnostic
prose/status, overlap, truncation, blank content, normal/reduced temporal
states, cloth handoff, and closing card. All inspected states were readable and
non-flat. The first inspection found clipped lower-row inventory descriptions
and collisions in the longest workbench labels at 1280x720. Those defects were
corrected before this final matrix; the complete matrix was then recaptured and
reinspected at all three sizes.

## Residual Scope

Save files, controller support, localisation, voice acting, combat, hazards,
branching dialogue, web export, the dinner-party demonstration, later time
periods, and other chapters remain outside this task.

The captures were validated on the macOS OpenGL compatibility renderer; another
platform or rendering backend could still expose presentation differences. The
automated and visual checks establish the scripted paths and presentation
states, but do not replace a fresh human playthrough for pacing, clue salience,
or puzzle satisfaction.
