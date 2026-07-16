# Time Expedition Act 0 R2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Act 0's underscaled protagonist, sparse workshop, three-item fetch, and undifferentiated calibration grind with a clue-driven laboratory specimen ready for a second human beta playthrough.

**Architecture:** Preserve the existing `GameSession`, `ContentRegistry`, `WorkshopDirector`, `Act00Workshop`, `ModelWorkbench`, and HUD boundaries. Extend immutable content to six candidates and richer observations; make `WorkshopDirector` own paired collection, exact fitting decisions, clue state, and eight-way calibration diagnosis; keep visual and input presentation in the existing scenes.

**Tech Stack:** Godot `4.7.stable.official.5b4e0cb0f`, 2D GDScript, custom Resources, repository-owned GDScript tests, SVG source art rendered by ImageMagick `7.1.2-26`, Pillow `12.2.0`, and shell verification.

## Global Constraints

- Work only in the isolated `codex/act-0-r2` worktree; do not alter the dirty main-checkout `project.godot`.
- Retain the 1280-by-720 logical viewport and verify 1280x720, 1440x900, and 1920x1080 windows.
- Retain the 3200-pixel workshop, four-second model absence, fifteen-second onboard reading, return acknowledgement, cloth cover, clock strike, bell, and closing card.
- Only `GameSession` owns mutable story state; shared Resource instances remain immutable.
- The six candidates are always gathered as three paired collections: ivory/brass, prism/smoked glass, and levers/escapement.
- Only the exact required item-to-slot mapping is accepted; all fifteen wrong pairs have authored feedback.
- Calibration controls each use `[-2, -1, 0, +1, +2]`, reset to `(0, 0)`, and succeed only at `(0, +1)`.
- The eight wrong-relation sign pairs map to exactly eight stable diagnostic IDs.
- Journal values remain hidden until their room clues are inspected.
- Do not add NPCs, dialogue trees, item combinations, save files, another room, a generic quest system, or network/AI runtime dependencies.
- Follow red-green TDD for every behavioral task. Use `apply_patch` for manual edits and preserve unrelated changes.

---

### Task 1: Adult Player Scale and Fourteen-Hotspot Contract

**Files:**
- Create: `tests/test_workshop_scene_contract.gd`
- Modify: `tests/run_all.gd`
- Modify: `tests/test_art_assets.gd`
- Modify: `game/player/player.tscn`
- Modify: `game/act_00/workshop.tscn`

**Interfaces:**
- Consumes: existing `PlayerController`, `Interactable`, player atlas, and panorama.
- Produces: the exact adult-scale scene contract and fourteen unique action IDs.

- [ ] **Step 1: Write the failing scale and hotspot test**

Register `test_workshop_scene_contract.gd` in `tests/run_all.gd`. Instantiate the player and assert:

```gdscript
suite.expect_equal(sprite.scale, Vector2(0.62, 0.62), "adult visual scale")
suite.expect_equal(sprite.position, Vector2(0, -151), "adult visual anchor")
suite.expect_equal(capsule.radius, 26.0, "adult collision radius")
suite.expect_equal(capsule.height, 168.0, "adult collision height")
suite.expect_equal(capsule_node.position, Vector2(0, -84), "adult collision anchor")
suite.expect_equal(range_shape.size, Vector2(260, 260), "adult interaction size")
suite.expect_equal(range_node.position, Vector2(0, -120), "adult interaction anchor")
```

Instantiate the workshop and assert exactly these sorted action IDs:

```text
act00.action.notebook
act00.action.diagrams
act00.action.collect_guides_and_rails
act00.action.clock
act00.action.glassware
act00.action.bench
act00.action.spirit_level
act00.action.window
act00.action.collect_prism_and_lens
act00.action.collect_levers_and_escapement
act00.action.displacement_rig
act00.action.gas_lamp
act00.action.drafting_stool
act00.action.specimen_cabinet
```

Update the existing atlas assertions to the new visual scale and position.

- [ ] **Step 2: Run the suite and confirm red**

Run `godot --headless --path . --script res://tests/run_all.gd`.

Expected: adult-scale and missing-action failures.

- [ ] **Step 3: Apply the exact player dimensions**

Set the player sprite, capsule, and detector to the values asserted in Step 1. Keep the player root foot-aligned and retain movement speed, camera limits, floor height, and room width.

- [ ] **Step 4: Rebuild the fourteen scene anchors**

Use this exact action-to-x map: notebook `260`, drafting stool `480`, diagrams `650`, guide/rail cabinet `850`, clock `1150`, glassware `1350`, bench `1580`, spirit level `1810`, window `2050`, optical pair `2300`, control pair `2620`, displacement rig `2820`, gas lamp `2990`, specimen cabinet `3140`. Every node is an `Area2D` using `Interactable`, a unique prompt verb/name, a collision shape, and a `FocusVisual`. Preserve `Bench` focus priority `2`.

- [ ] **Step 5: Verify and commit**

Run Godot import and the complete GDScript suite. Expected: both exit 0 with no focus or scene regression.

```bash
git add game/player/player.tscn game/act_00/workshop.tscn tests/test_workshop_scene_contract.gd tests/test_art_assets.gd tests/run_all.gd
git commit -m "feat: rescale traveller and enrich workshop anchors"
```

### Task 2: Six-Candidate Content, Narrative, and Decoy Art

**Files:**
- Create: `assets/art/act_00/source/brass_rails.svg`
- Create: `assets/art/act_00/source/smoked_lens.svg`
- Create: `assets/art/act_00/source/clockwork_escapement.svg`
- Generate: `assets/art/act_00/brass_rails.png`
- Generate: `assets/art/act_00/smoked_lens.png`
- Generate: `assets/art/act_00/clockwork_escapement.png`
- Modify: `tools/process_art.sh`
- Modify: `assets/art/act_00/ASSET_PROVENANCE.md`
- Modify: `tools/build_content.gd`
- Generate: `game/content/act_00/act_00_manifest.tres`
- Modify: `game/content/content_registry.gd`
- Modify: `tests/test_content_registry.gd`
- Modify: `tests/test_art_assets.gd`

**Interfaces:**
- Consumes: immutable content Resources and the deterministic art processor.
- Produces: six items, eight journals, at least 55 observations, and six valid 256-by-256 candidate icons.

- [ ] **Step 1: Write failing content and art assertions**

Require exact item count `6`, journal count at least `8`, and observation count at least `55`. Assert lookup and icons for:

```gdscript
const CANDIDATES := [
    &"act00.item.ivory_guides", &"act00.item.brass_rails",
    &"act00.item.crystal_prism", &"act00.item.smoked_lens",
    &"act00.item.control_levers", &"act00.item.clockwork_escapement",
]
const DEDUCTIONS := [
    &"act00.journal.experiment", &"act00.journal.materials",
    &"act00.journal.components", &"act00.journal.spatial_datum",
    &"act00.journal.temporal_datum", &"act00.journal.calibration",
    &"act00.journal.misfire", &"act00.journal.success",
]
```

Extend art tests with the three source SVGs, runtime PNGs, item bindings, workbench token paths, 256-by-256 dimensions, transparent corners, and nontrivial alpha coverage.

- [ ] **Step 2: Run the suite and confirm red**

Run the complete GDScript suite. Expected: missing item, journal, observation, source-vector, and icon failures.

- [ ] **Step 3: Add deterministic source vectors and processor rules**

Create transparent, text-free 256-by-256 SVGs showing: two gold-brass rails with mounting holes; a charcoal smoked lens in a nickel rim; and a brass escape wheel with steel anchor and pivot jewels. Add exact processing:

```bash
for icon in brass_rails smoked_lens clockwork_escapement; do
    require_file "$source_dir/$icon.svg"
    magick -background none "$source_dir/$icon.svg" \
        -filter Lanczos -resize '200x200' -gravity center -extent 256x256 \
        -strip -define png:exclude-chunk=time "$output_dir/$icon.png"
done
```

Include SVGs in generated source checksums. Document them as original hand-authored vector sources, separately from ImageGen plates.

- [ ] **Step 4: Build the complete content recipe**

Extend `ITEM_ICON_PATHS` and `manifest.items` for all candidates. Inventory descriptions expose these properties: light/inert ivory; heavy/conductive brass; transparent spectral prism; absorbing smoked glass; paired low-friction levers with white handle; periodically arresting escapement.

Add the eight journals and observations for the fourteen hotspots, paired first/repeat collection, exact state matrix, fifteen wrong item-slot pairs, existing progression, and these exact diagnostics:

```text
act00.observation.misfire.left_slow
act00.observation.misfire.left_correct
act00.observation.misfire.left_fast
act00.observation.misfire.centred_slow
act00.observation.misfire.centred_fast
act00.observation.misfire.right_slow
act00.observation.misfire.right_correct
act00.observation.misfire.right_fast
```

Use these stable state IDs:

```text
act00.observation.notebook
act00.observation.notebook_after_datum
act00.observation.notebook_calibration
act00.observation.bench_missing
act00.observation.bench_ready
act00.observation.bench_calibration
act00.observation.clock
act00.observation.clock_repeat
act00.observation.spirit_level
act00.observation.spirit_level_repeat
act00.observation.displacement_rig
act00.observation.displacement_rig_calibration
```

Name each rejection `act00.observation.reject.<item_slug>.<slot_slug>`, where item slugs are `ivory_guides`, `brass_rails`, `crystal_prism`, `smoked_lens`, `control_levers`, and `clockwork_escapement`, and slot slugs are `ivory_guides`, `crystal_prism`, and `control_levers`. Create every cross-product ID except the three matching required pairs, for exactly fifteen rejection IDs.

Every diagnostic names both lateral field pull and temporal cadence. Room observations normally use two or three sentences where the subject warrants it.

- [ ] **Step 5: Extend strict manifest validation**

Add every new required item, journal, and critical observation ID to the strict Act 0 contract. Preserve generic partial-manifest validation for fixtures.

- [ ] **Step 6: Generate, verify, and commit**

Run art processing, Godot import, content build, second import, and the full GDScript suite. Expected: all exit 0 and generated surfaces are deterministic.

```bash
git add assets/art/act_00 tools/process_art.sh tools/build_content.gd game/content/act_00/act_00_manifest.tres game/content/content_registry.gd tests/test_content_registry.gd tests/test_art_assets.gd
git commit -m "feat: add Act 0 candidates and richer content"
```

### Task 3: Paired Collection, Fitting Reasoning, and Diagnosis

**Files:**
- Modify: `game/act_00/workshop_director.gd`
- Modify: `tests/test_workshop_director.gd`

**Interfaces:**
- Consumes: six item IDs and authored observation/journal IDs from Task 2.
- Produces: `calibration_relation() -> Vector2i`, `last_calibration_feedback_id: StringName`, `calibration_feedback_requested(id, instrument_text)`, paired collection, clues, and exact fitting feedback.

- [ ] **Step 1: Write the failing R2 director matrix**

Test three paired actions acquiring six unique items idempotently, clue actions adding only their datum journal, all eighteen item-slot pairs, and the bounded state matrix. Test all 25 calibration settings with this exact oracle:

```gdscript
const DIAGNOSTICS := {
    Vector2i(-1, -1): &"act00.observation.misfire.left_slow",
    Vector2i(-1, 0): &"act00.observation.misfire.left_correct",
    Vector2i(-1, 1): &"act00.observation.misfire.left_fast",
    Vector2i(0, -1): &"act00.observation.misfire.centred_slow",
    Vector2i(0, 1): &"act00.observation.misfire.centred_fast",
    Vector2i(1, -1): &"act00.observation.misfire.right_slow",
    Vector2i(1, 0): &"act00.observation.misfire.right_correct",
    Vector2i(1, 1): &"act00.observation.misfire.right_fast",
}

for spatial in range(-2, 3):
    for temporal in range(-2, 3):
        if spatial == 0 and temporal == 1:
            continue
        director.update_calibration(spatial, temporal)
        var expected := Vector2i(signi(spatial), signi(temporal - 1))
        suite.expect_equal(director.calibration_relation(), expected, "signed relation")
        suite.expect_true(not director.pull_lever(), "wrong pair remains recoverable")
        suite.expect_equal(director.last_calibration_feedback_id, DIAGNOSTICS[expected], "exact diagnosis")
```

Run `(0, +1)` only after the 24 wrong settings so the matrix remains in `CALIBRATION`.

- [ ] **Step 2: Run the suite and confirm red**

Expected: failures for paired actions, clue state, relation API, and feedback signal.

- [ ] **Step 3: Implement paired collection and stateful clues**

Map each paired action to two item IDs plus first/repeat observations. `_collect_pair()` acquires both atomically and repeated use changes no inventory. Clock and spirit-level actions add their datum journals idempotently. Implement this exact state matrix: notebook uses `notebook` initially, `notebook_after_datum` after either datum, and `notebook_calibration` in calibration; bench uses `bench_missing` with fewer than six items, `bench_ready` with all six before calibration, and `bench_calibration` in calibration; clock and spirit level each use first/repeat IDs; displacement rig uses its base ID in discovery/assembly and calibration ID in calibration. Ignore interactions during `EXCURSION` and `COMPLETE`.

- [ ] **Step 4: Implement all fifteen rejection reasons**

Keep `REQUIRED_SLOTS` unchanged. Add a complete map for every nonmatching item-slot pair. Accept only `REQUIRED_SLOTS[slot_id] == item_id`; otherwise emit the mapped observation and preserve inventory and placements.

- [ ] **Step 5: Implement eight-way relation feedback**

Add:

```gdscript
signal calibration_feedback_requested(id: StringName, instrument_text: String)
var last_calibration_feedback_id := StringName()

func calibration_relation() -> Vector2i:
    return Vector2i(signi(spatial_alignment), signi(temporal_bias - 1))
```

Map the eight relations to the exact IDs and `FIELD: LEFT/CENTRED/RIGHT | RATE: SLOW/CORRECT/FAST`. On wrong pull, add the idempotent misfire journal, emit observation and feedback, and remain in `CALIBRATION`. Reset the last ID during initialization and success.

- [ ] **Step 6: Verify and commit**

Run the full GDScript suite. Expected: paired collections, all eighteen placements, exact state matrix, all 24 diagnoses, and the sole success pair pass.

```bash
git add game/act_00/workshop_director.gd tests/test_workshop_director.gd
git commit -m "feat: make Act 0 puzzles evidence driven"
```

### Task 4: Six-Item Inventory and Conditional Journal

**Files:**
- Modify: `game/ui/inventory_tray.gd`
- Modify: `game/ui/inventory_tray.tscn`
- Modify: `game/ui/journal_overlay.gd`
- Modify: `game/ui/game_hud.gd`
- Modify: `tests/test_game_hud.gd`

**Interfaces:**
- Consumes: six item definitions and spatial/temporal datum journal IDs.
- Produces: bounded three-column inventory and independently revealed journal values.

- [ ] **Step 1: Write failing HUD assertions**

Acquire all six items and assert six inventory cells, a three-column grid, and cells no wider than 310 logical pixels. Expose `JournalOverlay.sketch_text()` through `GameHUD.journal_sketch_text()` and test:

```gdscript
session.add_journal_entry(&"act00.journal.experiment")
hud.open_journal()
suite.expect_true(hud.journal_sketch_text().contains("Spatial datum: not yet verified"), "spatial hidden")
suite.expect_true(hud.journal_sketch_text().contains("Temporal datum: not yet verified"), "temporal hidden")

session.add_journal_entry(&"act00.journal.spatial_datum")
hud.open_journal()
suite.expect_true(hud.journal_sketch_text().contains("Spatial datum: 0"), "spatial revealed")
suite.expect_true(not hud.journal_sketch_text().contains("Temporal datum: +1"), "temporal still hidden")

session.add_journal_entry(&"act00.journal.temporal_datum")
hud.open_journal()
suite.expect_true(hud.journal_sketch_text().contains("Temporal datum: +1"), "temporal revealed")
```

- [ ] **Step 2: Run and confirm red**

Expected: the current HBox overflows and the journal reveals both values immediately.

- [ ] **Step 3: Build the bounded grid**

Change `Items` to `GridContainer` with `columns = 3`, horizontal separation `18`, vertical separation `12`, and overlay top `300`. Build each item as a 300-by-118 `HBoxContainer` with a 56-by-56 icon and wrapping text column. Keep all six descriptions visible without nested cards.

- [ ] **Step 4: Make the journal conditional**

Generate exact sketch state:

```gdscript
var spatial := "0" if entry_ids.has("act00.journal.spatial_datum") else "not yet verified"
var temporal := "+1" if entry_ids.has("act00.journal.temporal_datum") else "not yet verified"
_sketch.text = (
    "EXPERIMENT SKETCH\n\n"
    + "Spatial datum: %s\n" % spatial
    + "Temporal datum: %s\n\n" % temporal
    + "White lever: departure"
)
```

- [ ] **Step 5: Verify and commit**

Run the full suite. Expected: six-item layout and all clue visibility states pass with modal, queue, pause, and keyboard behavior unchanged.

```bash
git add game/ui/inventory_tray.gd game/ui/inventory_tray.tscn game/ui/journal_overlay.gd game/ui/game_hud.gd tests/test_game_hud.gd
git commit -m "feat: expose Act 0 candidates and discovered clues"
```

### Task 5: Six-Candidate Workbench and Feedback Integration

**Files:**
- Modify: `game/workbench/model_workbench.gd`
- Modify: `game/workbench/model_workbench.tscn`
- Modify: `game/act_00/workshop.gd`
- Modify: `tests/test_model_workbench.gd`
- Modify: `tests/test_act_00_playtest_matrix.gd`

**Interfaces:**
- Consumes: six item IDs, exact director placement decisions, and `calibration_feedback_requested`.
- Produces: six-token row, attempts into any unfilled slot, rejected-decoy retention, and concise machine diagnosis.

- [ ] **Step 1: Write failing workbench and path assertions**

Open with all six IDs and assert:

```gdscript
suite.expect_equal(workbench.available_token_count(), 6, "six candidate tokens")
workbench.select_item(&"act00.item.brass_rails")
workbench.request_slot(&"act00.slot.ivory_guides")
suite.expect_equal(requests[-1], [&"act00.item.brass_rails", &"act00.slot.ivory_guides"], "decoy reaches director")
workbench.apply_placement_result(&"act00.item.brass_rails", &"act00.slot.ivory_guides", false)
suite.expect_equal(workbench.placed_count(), 0, "decoy unplaced")
suite.expect_equal(workbench.available_token_count(), 6, "decoy remains available")
```

Update the canonical path to gather all pairs, verify six inventory items, attempt one decoy, assemble exact pairs, misfire at `(0, 0)`, and assert a cadence observation plus `FIELD: CENTRED | RATE: SLOW`.

- [ ] **Step 2: Run and confirm red**

Expected: missing tokens and filtered wrong-slot attempts.

- [ ] **Step 3: Add three token nodes**

Extend `ITEM_LABELS`, `_tokens`, and the scene with `BrassRails`, `SmokedLens`, and `Escapement`. All six buttons use 160-by-54 minimum size, twelve-pixel separation, and exact icon resources.

- [ ] **Step 4: Route every attempt to the director**

Selection focuses the first unfilled slot. Remove expected-item filtering from drag and keyboard request paths. Only a director-accepted pair may enter `_placed`; rejected tokens stay selected and available.

- [ ] **Step 5: Integrate room art, audio, and status**

Hide both relevant candidate visuals after first paired collection and reuse material-appropriate audio. Connect:

```gdscript
_director.calibration_feedback_requested.connect(
    func(_id: StringName, instrument_text: String) -> void:
        _workbench.show_status(instrument_text)
)
```

Remove the generic misfire status overwrite. Continue playing the misfire sound.

- [ ] **Step 6: Verify and commit**

Run import, bounded main/workshop boots, and full tests. Expected: all exit 0; six-token selection, exact assembly, diagnosis, excursion, and handoff pass.

```bash
git add game/workbench/model_workbench.gd game/workbench/model_workbench.tscn game/act_00/workshop.gd tests/test_model_workbench.gd tests/test_act_00_playtest_matrix.gd
git commit -m "feat: integrate the Act 0 reasoning workbench"
```

### Task 6: R2 Capture Matrix and Resistance Paths

**Files:**
- Modify: `tools/capture_qa.gd`
- Modify: `tests/test_qa_capture_contract.gd`
- Modify: `tests/test_act_00_playtest_matrix.gd`
- Modify: `docs/qa/act-00-playtest.md`

**Interfaces:**
- Consumes: complete R2 room, HUD, workbench, and director.
- Produces: deterministic beta-critical captures and end-to-end proof against shortcuts, sequence breaks, and soft locks.

- [ ] **Step 1: Add failing capture labels**

Add these before the existing temporal sequence and assert exact order, uniqueness, and count:

```text
adult_scale_left
dense_focus_centre
inventory_six_candidates
journal_clues_hidden
journal_spatial_only
journal_clues_complete
workbench_six_candidates
misfire_left_fast
misfire_right_slow
```

- [ ] **Step 2: Add resistance assertions**

Prove: each candidate station is idempotent and all three yield exactly six items; assembly requires all three exact pairs; rejected decoys remain available; clues work before or after collection; journal values reveal independently; contrasting misfires preserve `CALIBRATION` and produce contrasting IDs/status; restart clears items, clues, placements, and last diagnosis.

- [ ] **Step 3: Run and confirm red**

Expected: missing labels and incomplete R2 resistance paths.

- [ ] **Step 4: Implement deterministic R2 setup**

Use the three paired actions. Capture the adult player beside a low stool, dense centre focus, all six inventory items, three journal states, all six workbench tokens, and misfires at relations `(-1, +1)` and `(+1, -1)`. Preserve all normal/reduced departure, absence, return, cloth, and closing captures.

- [ ] **Step 5: Verify one viewport and document procedure**

Run the full suite and `scripts/capture-qa.sh` at 1280x720 to a fresh external directory. Expected: exact frame inventory and no flat capture. Update the QA document with the new logical and resistance paths, but do not claim all-viewport results before Task 7.

- [ ] **Step 6: Commit**

```bash
git add tools/capture_qa.gd tests/test_qa_capture_contract.gd tests/test_act_00_playtest_matrix.gd docs/qa/act-00-playtest.md
git commit -m "test: cover the Act 0 R2 beta paths"
```

### Task 7: Final Verification, Review, and Beta Handoff

**Files:**
- Modify: `README.md`
- Modify: `docs/qa/act-00-playtest.md`
- Modify only as evidence requires: files from Tasks 1-6

**Interfaces:**
- Consumes: complete R2 branch and repository verification scripts.
- Produces: reproducible branch, three-viewport evidence, clean archive, independent review, and launched beta build.

- [ ] **Step 1: Run exact full verification**

Run `scripts/verify.sh`.

Expected: toolchain checks; deterministic art/audio/content; imports; bounded boots; capture-boundary regression; all GDScript assertions; generated-surface diff.

- [ ] **Step 2: Capture all viewports outside the repository**

Run `scripts/capture-qa.sh` for 1280x720, 1440x900, and 1920x1080 into one fresh external QA root. Assert equal frame counts and exact dimensions. For 1440x900, require centred 1440x810 content with 45 black rows above and below.

- [ ] **Step 3: Inspect visual evidence**

Build contact sheets and inspect every state. Verify adult scale and feet, prompt stability, inventory grid, journal secrecy/reveal, six-token tray, contrasting diagnostics, normal/reduced excursion, return, cloth, and closing card. Fix and rerun affected evidence for any overlap, truncation, or incoherent focus.

- [ ] **Step 4: Run independent whole-branch review**

Generate a review package from merge base `8ba1c4a` through `HEAD`. Give one independent native reviewer the design, plan, implementation reports, full diff, and verification summary. Ask for Critical/Important defects, puzzle shortcuts, missing tests, or user-facing regressions. Address all Critical/Important findings in one bounded fix wave and rerun covering tests.

- [ ] **Step 5: Verify a clean archive**

Create `git archive HEAD`, extract outside the repository, initialize a temporary Git baseline for generated-surface comparison, and run `scripts/verify.sh`. Require the same passing assertion count and no `.godot`, `.worktrees`, `.DS_Store`, `__pycache__`, or QA payload.

- [ ] **Step 6: Finalize documentation and commit**

Update controls only where behavior changed. Record exact final commands, assertion count, viewport/frame count, review outcome, and residual human checks.

```bash
git add README.md docs/qa/act-00-playtest.md
git commit -m "docs: certify the Act 0 R2 beta build"
```

- [ ] **Step 7: Integrate, push, and launch**

Confirm the main checkout's pre-existing `project.godot` change has not been overwritten. Fast-forward `main` to the verified branch if cleanly possible, push `main`, launch `godot --path .`, and report exact commit, verification evidence, private repository URL, controls, and residual human-only beta checks.
