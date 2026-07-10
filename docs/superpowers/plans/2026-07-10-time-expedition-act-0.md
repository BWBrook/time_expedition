# Time Expedition Act 0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete 8-to-12-minute Godot prologue in which the Time Traveller explores his workshop, assembles and calibrates a model Time Machine, observes its first temporal excursion, and reaches the dinner-bell closing card.

**Architecture:** A single `Main` scene owns the cold open, workshop, and closing card. Immutable custom Resources are loaded through `ContentRegistry`; mutable inventory, journal, and flags live in the `GameSession` autoload; `WorkshopDirector` is the testable story state machine; player, UI, workbench, effects, and audio communicate through semantic signals.

**Tech Stack:** Godot 4.7 stable, GDScript, Godot custom Resources and scenes, a repository-owned headless GDScript test harness, Python standard-library audio generation, ImageGen raster assets, and ImageMagick for deterministic asset normalisation.

## Global Constraints

- Target Godot `4.7.stable.official.5b4e0cb0f`; do not add C#, Mono, or third-party Godot add-ons.
- Build a desktop 2D side-view game at a 1280x720 logical viewport and verify 1280x720, 1440x900, and 1920x1080 windows.
- Use lowercase snake-case paths and stable content IDs in the form `act00.<domain>.<name>`.
- Keep mutable state out of shared Resource instances; only `GameSession` owns mutable story state.
- Keep `docs/` and `source_material/` outside Godot import with `.gdignore` files.
- Do not implement save files, controller support, localisation, voice acting, combat, hazards, branching dialogue, another location, or generic quest/crafting/puzzle engines.
- Use original narrative and visual material based only on Wells' public-domain text; do not reference later adaptation designs.
- Pin the structured literary source to Standard Ebooks commit `9255fefede65b1fd3138d6a802cfd7cde431133c`; use Project Gutenberg eBook 35 as the independent text cross-check.
- Licence code under MIT and original narrative/art under CC BY 4.0; record every generated or third-party asset in provenance documentation.
- Every behavioural task follows red-green TDD and ends with its own commit. Do not bypass a failing test by weakening its assertion.
- The final runtime must not require network access or an AI service.

## File Map

### Project and verification

- `project.godot`: Godot application, viewport, renderer, and autoload configuration.
- `.gitignore`: Godot cache and local build exclusions.
- `scripts/verify.sh`: Final reproducible import, startup, content-build, and test command.
- `tests/test_suite.gd`: Minimal assertion collector used by all tests.
- `tests/run_all.gd`: Headless test entry point with the authoritative test list.

### Runtime state and content

- `game/state/game_session.gd`: Mutable items, journal IDs, flags, and reset signals.
- `game/content/item_definition.gd`: Immutable inventory item Resource.
- `game/content/journal_entry_definition.gd`: Immutable journal Resource.
- `game/content/observation_definition.gd`: Immutable inspection-line Resource.
- `game/content/act_manifest.gd`: Immutable collection of Act 0 content.
- `game/content/content_registry.gd`: Manifest validation and ID lookup.
- `game/content/act_00/act_00_manifest.tres`: Generated and committed narrative content.
- `tools/build_content.gd`: Deterministic source recipe for the manifest.

### Play systems

- `game/act_00/workshop_director.gd`: Act 0 phase machine and puzzle rules.
- `game/shared/interactable.gd`: Reusable focused workshop interaction area.
- `game/player/player_controller.gd`: Horizontal motion, facing, focus selection, and interaction input.
- `game/player/player.tscn`: Player physics and visual scene.
- `game/workbench/component_token.gd`: Mouse-drag and keyboard-selectable component control.
- `game/workbench/component_slot.gd`: Typed drop target and placement signal.
- `game/workbench/model_workbench.gd`: Assembly, calibration controls, and semantic events.
- `game/workbench/model_workbench.tscn`: Full-screen workbench close-up.
- `game/act_00/workshop.gd`: Signal wiring among director, player, HUD, and workbench.
- `game/act_00/workshop.tscn`: Horizontally staged workshop scene.

### Presentation and flow

- `game/ui/observation_band.gd` and `.tscn`: Dismissible inspection prose band.
- `game/ui/inventory_tray.gd` and `.tscn`: Acquired-item tray.
- `game/ui/journal_overlay.gd` and `.tscn`: Two-page observations and experiment sketch.
- `game/ui/pause_overlay.gd` and `.tscn`: Resume, reduced motion, restart, and quit.
- `game/ui/game_hud.gd` and `.tscn`: HUD composition and input routing.
- `game/ui/cold_open.gd` and `.tscn`: Opening location card.
- `game/ui/closing_card.gd` and `.tscn`: Title reveal, restart, and quit.
- `game/main.gd` and `game/main.tscn`: Chapter flow and restart lifecycle.
- `game/effects/temporal_effect.gd` and `.gdshader`: Normal and reduced-motion excursion treatments.
- `game/audio/act_00_audio.gd`: Named audio-event playback.
- `tools/generate_audio.py`: Deterministic original WAV synthesis.
- `assets/audio/act_00/*.wav`: Generated and committed audio.
- `assets/art/act_00/*.png`: Generated and normalised raster art.

### Documentation

- `README.md`: Project, controls, run, test, and licence summary.
- `LICENSE`: MIT code licence.
- `CONTENT_LICENSE.md`: CC BY 4.0 content notice and exclusions.
- `docs/sources.md`: Wells source and edition provenance.
- `assets/art/act_00/ASSET_PROVENANCE.md`: ImageGen prompts, dates, and output mapping.
- `docs/qa/act-00-playtest.md`: Final viewport and playthrough evidence.

---

### Task 1: Godot Project Shell and Headless Test Harness

**Files:**
- Create: `.gitignore`
- Create: `project.godot`
- Create: `docs/.gdignore`
- Create: `source_material/.gdignore`
- Create: `game/main.gd`
- Create: `game/main.tscn`
- Create: `tests/test_suite.gd`
- Create: `tests/test_project_boot.gd`
- Create: `tests/run_all.gd`

**Interfaces:**
- Consumes: Godot 4.7 CLI at `/opt/homebrew/bin/godot`.
- Produces: `TestSuite.expect_true()`, `TestSuite.expect_equal()`, `TestSuite.expect_not_null()`, and a runnable `res://tests/run_all.gd`; later tasks append test scripts to `TEST_SCRIPTS`.

- [ ] **Step 1: Write the test harness and boot test before the project exists**

Create `tests/test_suite.gd`:

```gdscript
class_name TestSuite
extends RefCounted

var assertions := 0
var failures := PackedStringArray()

func expect_true(condition: bool, message: String) -> void:
    assertions += 1
    if not condition:
        failures.append(message)

func expect_equal(actual: Variant, expected: Variant, message: String) -> void:
    assertions += 1
    if actual != expected:
        failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])

func expect_not_null(value: Variant, message: String) -> void:
    expect_true(value != null, message)
```

Create `tests/test_project_boot.gd`:

```gdscript
extends RefCounted

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    suite.expect_equal(
        ProjectSettings.get_setting("application/config/name"),
        "Time Expedition",
        "project name"
    )
    var main_path: String = ProjectSettings.get_setting("application/run/main_scene", "")
    suite.expect_equal(main_path, "res://game/main.tscn", "main scene path")
    var packed := load(main_path) as PackedScene
    suite.expect_not_null(packed, "main scene loads")
    if packed != null:
        var instance := packed.instantiate()
        suite.expect_equal(instance.name, "Main", "main root name")
        instance.free()
```

Create `tests/run_all.gd`:

```gdscript
extends SceneTree

const TEST_SCRIPTS := [
    preload("res://tests/test_project_boot.gd"),
]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var suite := TestSuite.new()
    for test_script in TEST_SCRIPTS:
        var test_case: RefCounted = test_script.new()
        await test_case.run(suite, self)

    if suite.failures.is_empty():
        print("TESTS PASSED: %d assertions" % suite.assertions)
        quit(0)
        return

    for failure in suite.failures:
        push_error("TEST FAILURE: %s" % failure)
    print("TESTS FAILED: %d of %d assertions" % [suite.failures.size(), suite.assertions])
    quit(1)
```

- [ ] **Step 2: Run the boot test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: non-zero exit because `project.godot` and `res://game/main.tscn` do not exist.

- [ ] **Step 3: Add the minimal project and main scene**

Create `.gitignore`:

```gitignore
.DS_Store
.godot/
builds/
*.tmp
```

Create `docs/.gdignore` and `source_material/.gdignore` with this single line:

```text
# Keep non-runtime project material outside Godot import.
```

Create `project.godot`:

```ini
; Engine configuration file.
; Edit through the Godot editor when possible.
config_version=5

[application]

config/name="Time Expedition"
run/main_scene="res://game/main.tscn"
config/features=PackedStringArray("4.7", "GL Compatibility")
boot_splash/bg_color=Color(0.035, 0.043, 0.05, 1)

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/size/window_width_override=1280
window/size/window_height_override=720
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/default_filters/use_nearest_mipmap_filter=false

[audio]

driver/enable_input=false
```

Create `game/main.gd`:

```gdscript
extends Node
```

Create `game/main.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://game/main.gd" id="1_main"]

[node name="Main" type="Node"]
script = ExtResource("1_main")
```

- [ ] **Step 4: Import, boot, and run the green test**

Run:

```bash
godot --headless --path . --import
godot --headless --path . --quit-after 1
godot --headless --path . --script res://tests/run_all.gd
```

Expected: all commands exit 0 and the test runner prints `TESTS PASSED: 4 assertions`.

- [ ] **Step 5: Commit the project shell**

```bash
git add .gitignore project.godot docs/.gdignore source_material/.gdignore game/main.gd game/main.tscn tests
git commit -m "build: scaffold Godot project and test harness"
```

### Task 2: Immutable Content Resources and Registry

**Files:**
- Create: `game/content/item_definition.gd`
- Create: `game/content/journal_entry_definition.gd`
- Create: `game/content/observation_definition.gd`
- Create: `game/content/act_manifest.gd`
- Create: `game/content/content_registry.gd`
- Create: `tools/build_content.gd`
- Create: `game/content/act_00/act_00_manifest.tres` through the builder
- Create: `tests/test_content_registry.gd`
- Modify: `tests/run_all.gd`
- Modify: `project.godot`

**Interfaces:**
- Consumes: `TestSuite` from Task 1.
- Produces: `ItemDefinition`, `JournalEntryDefinition`, `ObservationDefinition`, `ActManifest`, and the autoload API `ContentRegistry.load_manifest()`, `get_item()`, `get_journal_entry()`, `get_observation()`, and `has_entry()`.

- [ ] **Step 1: Write registry tests and register them with the runner**

Create `tests/test_content_registry.gd`:

```gdscript
extends RefCounted

const RegistryScript := preload("res://game/content/content_registry.gd")
const ManifestScript := preload("res://game/content/act_manifest.gd")
const ItemScript := preload("res://game/content/item_definition.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var manifest := load("res://game/content/act_00/act_00_manifest.tres") as ActManifest
    suite.expect_not_null(manifest, "Act 0 manifest loads")

    var registry := RegistryScript.new()
    var errors := registry.load_manifest(manifest)
    suite.expect_equal(errors.size(), 0, "canonical manifest validates")
    suite.expect_equal(registry.item_count(), 3, "three inventory items")
    suite.expect_equal(registry.journal_count(), 5, "five journal entries")
    suite.expect_true(registry.observation_count() >= 16, "authored observations present")
    suite.expect_equal(
        registry.get_item(&"act00.item.crystal_prism").display_name,
        "Crystalline prism",
        "item lookup by stable ID"
    )

    var duplicate_manifest := ManifestScript.new()
    var duplicate_a := ItemScript.new()
    duplicate_a.id = &"act00.item.duplicate"
    var duplicate_b := ItemScript.new()
    duplicate_b.id = &"act00.item.duplicate"
    duplicate_manifest.items = [duplicate_a, duplicate_b]
    var duplicate_errors := registry.load_manifest(duplicate_manifest)
    suite.expect_true(duplicate_errors.size() == 1, "duplicate ID rejected")
    suite.expect_equal(registry.item_count(), 3, "invalid load preserves prior registry")
    registry.free()
```

Replace `TEST_SCRIPTS` in `tests/run_all.gd` with:

```gdscript
const TEST_SCRIPTS := [
    preload("res://tests/test_project_boot.gd"),
    preload("res://tests/test_content_registry.gd"),
]
```

- [ ] **Step 2: Run the content test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: parse/load failure naming `res://game/content/content_registry.gd` or another missing content file.

- [ ] **Step 3: Implement the Resource definitions**

Create `game/content/item_definition.gd`:

```gdscript
class_name ItemDefinition
extends Resource

@export var id: StringName
@export var display_name := ""
@export_multiline var description := ""
@export var icon: Texture2D
```

Create `game/content/journal_entry_definition.gd`:

```gdscript
class_name JournalEntryDefinition
extends Resource

@export var id: StringName
@export var title := ""
@export_multiline var body := ""
```

Create `game/content/observation_definition.gd`:

```gdscript
class_name ObservationDefinition
extends Resource

@export var id: StringName
@export_multiline var text := ""
```

Create `game/content/act_manifest.gd`:

```gdscript
class_name ActManifest
extends Resource

@export var act_id: StringName
@export var title := ""
@export var items: Array[ItemDefinition] = []
@export var journal_entries: Array[JournalEntryDefinition] = []
@export var observations: Array[ObservationDefinition] = []
```

- [ ] **Step 4: Add the deterministic content builder**

Create `tools/build_content.gd`:

```gdscript
extends SceneTree

const OUTPUT := "res://game/content/act_00/act_00_manifest.tres"

func _initialize() -> void:
    var manifest := ActManifest.new()
    manifest.act_id = &"act00"
    manifest.title = "Act 0: The Model"
    manifest.items = [
        _item(
            &"act00.item.ivory_guides",
            "Ivory guide bars",
            "Twin ivory guides, worked to an accuracy the eye can barely judge."
        ),
        _item(
            &"act00.item.crystal_prism",
            "Crystalline prism",
            "A transparent prism cut for the model's temporal axis."
        ),
        _item(
            &"act00.item.control_levers",
            "Paired control levers",
            "The white departure lever and its darker companion on one delicate yoke."
        ),
    ]
    manifest.journal_entries = [
        _journal(
            &"act00.journal.experiment",
            "The model",
            "The frame is complete, but the ivory guides, crystalline prism, and paired levers remain to be fitted. I shall test it once before I submit the thing to witnesses."
        ),
        _journal(
            &"act00.journal.components",
            "Materials assembled",
            "All three pieces are at hand. Their fittings are unlike enough that haste ought not defeat reason."
        ),
        _journal(
            &"act00.journal.calibration",
            "Calibration",
            "Spatial axes at equilibrium. Temporal bias one division forward. Only then may the departure lever describe a complete excursion."
        ),
        _journal(
            &"act00.journal.misfire",
            "An incomplete displacement",
            "The frame shuddered but did not depart. The mechanism is sound; the fault lies in my calibration."
        ),
        _journal(
            &"act00.journal.success",
            "Eleven seconds",
            "Four seconds passed in the workshop. The model's chronometer advanced fifteen. An error of measurement remains possible, but an error with a very particular direction."
        ),
    ]
    manifest.observations = [
        _observation(&"act00.observation.notebook", "The ink is scarcely dry. Three pieces remain, and the calibration note is underlined twice."),
        _observation(&"act00.observation.take_guides", "The ivory guides are cool and absurdly light. They belong on the model."),
        _observation(&"act00.observation.guides_taken", "Only their fitted impressions remain in the velvet."),
        _observation(&"act00.observation.take_prism", "The prism divides the lamplight into a narrow spectral edge."),
        _observation(&"act00.observation.prism_taken", "The optical stand is empty."),
        _observation(&"act00.observation.take_levers", "The paired levers survived the discarded mechanism. Waste is merely invention awaiting better judgement."),
        _observation(&"act00.observation.levers_taken", "The rejected frames can offer nothing further tonight."),
        _observation(&"act00.observation.bench_missing", "The frame is ready, but its three empty fittings make success impossible."),
        _observation(&"act00.observation.bench_ready", "Everything required is here. Now accuracy must do what theory has promised."),
        _observation(&"act00.observation.wrong_slot", "No. The fitting refuses it without force, which is more wisdom than many men display."),
        _observation(&"act00.observation.component_fitted", "It seats cleanly. One uncertainty removed."),
        _observation(&"act00.observation.assembly_complete", "The model is whole. Spatial equilibrium; temporal bias one division forward."),
        _observation(&"act00.observation.misfire", "A displacement began and collapsed. The calibration, not the construction, is at fault."),
        _observation(&"act00.observation.excursion", "For four seconds the bench is indisputably empty."),
        _observation(&"act00.observation.return", "The chronometer reads fifteen seconds. The workshop clock has advanced four."),
        _observation(&"act00.observation.clock", "The house clock is less forgiving than any scientific instrument. My guests will soon arrive."),
        _observation(&"act00.observation.window", "Rain stipples the Richmond glass. Beyond it, ordinary time proceeds with complete confidence."),
        _observation(&"act00.observation.apparatus", "A respectable collection of failures, each one useful enough to deserve dusting."),
    ]

    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.get_base_dir()))
    var error := ResourceSaver.save(manifest, OUTPUT)
    if error != OK:
        push_error("Unable to save %s: error %d" % [OUTPUT, error])
        quit(1)
        return
    print("WROTE %s" % OUTPUT)
    quit(0)

func _item(id: StringName, display_name: String, description: String) -> ItemDefinition:
    var value := ItemDefinition.new()
    value.id = id
    value.display_name = display_name
    value.description = description
    return value

func _journal(id: StringName, title: String, body: String) -> JournalEntryDefinition:
    var value := JournalEntryDefinition.new()
    value.id = id
    value.title = title
    value.body = body
    return value

func _observation(id: StringName, text: String) -> ObservationDefinition:
    var value := ObservationDefinition.new()
    value.id = id
    value.text = text
    return value
```

Run:

```bash
godot --headless --path . --script res://tools/build_content.gd
```

Expected: exit 0 and `WROTE res://game/content/act_00/act_00_manifest.tres`.

- [ ] **Step 5: Implement registry validation and lookup**

Create `game/content/content_registry.gd`:

```gdscript
extends Node

const DEFAULT_MANIFEST := preload("res://game/content/act_00/act_00_manifest.tres")

var _items := {}
var _journal_entries := {}
var _observations := {}

func _ready() -> void:
    var errors := load_manifest(DEFAULT_MANIFEST)
    for message in errors:
        push_error(message)

func load_manifest(manifest: ActManifest) -> PackedStringArray:
    var errors := _validate_manifest(manifest)
    if not errors.is_empty():
        return errors

    var next_items := {}
    var next_journal := {}
    var next_observations := {}
    for item in manifest.items:
        next_items[item.id] = item
    for entry in manifest.journal_entries:
        next_journal[entry.id] = entry
    for observation in manifest.observations:
        next_observations[observation.id] = observation
    _items = next_items
    _journal_entries = next_journal
    _observations = next_observations
    return PackedStringArray()

func _validate_manifest(manifest: ActManifest) -> PackedStringArray:
    var errors := PackedStringArray()
    if manifest == null:
        errors.append("Content manifest is null")
        return errors

    var seen := {}
    for collection in [manifest.items, manifest.journal_entries, manifest.observations]:
        for entry in collection:
            if entry == null:
                errors.append("Content manifest contains a null entry")
                continue
            if entry.id == StringName():
                errors.append("Content entry has an empty ID")
                continue
            if seen.has(entry.id):
                errors.append("Duplicate content ID: %s" % entry.id)
                continue
            seen[entry.id] = true
    return errors

func get_item(id: StringName) -> ItemDefinition:
    return _items.get(id) as ItemDefinition

func get_journal_entry(id: StringName) -> JournalEntryDefinition:
    return _journal_entries.get(id) as JournalEntryDefinition

func get_observation(id: StringName) -> ObservationDefinition:
    return _observations.get(id) as ObservationDefinition

func has_entry(id: StringName) -> bool:
    return _items.has(id) or _journal_entries.has(id) or _observations.has(id)

func item_count() -> int:
    return _items.size()

func journal_count() -> int:
    return _journal_entries.size()

func observation_count() -> int:
    return _observations.size()
```

Add this section to `project.godot` before `[display]`:

```ini
[autoload]

ContentRegistry="*res://game/content/content_registry.gd"
```

- [ ] **Step 6: Run the complete suite and confirm the green state**

Run:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_all.gd
```

Expected: exit 0, no content validation errors, and `TESTS PASSED: 12 assertions`.

- [ ] **Step 7: Commit the content model**

```bash
git add project.godot game/content tools/build_content.gd tests/test_content_registry.gd tests/run_all.gd
git commit -m "feat: add validated Act 0 content registry"
```

### Task 3: Mutable Game Session

**Files:**
- Create: `game/state/game_session.gd`
- Create: `tests/test_game_session.gd`
- Modify: `tests/run_all.gd`
- Modify: `project.godot`

**Interfaces:**
- Consumes: Stable content IDs from Task 2.
- Produces: the `GameSession` autoload API `reset()`, `acquire_item()`, `has_item()`, `add_journal_entry()`, `has_journal_entry()`, `set_flag()`, `get_flag()`, `item_ids()`, and `journal_entry_ids()` plus change signals.

- [ ] **Step 1: Write session idempotency and reset tests**

Create `tests/test_game_session.gd`:

```gdscript
extends RefCounted

const SessionScript := preload("res://game/state/game_session.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var session := SessionScript.new()
    var acquired: Array[String] = []
    var journal_added: Array[String] = []
    var flag_events: Array[String] = []
    var reset_count: Array[int] = [0]
    session.item_acquired.connect(func(id: StringName) -> void: acquired.append(String(id)))
    session.journal_added.connect(func(id: StringName) -> void: journal_added.append(String(id)))
    session.flag_changed.connect(
        func(id: StringName, enabled: bool) -> void:
            flag_events.append("%s=%s" % [id, enabled])
    )
    session.reset_completed.connect(func() -> void: reset_count[0] += 1)

    suite.expect_true(session.acquire_item(&"act00.item.ivory_guides"), "first item acquisition")
    suite.expect_true(not session.acquire_item(&"act00.item.ivory_guides"), "duplicate item ignored")
    suite.expect_true(session.has_item(&"act00.item.ivory_guides"), "item membership")
    suite.expect_equal(acquired.size(), 1, "item signal emitted once")

    suite.expect_true(session.add_journal_entry(&"act00.journal.experiment"), "first journal entry")
    suite.expect_true(not session.add_journal_entry(&"act00.journal.experiment"), "duplicate journal ignored")
    suite.expect_true(session.has_journal_entry(&"act00.journal.experiment"), "journal membership")
    suite.expect_equal(journal_added.size(), 1, "journal signal emitted once")

    suite.expect_true(session.set_flag(&"act00.flag.test", true), "flag changes")
    suite.expect_true(not session.set_flag(&"act00.flag.test", true), "same flag value ignored")
    suite.expect_true(session.get_flag(&"act00.flag.test"), "flag lookup")
    suite.expect_equal(flag_events.size(), 1, "flag signal emitted once")
    suite.expect_equal(session.item_ids(), PackedStringArray(["act00.item.ivory_guides"]), "stable item snapshot")
    suite.expect_equal(session.journal_entry_ids(), PackedStringArray(["act00.journal.experiment"]), "stable journal snapshot")

    session.reset()
    suite.expect_true(not session.has_item(&"act00.item.ivory_guides"), "reset clears items")
    suite.expect_true(not session.has_journal_entry(&"act00.journal.experiment"), "reset clears journal")
    suite.expect_true(not session.get_flag(&"act00.flag.test"), "reset clears flags")
    suite.expect_equal(reset_count[0], 1, "reset signal emitted")
    session.free()
```

Append this preload to `TEST_SCRIPTS` in `tests/run_all.gd`:

```gdscript
    preload("res://tests/test_game_session.gd"),
```

- [ ] **Step 2: Run the session test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: parse/load failure naming missing `res://game/state/game_session.gd`.

- [ ] **Step 3: Implement session state and signals**

Create `game/state/game_session.gd`:

```gdscript
extends Node

signal item_acquired(id: StringName)
signal journal_added(id: StringName)
signal flag_changed(id: StringName, enabled: bool)
signal reset_completed

var _items := {}
var _journal_entries := {}
var _flags := {}

func reset() -> void:
    _items.clear()
    _journal_entries.clear()
    _flags.clear()
    reset_completed.emit()

func acquire_item(id: StringName) -> bool:
    if id == StringName() or _items.has(id):
        return false
    _items[id] = true
    item_acquired.emit(id)
    return true

func has_item(id: StringName) -> bool:
    return _items.has(id)

func item_ids() -> PackedStringArray:
    var ids := PackedStringArray()
    for id in _items:
        ids.append(String(id))
    ids.sort()
    return ids

func add_journal_entry(id: StringName) -> bool:
    if id == StringName() or _journal_entries.has(id):
        return false
    _journal_entries[id] = true
    journal_added.emit(id)
    return true

func has_journal_entry(id: StringName) -> bool:
    return _journal_entries.has(id)

func journal_entry_ids() -> PackedStringArray:
    var ids := PackedStringArray()
    for id in _journal_entries:
        ids.append(String(id))
    ids.sort()
    return ids

func set_flag(id: StringName, enabled: bool) -> bool:
    if id == StringName() or get_flag(id) == enabled:
        return false
    if enabled:
        _flags[id] = true
    else:
        _flags.erase(id)
    flag_changed.emit(id, enabled)
    return true

func get_flag(id: StringName) -> bool:
    return bool(_flags.get(id, false))
```

Add `GameSession` beneath `ContentRegistry` in the `[autoload]` section of `project.godot`:

```ini
GameSession="*res://game/state/game_session.gd"
```

- [ ] **Step 4: Run the session tests and confirm the green state**

Run:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_all.gd
```

Expected: exit 0 and the runner prints `TESTS PASSED:` with no duplicate-state failures.

- [ ] **Step 5: Commit session state**

```bash
git add project.godot game/state/game_session.gd tests/test_game_session.gd tests/run_all.gd
git commit -m "feat: add idempotent game session state"
```

### Task 4: Workshop Story State Machine

**Files:**
- Create: `game/act_00/workshop_director.gd`
- Create: `tests/test_workshop_director.gd`
- Modify: `tests/run_all.gd`

**Interfaces:**
- Consumes: the `GameSession` methods from Task 3 and stable IDs from Task 2.
- Produces: `WorkshopDirector.Phase`, `initialize()`, `handle_action()`, `request_place_component()`, `update_calibration()`, `pull_lever()`, `complete_excursion()`, state getters, and semantic signals consumed by the workshop and workbench.

- [ ] **Step 1: Write the complete happy-path and out-of-order state tests**

Create `tests/test_workshop_director.gd`:

```gdscript
extends RefCounted

const SessionScript := preload("res://game/state/game_session.gd")
const DirectorScript := preload("res://game/act_00/workshop_director.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var session := SessionScript.new()
    var director := DirectorScript.new()
    var observations: Array[String] = []
    var workbench_requests: Array[int] = [0]
    var excursion_requests: Array[int] = [0]
    var completion_requests: Array[int] = [0]
    director.observation_requested.connect(
        func(id: StringName) -> void: observations.append(String(id))
    )
    director.workbench_requested.connect(func() -> void: workbench_requests[0] += 1)
    director.excursion_requested.connect(func() -> void: excursion_requests[0] += 1)
    director.chapter_completed.connect(func() -> void: completion_requests[0] += 1)
    director.initialize(session)

    suite.expect_equal(director.phase, DirectorScript.Phase.DISCOVERY, "initial phase")
    director.handle_action(&"act00.action.bench")
    suite.expect_equal(director.phase, DirectorScript.Phase.ASSEMBLY, "bench opens assembly phase")
    suite.expect_equal(workbench_requests[0], 1, "workbench requested")
    suite.expect_equal(observations[-1], "act00.observation.bench_missing", "missing-parts feedback")

    director.handle_action(&"act00.action.notebook")
    suite.expect_true(session.has_journal_entry(&"act00.journal.experiment"), "notebook adds experiment journal")
    director.handle_action(&"act00.action.collect_guides")
    director.handle_action(&"act00.action.collect_guides")
    director.handle_action(&"act00.action.collect_prism")
    director.handle_action(&"act00.action.collect_levers")
    suite.expect_equal(session.item_ids().size(), 3, "all components acquired once")
    suite.expect_true(session.has_journal_entry(&"act00.journal.components"), "components journal added")
    suite.expect_equal(observations[-1], "act00.observation.take_levers", "latest collection feedback")

    suite.expect_true(
        not director.request_place_component(
            &"act00.item.crystal_prism",
            &"act00.slot.ivory_guides"
        ),
        "wrong slot rejected"
    )
    suite.expect_equal(observations[-1], "act00.observation.wrong_slot", "wrong-slot observation")
    suite.expect_true(
        director.request_place_component(
            &"act00.item.ivory_guides",
            &"act00.slot.ivory_guides"
        ),
        "ivory guides placed"
    )
    suite.expect_true(
        director.request_place_component(
            &"act00.item.ivory_guides",
            &"act00.slot.ivory_guides"
        ),
        "same placement is idempotent"
    )
    suite.expect_true(
        director.request_place_component(
            &"act00.item.crystal_prism",
            &"act00.slot.crystal_prism"
        ),
        "prism placed"
    )
    suite.expect_true(
        director.request_place_component(
            &"act00.item.control_levers",
            &"act00.slot.control_levers"
        ),
        "levers placed"
    )
    suite.expect_equal(director.phase, DirectorScript.Phase.CALIBRATION, "assembly unlocks calibration")
    suite.expect_true(session.has_journal_entry(&"act00.journal.calibration"), "calibration clue recorded")

    director.update_calibration(1, 0)
    suite.expect_true(not director.pull_lever(), "incorrect calibration misfires")
    suite.expect_true(session.has_journal_entry(&"act00.journal.misfire"), "misfire recorded")
    suite.expect_equal(excursion_requests[0], 0, "misfire does not start excursion")

    director.update_calibration(0, 1)
    suite.expect_true(director.pull_lever(), "correct calibration starts excursion")
    suite.expect_equal(director.phase, DirectorScript.Phase.EXCURSION, "excursion phase")
    suite.expect_equal(excursion_requests[0], 1, "excursion requested once")
    suite.expect_true(not director.pull_lever(), "lever ignored during excursion")

    suite.expect_true(director.complete_excursion(), "excursion completes")
    suite.expect_equal(director.phase, DirectorScript.Phase.COMPLETE, "complete phase")
    suite.expect_true(session.has_journal_entry(&"act00.journal.success"), "success journal recorded")
    suite.expect_equal(observations[-1], "act00.observation.return", "return observation")
    suite.expect_equal(completion_requests[0], 1, "chapter completion emitted once")
    suite.expect_true(not director.complete_excursion(), "completion is idempotent")
    director.free()
    session.free()
```

Append this preload to `TEST_SCRIPTS` in `tests/run_all.gd`:

```gdscript
    preload("res://tests/test_workshop_director.gd"),
```

- [ ] **Step 2: Run the director test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: parse/load failure naming missing `res://game/act_00/workshop_director.gd`.

- [ ] **Step 3: Implement the phase machine and semantic actions**

Create `game/act_00/workshop_director.gd`:

```gdscript
class_name WorkshopDirector
extends Node

signal observation_requested(id: StringName)
signal phase_changed(next_phase: Phase)
signal workbench_requested
signal excursion_requested
signal chapter_completed

enum Phase {
    DISCOVERY,
    ASSEMBLY,
    CALIBRATION,
    EXCURSION,
    COMPLETE,
}

const REQUIRED_SLOTS := {
    &"act00.slot.ivory_guides": &"act00.item.ivory_guides",
    &"act00.slot.crystal_prism": &"act00.item.crystal_prism",
    &"act00.slot.control_levers": &"act00.item.control_levers",
}

const COLLECTIONS := {
    &"act00.action.collect_guides": [
        &"act00.item.ivory_guides",
        &"act00.observation.take_guides",
        &"act00.observation.guides_taken",
    ],
    &"act00.action.collect_prism": [
        &"act00.item.crystal_prism",
        &"act00.observation.take_prism",
        &"act00.observation.prism_taken",
    ],
    &"act00.action.collect_levers": [
        &"act00.item.control_levers",
        &"act00.observation.take_levers",
        &"act00.observation.levers_taken",
    ],
}

var phase := Phase.DISCOVERY
var spatial_alignment := 0
var temporal_bias := 0
var _session: Node
var _placed_slots := {}

func initialize(session: Node) -> void:
    _session = session
    phase = Phase.DISCOVERY
    spatial_alignment = 0
    temporal_bias = 0
    _placed_slots.clear()

func handle_action(action_id: StringName) -> void:
    if COLLECTIONS.has(action_id):
        var values: Array = COLLECTIONS[action_id]
        _collect_item(values[0], values[1], values[2])
        return

    match action_id:
        &"act00.action.notebook":
            _session.add_journal_entry(&"act00.journal.experiment")
            observation_requested.emit(&"act00.observation.notebook")
        &"act00.action.bench":
            if phase == Phase.DISCOVERY:
                _set_phase(Phase.ASSEMBLY)
            observation_requested.emit(
                &"act00.observation.bench_ready"
                if _all_items_acquired()
                else &"act00.observation.bench_missing"
            )
            workbench_requested.emit()
        &"act00.action.clock":
            observation_requested.emit(&"act00.observation.clock")
        &"act00.action.window":
            observation_requested.emit(&"act00.observation.window")
        &"act00.action.apparatus":
            observation_requested.emit(&"act00.observation.apparatus")

func request_place_component(item_id: StringName, slot_id: StringName) -> bool:
    if _placed_slots.get(slot_id) == item_id:
        return true
    if REQUIRED_SLOTS.get(slot_id) != item_id or not _session.has_item(item_id):
        observation_requested.emit(&"act00.observation.wrong_slot")
        return false
    if _placed_slots.values().has(item_id):
        observation_requested.emit(&"act00.observation.wrong_slot")
        return false

    _placed_slots[slot_id] = item_id
    _session.set_flag(StringName("act00.flag.placed.%s" % String(slot_id).get_slice(".", 2)), true)
    observation_requested.emit(&"act00.observation.component_fitted")
    if _placed_slots.size() == REQUIRED_SLOTS.size():
        _session.add_journal_entry(&"act00.journal.calibration")
        observation_requested.emit(&"act00.observation.assembly_complete")
        _set_phase(Phase.CALIBRATION)
    return true

func update_calibration(next_spatial_alignment: int, next_temporal_bias: int) -> void:
    spatial_alignment = clampi(next_spatial_alignment, -2, 2)
    temporal_bias = clampi(next_temporal_bias, -2, 2)

func pull_lever() -> bool:
    if phase == Phase.EXCURSION or phase == Phase.COMPLETE:
        return false
    if _placed_slots.size() != REQUIRED_SLOTS.size():
        observation_requested.emit(&"act00.observation.bench_missing")
        return false
    if spatial_alignment != 0 or temporal_bias != 1:
        _session.add_journal_entry(&"act00.journal.misfire")
        observation_requested.emit(&"act00.observation.misfire")
        return false

    observation_requested.emit(&"act00.observation.excursion")
    _set_phase(Phase.EXCURSION)
    excursion_requested.emit()
    return true

func complete_excursion() -> bool:
    if phase != Phase.EXCURSION:
        return false
    _session.add_journal_entry(&"act00.journal.success")
    observation_requested.emit(&"act00.observation.return")
    _set_phase(Phase.COMPLETE)
    chapter_completed.emit()
    return true

func placed_slots() -> Dictionary:
    return _placed_slots.duplicate()

func all_items_acquired() -> bool:
    return _all_items_acquired()

func _collect_item(
    item_id: StringName,
    acquired_observation: StringName,
    repeated_observation: StringName
) -> void:
    if _session.acquire_item(item_id):
        observation_requested.emit(acquired_observation)
        if _all_items_acquired():
            _session.add_journal_entry(&"act00.journal.components")
        return
    observation_requested.emit(repeated_observation)

func _all_items_acquired() -> bool:
    for item_id in REQUIRED_SLOTS.values():
        if not _session.has_item(item_id):
            return false
    return true

func _set_phase(next_phase: Phase) -> void:
    if phase == next_phase:
        return
    phase = next_phase
    phase_changed.emit(phase)
```

- [ ] **Step 4: Run the complete suite and confirm the green state**

Run:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_all.gd
```

Expected: exit 0; all collection, wrong-slot, calibration, excursion, completion, and idempotency assertions pass.

- [ ] **Step 5: Commit the story state machine**

```bash
git add game/act_00/workshop_director.gd tests/test_workshop_director.gd tests/run_all.gd
git commit -m "feat: add Act 0 workshop state machine"
```

### Task 5: Player Movement and Focused Interactions

**Files:**
- Create: `game/shared/interactable.gd`
- Create: `game/player/player_controller.gd`
- Create: `game/player/player.tscn`
- Create: `tests/test_focus_selection.gd`
- Modify: `tests/run_all.gd`

**Interfaces:**
- Consumes: semantic action IDs accepted by `WorkshopDirector.handle_action()`.
- Produces: `Interactable.prompt_text()`, `set_focused()`, and `trigger()`; `PlayerController.choose_focus()`, `set_input_enabled()`, `interaction_requested(action_id)`, and `focus_prompt_changed(text, visible)`.

- [ ] **Step 1: Write deterministic focus-selection and interaction tests**

Create `tests/test_focus_selection.gd`:

```gdscript
extends RefCounted

const InteractableScript := preload("res://game/shared/interactable.gd")
const PlayerScript := preload("res://game/player/player_controller.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var player := PlayerScript.new()
    player.position = Vector2.ZERO
    player.facing = 1

    var near_left := InteractableScript.new()
    near_left.position = Vector2(-20, 0)
    near_left.action_id = &"act00.action.left"
    near_left.prompt_verb = "Inspect"
    near_left.prompt_name = "left object"

    var forward := InteractableScript.new()
    forward.position = Vector2(90, 0)
    forward.action_id = &"act00.action.forward"
    forward.prompt_verb = "Open"
    forward.prompt_name = "drawer"

    var high_priority := InteractableScript.new()
    high_priority.position = Vector2(100, 0)
    high_priority.action_id = &"act00.action.priority"
    high_priority.focus_priority = 2

    suite.expect_equal(
        player.choose_focus([near_left, forward]),
        forward,
        "facing preference beats nearby object behind player"
    )
    suite.expect_equal(
        player.choose_focus([forward, high_priority]),
        high_priority,
        "focus priority breaks nearby competition"
    )
    player.facing = -1
    suite.expect_equal(player.choose_focus([near_left, forward]), near_left, "left-facing selection")
    suite.expect_equal(forward.prompt_text(), "Open drawer", "prompt composition")

    var trigger_count: Array[int] = [0]
    forward.interacted.connect(func(_id: StringName) -> void: trigger_count[0] += 1)
    forward.trigger()
    suite.expect_equal(trigger_count[0], 1, "interactable emits semantic action")

    near_left.free()
    forward.free()
    high_priority.free()
    player.free()
```

Append this preload to `TEST_SCRIPTS` in `tests/run_all.gd`:

```gdscript
    preload("res://tests/test_focus_selection.gd"),
```

- [ ] **Step 2: Run the focus test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: parse/load failure naming missing `res://game/shared/interactable.gd` or `player_controller.gd`.

- [ ] **Step 3: Implement the reusable interaction area**

Create `game/shared/interactable.gd`:

```gdscript
class_name Interactable
extends Area2D

signal interacted(action_id: StringName)

@export var action_id: StringName
@export var prompt_verb := "Inspect"
@export var prompt_name := "object"
@export var focus_priority := 0

var _focused := false

func prompt_text() -> String:
    return "%s %s" % [prompt_verb, prompt_name]

func set_focused(value: bool) -> void:
    if _focused == value:
        return
    _focused = value
    var visual := get_node_or_null("FocusVisual") as CanvasItem
    if visual != null:
        visual.visible = value

func is_focused() -> bool:
    return _focused

func trigger() -> void:
    interacted.emit(action_id)
```

- [ ] **Step 4: Implement horizontal movement, facing, focus, and input**

Create `game/player/player_controller.gd`:

```gdscript
class_name PlayerController
extends CharacterBody2D

signal interaction_requested(action_id: StringName)
signal focus_prompt_changed(text: String, visible: bool)

@export var speed := 240.0
var facing := 1
var _input_enabled := true
var _focused: Interactable
@onready var _interaction_range: Area2D = $InteractionRange
@onready var _visual: Node2D = $Visual

func _physics_process(_delta: float) -> void:
    if not _input_enabled:
        velocity = Vector2.ZERO
        return

    var direction := Input.get_axis("ui_left", "ui_right")
    if Input.is_key_pressed(KEY_A):
        direction -= 1.0
    if Input.is_key_pressed(KEY_D):
        direction += 1.0
    direction = clampf(direction, -1.0, 1.0)
    if not is_zero_approx(direction):
        facing = 1 if direction > 0.0 else -1
        _visual.scale.x = absf(_visual.scale.x) * facing
    velocity = Vector2(direction * speed, 0.0)
    move_and_slide()
    _refresh_focus()

func _unhandled_input(event: InputEvent) -> void:
    if not _input_enabled or _focused == null:
        return
    var key_event := event as InputEventKey
    var e_pressed := (
        key_event != null
        and key_event.pressed
        and not key_event.echo
        and key_event.keycode == KEY_E
    )
    if e_pressed or event.is_action_pressed("ui_accept"):
        _focused.trigger()
        interaction_requested.emit(_focused.action_id)
        get_viewport().set_input_as_handled()

func choose_focus(candidates: Array) -> Interactable:
    var best: Interactable
    var best_score := INF
    for candidate_value in candidates:
        var candidate := candidate_value as Interactable
        if candidate == null:
            continue
        var offset := candidate.global_position - global_position
        var behind := not is_zero_approx(offset.x) and signf(offset.x) != float(facing)
        var score := absf(offset.x) + absf(offset.y) * 2.0
        if behind:
            score += 500.0
        score -= float(candidate.focus_priority) * 20.0
        if score < best_score:
            best = candidate
            best_score = score
    return best

func set_input_enabled(enabled: bool) -> void:
    _input_enabled = enabled
    if not enabled:
        velocity = Vector2.ZERO
        _set_focus(null)

func input_enabled() -> bool:
    return _input_enabled

func _refresh_focus() -> void:
    _set_focus(choose_focus(_interaction_range.get_overlapping_areas()))

func _set_focus(next_focus: Interactable) -> void:
    if _focused == next_focus:
        return
    if _focused != null:
        _focused.set_focused(false)
    _focused = next_focus
    if _focused == null:
        focus_prompt_changed.emit("", false)
        return
    _focused.set_focused(true)
    focus_prompt_changed.emit(_focused.prompt_text(), true)
```

Create `game/player/player.tscn`:

```ini
[gd_scene load_steps=4 format=3]

[ext_resource type="Script" path="res://game/player/player_controller.gd" id="1_player"]

[sub_resource type="CapsuleShape2D" id="Capsule_player"]
radius = 18.0
height = 92.0

[sub_resource type="RectangleShape2D" id="Range_shape"]
size = Vector2(220, 150)

[node name="Player" type="CharacterBody2D"]
collision_layer = 1
collision_mask = 1
script = ExtResource("1_player")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, -46)
shape = SubResource("Capsule_player")

[node name="Visual" type="Node2D" parent="."]

[node name="Body" type="Polygon2D" parent="Visual"]
position = Vector2(0, -46)
polygon = PackedVector2Array(-16, -44, 14, -44, 22, 34, 12, 48, -14, 48, -22, 34)
color = Color(0.16, 0.2, 0.21, 1)

[node name="Head" type="Polygon2D" parent="Visual"]
position = Vector2(0, -102)
polygon = PackedVector2Array(-13, -15, 11, -15, 16, 4, 6, 18, -10, 16, -17, 2)
color = Color(0.23, 0.25, 0.24, 1)

[node name="InteractionRange" type="Area2D" parent="."]
position = Vector2(0, -55)
collision_layer = 0
collision_mask = 2
monitoring = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="InteractionRange"]
shape = SubResource("Range_shape")
```

- [ ] **Step 5: Run focus tests and instantiate the player scene**

Run:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_all.gd
godot --headless --path . --quit-after 1
```

Expected: exit 0; focus direction, priority, prompt, and trigger tests pass; the player scene parses without warnings.

- [ ] **Step 6: Commit player interaction**

```bash
git add game/shared/interactable.gd game/player tests/test_focus_selection.gd tests/run_all.gd
git commit -m "feat: add player movement and focused interactions"
```

### Task 6: HUD, Inventory, Journal, and Pause Surfaces

**Files:**
- Create: `game/ui/observation_band.gd`
- Create: `game/ui/observation_band.tscn`
- Create: `game/ui/inventory_tray.gd`
- Create: `game/ui/inventory_tray.tscn`
- Create: `game/ui/journal_overlay.gd`
- Create: `game/ui/journal_overlay.tscn`
- Create: `game/ui/pause_overlay.gd`
- Create: `game/ui/pause_overlay.tscn`
- Create: `game/ui/game_hud.gd`
- Create: `game/ui/game_hud.tscn`
- Create: `tests/test_game_hud.gd`
- Modify: `tests/run_all.gd`

**Interfaces:**
- Consumes: `GameSession.item_ids()`, `journal_entry_ids()`, and `ContentRegistry` lookup methods.
- Produces: `GameHUD.bind()`, `show_observation()`, `set_focus_prompt()`, `open_inventory()`, `open_journal()`, `set_external_modal_open()`, `set_reduced_motion()`, `reduced_motion_enabled()`, and `restart_requested`, `quit_requested`, `external_modal_close_requested`, and `pause_changed` signals.

- [ ] **Step 1: Write HUD binding and content-presentation tests**

Create `tests/test_game_hud.gd`:

```gdscript
extends RefCounted

const HudScene := preload("res://game/ui/game_hud.tscn")
const RegistryScript := preload("res://game/content/content_registry.gd")
const SessionScript := preload("res://game/state/game_session.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    var registry := RegistryScript.new()
    registry.load_manifest(load("res://game/content/act_00/act_00_manifest.tres"))
    var session := SessionScript.new()
    var hud := HudScene.instantiate()
    tree.root.add_child(hud)
    await tree.process_frame
    hud.bind(session, registry)

    hud.show_observation(&"act00.observation.notebook")
    suite.expect_true(hud.observation_visible(), "observation band opens")
    suite.expect_true(hud.observation_text().contains("ink is scarcely dry"), "observation text resolves")

    session.acquire_item(&"act00.item.crystal_prism")
    hud.open_inventory()
    suite.expect_true(hud.inventory_visible(), "inventory opens")
    suite.expect_equal(hud.displayed_item_count(), 1, "one acquired item displayed")

    session.add_journal_entry(&"act00.journal.experiment")
    hud.open_journal()
    suite.expect_true(hud.journal_visible(), "journal opens")
    suite.expect_equal(hud.displayed_journal_count(), 1, "one journal entry displayed")

    hud.set_focus_prompt("Inspect notebook", true)
    suite.expect_equal(hud.focus_prompt_text(), "Inspect notebook", "focus prompt text")
    hud.set_reduced_motion(true)
    suite.expect_true(hud.reduced_motion_enabled(), "reduced motion state")

    tree.root.remove_child(hud)
    hud.free()
    registry.free()
    session.free()
```

Append this preload to `TEST_SCRIPTS` in `tests/run_all.gd`:

```gdscript
    preload("res://tests/test_game_hud.gd"),
```

- [ ] **Step 2: Run the HUD test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: parse/load failure naming missing `res://game/ui/game_hud.tscn`.

- [ ] **Step 3: Implement the four focused UI components**

Create `game/ui/observation_band.gd`:

```gdscript
class_name ObservationBand
extends PanelContainer

signal dismissed

@onready var _label: Label = $Margin/Rows/Text

func _ready() -> void:
    $Margin/Rows/Continue.pressed.connect(dismiss)

func show_text(text: String) -> void:
    _label.text = text
    visible = true
    $Margin/Rows/Continue.grab_focus()

func dismiss() -> void:
    if not visible:
        return
    visible = false
    dismissed.emit()

func text_value() -> String:
    return _label.text

func _unhandled_input(event: InputEvent) -> void:
    var key_event := event as InputEventKey
    if not visible or key_event == null or not key_event.pressed or key_event.echo:
        return
    if key_event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER]:
        dismiss()
        get_viewport().set_input_as_handled()
```

Create `game/ui/inventory_tray.gd`:

```gdscript
class_name InventoryTray
extends PanelContainer

signal closed

var _displayed_count := 0
@onready var _items: HBoxContainer = $Margin/Rows/Items

func _ready() -> void:
    $Margin/Rows/Header/Close.pressed.connect(close)

func populate(item_ids: PackedStringArray, registry: Node) -> void:
    for child in _items.get_children():
        child.free()
    _displayed_count = 0
    for id_text in item_ids:
        var definition := registry.get_item(StringName(id_text)) as ItemDefinition
        if definition == null:
            push_error("Missing inventory item: %s" % id_text)
            continue
        var column := VBoxContainer.new()
        column.custom_minimum_size = Vector2(240, 0)
        var title := Label.new()
        title.text = definition.display_name
        title.add_theme_font_size_override("font_size", 18)
        var description := Label.new()
        description.text = definition.description
        description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        column.add_child(title)
        column.add_child(description)
        _items.add_child(column)
        _displayed_count += 1

func open() -> void:
    visible = true
    $Margin/Rows/Header/Close.grab_focus()

func close() -> void:
    if not visible:
        return
    visible = false
    closed.emit()

func displayed_count() -> int:
    return _displayed_count
```

Create `game/ui/journal_overlay.gd`:

```gdscript
class_name JournalOverlay
extends ColorRect

signal closed

var _displayed_count := 0
@onready var _entries: VBoxContainer = $Frame/Margin/Rows/Pages/EntryScroll/Entries
@onready var _sketch: Label = $Frame/Margin/Rows/Pages/Sketch

func _ready() -> void:
    $Frame/Margin/Rows/Header/Close.pressed.connect(close)

func populate(entry_ids: PackedStringArray, registry: Node) -> void:
    for child in _entries.get_children():
        child.free()
    _displayed_count = 0
    for id_text in entry_ids:
        var definition := registry.get_journal_entry(StringName(id_text)) as JournalEntryDefinition
        if definition == null:
            push_error("Missing journal entry: %s" % id_text)
            continue
        var title := Label.new()
        title.text = definition.title
        title.add_theme_font_size_override("font_size", 19)
        var body := Label.new()
        body.text = definition.body
        body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        _entries.add_child(title)
        _entries.add_child(body)
        _displayed_count += 1
    _sketch.text = (
        "EXPERIMENT SKETCH\n\n"
        + "Spatial axes: equilibrium (0)\n"
        + "Temporal bias: one division forward (+1)\n\n"
        + "White lever: departure"
    )

func open() -> void:
    visible = true
    $Frame/Margin/Rows/Header/Close.grab_focus()

func close() -> void:
    if not visible:
        return
    visible = false
    closed.emit()

func displayed_count() -> int:
    return _displayed_count
```

Create `game/ui/pause_overlay.gd`:

```gdscript
class_name PauseOverlay
extends ColorRect

signal resume_requested
signal restart_requested
signal quit_requested
signal reduced_motion_changed(enabled: bool)

@onready var _reduced_motion: CheckButton = $Frame/Margin/Rows/ReducedMotion

func _ready() -> void:
    $Frame/Margin/Rows/Resume.pressed.connect(func() -> void: resume_requested.emit())
    $Frame/Margin/Rows/Restart.pressed.connect(func() -> void: restart_requested.emit())
    $Frame/Margin/Rows/Quit.pressed.connect(func() -> void: quit_requested.emit())
    _reduced_motion.toggled.connect(
        func(enabled: bool) -> void: reduced_motion_changed.emit(enabled)
    )

func open(reduced_motion: bool) -> void:
    _reduced_motion.set_pressed_no_signal(reduced_motion)
    visible = true
    $Frame/Margin/Rows/Resume.grab_focus()

func close() -> void:
    visible = false

func set_reduced_motion(enabled: bool) -> void:
    _reduced_motion.set_pressed_no_signal(enabled)
```

- [ ] **Step 4: Create the component scenes with stable node paths**

Create `game/ui/observation_band.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://game/ui/observation_band.gd" id="1"]

[node name="ObservationBand" type="PanelContainer"]
visible = false
offset_left = 160.0
offset_top = 520.0
offset_right = 1120.0
offset_bottom = 700.0
script = ExtResource("1")

[node name="Margin" type="MarginContainer" parent="."]
layout_mode = 2
theme_override_constants/margin_left = 24
theme_override_constants/margin_top = 18
theme_override_constants/margin_right = 24
theme_override_constants/margin_bottom = 14

[node name="Rows" type="VBoxContainer" parent="Margin"]
layout_mode = 2
theme_override_constants/separation = 10

[node name="Text" type="Label" parent="Margin/Rows"]
custom_minimum_size = Vector2(0, 88)
layout_mode = 2
autowrap_mode = 3
text = "Observation"

[node name="Continue" type="Button" parent="Margin/Rows"]
custom_minimum_size = Vector2(130, 34)
layout_mode = 2
size_flags_horizontal = 8
text = "Continue"
```

Create `game/ui/inventory_tray.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://game/ui/inventory_tray.gd" id="1"]

[node name="InventoryTray" type="PanelContainer"]
visible = false
offset_left = 120.0
offset_top = 390.0
offset_right = 1160.0
offset_bottom = 690.0
script = ExtResource("1")

[node name="Margin" type="MarginContainer" parent="."]
layout_mode = 2
theme_override_constants/margin_left = 24
theme_override_constants/margin_top = 18
theme_override_constants/margin_right = 24
theme_override_constants/margin_bottom = 18

[node name="Rows" type="VBoxContainer" parent="Margin"]
layout_mode = 2
theme_override_constants/separation = 16

[node name="Header" type="HBoxContainer" parent="Margin/Rows"]
layout_mode = 2

[node name="Title" type="Label" parent="Margin/Rows/Header"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_font_sizes/font_size = 24
text = "Instrument satchel"

[node name="Close" type="Button" parent="Margin/Rows/Header"]
custom_minimum_size = Vector2(42, 42)
layout_mode = 2
tooltip_text = "Close inventory"
text = "X"

[node name="Items" type="HBoxContainer" parent="Margin/Rows"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/separation = 28
```

Create `game/ui/journal_overlay.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://game/ui/journal_overlay.gd" id="1"]

[node name="JournalOverlay" type="ColorRect"]
visible = false
offset_right = 1280.0
offset_bottom = 720.0
color = Color(0.025, 0.03, 0.035, 0.88)
script = ExtResource("1")

[node name="Frame" type="PanelContainer" parent="."]
offset_left = 110.0
offset_top = 70.0
offset_right = 1170.0
offset_bottom = 650.0

[node name="Margin" type="MarginContainer" parent="Frame"]
layout_mode = 2
theme_override_constants/margin_left = 32
theme_override_constants/margin_top = 24
theme_override_constants/margin_right = 32
theme_override_constants/margin_bottom = 28

[node name="Rows" type="VBoxContainer" parent="Frame/Margin"]
layout_mode = 2
theme_override_constants/separation = 18

[node name="Header" type="HBoxContainer" parent="Frame/Margin/Rows"]
layout_mode = 2

[node name="Title" type="Label" parent="Frame/Margin/Rows/Header"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_font_sizes/font_size = 26
text = "Laboratory journal"

[node name="Close" type="Button" parent="Frame/Margin/Rows/Header"]
custom_minimum_size = Vector2(42, 42)
layout_mode = 2
tooltip_text = "Close journal"
text = "X"

[node name="Pages" type="HBoxContainer" parent="Frame/Margin/Rows"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/separation = 42

[node name="EntryScroll" type="ScrollContainer" parent="Frame/Margin/Rows/Pages"]
custom_minimum_size = Vector2(480, 0)
layout_mode = 2
size_flags_horizontal = 3

[node name="Entries" type="VBoxContainer" parent="Frame/Margin/Rows/Pages/EntryScroll"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_constants/separation = 8

[node name="Sketch" type="Label" parent="Frame/Margin/Rows/Pages"]
custom_minimum_size = Vector2(420, 0)
layout_mode = 2
size_flags_horizontal = 3
theme_override_font_sizes/font_size = 18
autowrap_mode = 3
text = "Experiment sketch"
```

Create `game/ui/pause_overlay.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://game/ui/pause_overlay.gd" id="1"]

[node name="PauseOverlay" type="ColorRect"]
visible = false
offset_right = 1280.0
offset_bottom = 720.0
color = Color(0.02, 0.025, 0.03, 0.86)
script = ExtResource("1")

[node name="Frame" type="PanelContainer" parent="."]
offset_left = 470.0
offset_top = 145.0
offset_right = 810.0
offset_bottom = 575.0

[node name="Margin" type="MarginContainer" parent="Frame"]
layout_mode = 2
theme_override_constants/margin_left = 34
theme_override_constants/margin_top = 30
theme_override_constants/margin_right = 34
theme_override_constants/margin_bottom = 30

[node name="Rows" type="VBoxContainer" parent="Frame/Margin"]
layout_mode = 2
theme_override_constants/separation = 16

[node name="Title" type="Label" parent="Frame/Margin/Rows"]
layout_mode = 2
theme_override_font_sizes/font_size = 28
text = "Experiment paused"
horizontal_alignment = 1

[node name="Resume" type="Button" parent="Frame/Margin/Rows"]
custom_minimum_size = Vector2(0, 46)
layout_mode = 2
text = "Resume"

[node name="ReducedMotion" type="CheckButton" parent="Frame/Margin/Rows"]
custom_minimum_size = Vector2(0, 46)
layout_mode = 2
text = "Reduced motion"

[node name="Restart" type="Button" parent="Frame/Margin/Rows"]
custom_minimum_size = Vector2(0, 46)
layout_mode = 2
text = "Restart chapter"

[node name="Quit" type="Button" parent="Frame/Margin/Rows"]
custom_minimum_size = Vector2(0, 46)
layout_mode = 2
text = "Quit"
```

- [ ] **Step 5: Implement the HUD coordinator and scene composition**

Create `game/ui/game_hud.gd`:

```gdscript
class_name GameHUD
extends CanvasLayer

signal restart_requested
signal quit_requested
signal pause_changed(paused: bool)
signal reduced_motion_changed(enabled: bool)
signal external_modal_close_requested

var _session: Node
var _registry: Node
var _reduced_motion := false
var _external_modal_open := false
@onready var _observation: ObservationBand = $ObservationBand
@onready var _inventory: InventoryTray = $InventoryTray
@onready var _journal: JournalOverlay = $JournalOverlay
@onready var _pause: PauseOverlay = $PauseOverlay
@onready var _focus_prompt: PanelContainer = $FocusPrompt
@onready var _focus_label: Label = $FocusPrompt/Label

func _ready() -> void:
    $Toolbar/Buttons/Journal.pressed.connect(open_journal)
    $Toolbar/Buttons/Inventory.pressed.connect(open_inventory)
    _pause.resume_requested.connect(resume)
    _pause.restart_requested.connect(func() -> void: restart_requested.emit())
    _pause.quit_requested.connect(func() -> void: quit_requested.emit())
    _pause.reduced_motion_changed.connect(set_reduced_motion)

func bind(session: Node, registry: Node) -> void:
    _session = session
    _registry = registry

func show_observation(id: StringName) -> void:
    var definition := _registry.get_observation(id) as ObservationDefinition
    if definition == null:
        push_error("Missing observation: %s" % id)
        _observation.show_text("The observation cannot be recovered.")
        return
    _observation.show_text(definition.text)

func set_focus_prompt(text: String, is_visible: bool) -> void:
    _focus_label.text = text
    _focus_prompt.visible = is_visible

func set_external_modal_open(open: bool) -> void:
    _external_modal_open = open

func open_inventory() -> void:
    _journal.close()
    _inventory.populate(_session.item_ids(), _registry)
    _inventory.open()

func open_journal() -> void:
    _inventory.close()
    _journal.populate(_session.journal_entry_ids(), _registry)
    _journal.open()

func toggle_pause() -> void:
    if _pause.visible:
        resume()
        return
    _inventory.close()
    _journal.close()
    _pause.open(_reduced_motion)
    get_tree().paused = true
    pause_changed.emit(true)

func resume() -> void:
    _pause.close()
    get_tree().paused = false
    pause_changed.emit(false)

func set_reduced_motion(enabled: bool) -> void:
    if _reduced_motion == enabled:
        return
    _reduced_motion = enabled
    _pause.set_reduced_motion(enabled)
    reduced_motion_changed.emit(enabled)

func reduced_motion_enabled() -> bool:
    return _reduced_motion

func observation_visible() -> bool:
    return _observation.visible

func observation_text() -> String:
    return _observation.text_value()

func inventory_visible() -> bool:
    return _inventory.visible

func displayed_item_count() -> int:
    return _inventory.displayed_count()

func journal_visible() -> bool:
    return _journal.visible

func displayed_journal_count() -> int:
    return _journal.displayed_count()

func focus_prompt_text() -> String:
    return _focus_label.text

func _unhandled_input(event: InputEvent) -> void:
    var key_event := event as InputEventKey
    if key_event == null or not key_event.pressed or key_event.echo:
        return
    if (_pause.visible or _observation.visible) and key_event.keycode != KEY_ESCAPE:
        return
    match key_event.keycode:
        KEY_J:
            open_journal()
            get_viewport().set_input_as_handled()
        KEY_I:
            open_inventory()
            get_viewport().set_input_as_handled()
        KEY_ESCAPE:
            if _observation.visible:
                _observation.dismiss()
            elif _inventory.visible:
                _inventory.close()
            elif _journal.visible:
                _journal.close()
            elif _external_modal_open:
                external_modal_close_requested.emit()
            else:
                toggle_pause()
            get_viewport().set_input_as_handled()
```

Create `game/ui/game_hud.tscn`:

```ini
[gd_scene load_steps=6 format=3]

[ext_resource type="Script" path="res://game/ui/game_hud.gd" id="1"]
[ext_resource type="PackedScene" path="res://game/ui/observation_band.tscn" id="2"]
[ext_resource type="PackedScene" path="res://game/ui/inventory_tray.tscn" id="3"]
[ext_resource type="PackedScene" path="res://game/ui/journal_overlay.tscn" id="4"]
[ext_resource type="PackedScene" path="res://game/ui/pause_overlay.tscn" id="5"]

[node name="GameHUD" type="CanvasLayer"]
process_mode = 3
layer = 30
script = ExtResource("1")

[node name="Toolbar" type="PanelContainer" parent="."]
offset_left = 960.0
offset_top = 18.0
offset_right = 1260.0
offset_bottom = 70.0

[node name="Buttons" type="HBoxContainer" parent="Toolbar"]
layout_mode = 2
theme_override_constants/separation = 8

[node name="Journal" type="Button" parent="Toolbar/Buttons"]
custom_minimum_size = Vector2(140, 46)
layout_mode = 2
tooltip_text = "Journal (J)"
text = "Journal"

[node name="Inventory" type="Button" parent="Toolbar/Buttons"]
custom_minimum_size = Vector2(140, 46)
layout_mode = 2
tooltip_text = "Inventory (I)"
text = "Inventory"

[node name="FocusPrompt" type="PanelContainer" parent="."]
visible = false
offset_left = 490.0
offset_top = 625.0
offset_right = 790.0
offset_bottom = 680.0

[node name="Label" type="Label" parent="FocusPrompt"]
layout_mode = 2
text = "Inspect"
horizontal_alignment = 1
vertical_alignment = 1

[node name="ObservationBand" parent="." instance=ExtResource("2")]
[node name="InventoryTray" parent="." instance=ExtResource("3")]
[node name="JournalOverlay" parent="." instance=ExtResource("4")]
[node name="PauseOverlay" parent="." instance=ExtResource("5")]
```

- [ ] **Step 6: Run HUD tests and check scene import**

Run:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_all.gd
```

Expected: exit 0; observation, inventory, journal, focus-prompt, and reduced-motion assertions pass without missing-node errors.

- [ ] **Step 7: Commit the HUD surfaces**

```bash
git add game/ui tests/test_game_hud.gd tests/run_all.gd
git commit -m "feat: add Act 0 HUD and journal surfaces"
```

### Task 7: Model Workbench Assembly and Calibration

**Files:**
- Create: `game/workbench/component_token.gd`
- Create: `game/workbench/component_slot.gd`
- Create: `game/workbench/model_workbench.gd`
- Create: `game/workbench/model_workbench.tscn`
- Create: `tests/test_model_workbench.gd`
- Modify: `tests/run_all.gd`

**Interfaces:**
- Consumes: acquired item IDs and placed-slot state from `GameSession` and `WorkshopDirector`.
- Produces: `ModelWorkbench.open_with_items()`, `apply_placement_result()`, `set_calibration()`, state query methods, and `placement_requested`, `calibration_changed`, `lever_pulled`, and `closed` signals.

- [ ] **Step 1: Write mouse/keyboard-equivalent workbench tests**

Create `tests/test_model_workbench.gd`:

```gdscript
extends RefCounted

const WorkbenchScene := preload("res://game/workbench/model_workbench.tscn")

func run(suite: TestSuite, tree: SceneTree) -> void:
    var workbench := WorkbenchScene.instantiate()
    tree.root.add_child(workbench)
    await tree.process_frame

    var placements: Array[String] = []
    var calibrations: Array[Vector2i] = []
    var lever_count: Array[int] = [0]
    workbench.placement_requested.connect(
        func(item_id: StringName, slot_id: StringName) -> void:
            placements.append("%s>%s" % [item_id, slot_id])
    )
    workbench.calibration_changed.connect(
        func(spatial: int, temporal: int) -> void:
            calibrations.append(Vector2i(spatial, temporal))
    )
    workbench.lever_pulled.connect(func() -> void: lever_count[0] += 1)

    workbench.open_with_items(
        PackedStringArray([
            "act00.item.ivory_guides",
            "act00.item.crystal_prism",
            "act00.item.control_levers",
        ]),
        {},
        0,
        0
    )
    suite.expect_true(workbench.visible, "workbench opens")
    suite.expect_equal(workbench.available_token_count(), 3, "three tokens available")
    suite.expect_true(not workbench.lever_enabled(), "lever locked before assembly")

    workbench.select_item(&"act00.item.crystal_prism")
    workbench.request_slot(&"act00.slot.ivory_guides")
    suite.expect_equal(
        placements[-1],
        "act00.item.crystal_prism>act00.slot.ivory_guides",
        "keyboard selection emits placement request"
    )
    workbench.apply_placement_result(
        &"act00.item.crystal_prism",
        &"act00.slot.ivory_guides",
        false
    )
    suite.expect_equal(workbench.placed_count(), 0, "rejected placement does not mutate UI")

    workbench.apply_placement_result(
        &"act00.item.ivory_guides",
        &"act00.slot.ivory_guides",
        true
    )
    workbench.apply_placement_result(
        &"act00.item.crystal_prism",
        &"act00.slot.crystal_prism",
        true
    )
    workbench.apply_placement_result(
        &"act00.item.control_levers",
        &"act00.slot.control_levers",
        true
    )
    suite.expect_equal(workbench.placed_count(), 3, "three accepted placements displayed")
    suite.expect_true(workbench.calibration_visible(), "calibration appears after assembly")
    suite.expect_true(workbench.lever_enabled(), "lever enabled after assembly")

    workbench.set_calibration(0, 1)
    suite.expect_equal(workbench.calibration_values(), Vector2i(0, 1), "target calibration shown")
    suite.expect_equal(calibrations[-1], Vector2i(0, 1), "calibration event emitted")
    workbench.request_lever()
    suite.expect_equal(lever_count[0], 1, "lever request emitted")

    tree.root.remove_child(workbench)
    workbench.free()
```

Append this preload to `TEST_SCRIPTS` in `tests/run_all.gd`:

```gdscript
    preload("res://tests/test_model_workbench.gd"),
```

- [ ] **Step 2: Run the workbench test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: parse/load failure naming missing `res://game/workbench/model_workbench.tscn`.

- [ ] **Step 3: Implement draggable tokens and typed slots**

Create `game/workbench/component_token.gd`:

```gdscript
class_name ComponentToken
extends Button

signal token_selected(item_id: StringName)

@export var item_id: StringName

func _ready() -> void:
    pressed.connect(func() -> void: token_selected.emit(item_id))

func set_available(available: bool) -> void:
    visible = available
    disabled = not available

func _get_drag_data(_at_position: Vector2) -> Variant:
    if disabled or not visible:
        return null
    var preview := Label.new()
    preview.text = text
    preview.modulate = Color(1, 1, 1, 0.85)
    set_drag_preview(preview)
    return {"item_id": item_id}
```

Create `game/workbench/component_slot.gd`:

```gdscript
class_name ComponentSlot
extends Button

signal slot_activated(slot_id: StringName)
signal drop_requested(item_id: StringName, slot_id: StringName)

@export var slot_id: StringName
@export var expected_item_id: StringName
@export var empty_label := "Empty fitting"
var filled_item_id: StringName

func _ready() -> void:
    pressed.connect(func() -> void: slot_activated.emit(slot_id))

func reset_slot() -> void:
    filled_item_id = StringName()
    disabled = false
    text = empty_label

func set_filled(item_id: StringName, display_text: String) -> void:
    filled_item_id = item_id
    disabled = true
    text = display_text

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    return data is Dictionary and data.has("item_id") and filled_item_id == StringName()

func _drop_data(_at_position: Vector2, data: Variant) -> void:
    drop_requested.emit(StringName(data["item_id"]), slot_id)
```

- [ ] **Step 4: Implement workbench state and controls**

Create `game/workbench/model_workbench.gd`:

```gdscript
class_name ModelWorkbench
extends Control

signal placement_requested(item_id: StringName, slot_id: StringName)
signal calibration_changed(spatial: int, temporal: int)
signal lever_pulled
signal closed

const ITEM_LABELS := {
    &"act00.item.ivory_guides": "Ivory guides",
    &"act00.item.crystal_prism": "Crystalline prism",
    &"act00.item.control_levers": "Control levers",
}

var _selected_item: StringName
var _placed := {}
var _spatial := 0
var _temporal := 0
@onready var _tokens: Array[ComponentToken] = [
    $Frame/Margin/Rows/Tray/Guides,
    $Frame/Margin/Rows/Tray/Prism,
    $Frame/Margin/Rows/Tray/Levers,
]
@onready var _slots: Array[ComponentSlot] = [
    $Frame/Margin/Rows/Machine/Slots/GuidesSlot,
    $Frame/Margin/Rows/Machine/Slots/PrismSlot,
    $Frame/Margin/Rows/Machine/Slots/LeversSlot,
]
@onready var _calibration: VBoxContainer = $Frame/Margin/Rows/Calibration
@onready var _spatial_label: Label = $Frame/Margin/Rows/Calibration/Spatial/Value
@onready var _temporal_label: Label = $Frame/Margin/Rows/Calibration/Temporal/Value
@onready var _lever: Button = $Frame/Margin/Rows/Lever
@onready var _status: Label = $Frame/Margin/Rows/Status

func _ready() -> void:
    for token in _tokens:
        token.token_selected.connect(select_item)
    for slot in _slots:
        slot.slot_activated.connect(request_slot)
        slot.drop_requested.connect(
            func(item_id: StringName, slot_id: StringName) -> void:
                placement_requested.emit(item_id, slot_id)
        )
    $Frame/Margin/Rows/Header/Close.pressed.connect(dismiss)
    $Frame/Margin/Rows/Calibration/Spatial/Decrease.pressed.connect(
        func() -> void: set_calibration(_spatial - 1, _temporal)
    )
    $Frame/Margin/Rows/Calibration/Spatial/Increase.pressed.connect(
        func() -> void: set_calibration(_spatial + 1, _temporal)
    )
    $Frame/Margin/Rows/Calibration/Temporal/Decrease.pressed.connect(
        func() -> void: set_calibration(_spatial, _temporal - 1)
    )
    $Frame/Margin/Rows/Calibration/Temporal/Increase.pressed.connect(
        func() -> void: set_calibration(_spatial, _temporal + 1)
    )
    _lever.pressed.connect(request_lever)

func open_with_items(
    item_ids: PackedStringArray,
    placed_slots: Dictionary,
    spatial: int,
    temporal: int
) -> void:
    _selected_item = StringName()
    _placed = placed_slots.duplicate()
    for slot in _slots:
        slot.reset_slot()
        if _placed.has(slot.slot_id):
            var item_id: StringName = _placed[slot.slot_id]
            slot.set_filled(item_id, ITEM_LABELS[item_id])
    for token in _tokens:
        var available := item_ids.has(String(token.item_id)) and not _placed.values().has(token.item_id)
        token.set_available(available)
    set_calibration(spatial, temporal, false)
    _refresh_unlocks()
    _status.text = "Select a component, then its matching fitting."
    visible = true
    _focus_first_available_token()

func select_item(item_id: StringName) -> void:
    _selected_item = item_id
    _status.text = "%s selected." % ITEM_LABELS.get(item_id, "Component")
    for slot in _slots:
        if not slot.disabled:
            slot.grab_focus()
            break

func request_slot(slot_id: StringName) -> void:
    if _selected_item == StringName():
        _status.text = "Select a component first."
        return
    placement_requested.emit(_selected_item, slot_id)

func apply_placement_result(item_id: StringName, slot_id: StringName, accepted: bool) -> void:
    if not accepted:
        _status.text = "The fitting refuses it."
        return
    _placed[slot_id] = item_id
    for slot in _slots:
        if slot.slot_id == slot_id:
            slot.set_filled(item_id, ITEM_LABELS[item_id])
            break
    for token in _tokens:
        if token.item_id == item_id:
            token.set_available(false)
            break
    _selected_item = StringName()
    _status.text = "The component seats cleanly."
    _refresh_unlocks()
    _focus_first_available_token()

func set_calibration(spatial: int, temporal: int, emit_change := true) -> void:
    var next_spatial := clampi(spatial, -2, 2)
    var next_temporal := clampi(temporal, -2, 2)
    var changed := next_spatial != _spatial or next_temporal != _temporal
    _spatial = next_spatial
    _temporal = next_temporal
    _spatial_label.text = "%+d" % _spatial
    _temporal_label.text = "%+d" % _temporal
    if emit_change and changed:
        calibration_changed.emit(_spatial, _temporal)

func request_lever() -> void:
    if _lever.disabled:
        return
    lever_pulled.emit()

func dismiss() -> void:
    visible = false
    closed.emit()

func available_token_count() -> int:
    var count := 0
    for token in _tokens:
        if token.visible and not token.disabled:
            count += 1
    return count

func placed_count() -> int:
    return _placed.size()

func calibration_visible() -> bool:
    return _calibration.visible

func lever_enabled() -> bool:
    return not _lever.disabled

func calibration_values() -> Vector2i:
    return Vector2i(_spatial, _temporal)

func show_status(text: String) -> void:
    _status.text = text

func _unhandled_input(event: InputEvent) -> void:
    var key_event := event as InputEventKey
    if visible and key_event != null and key_event.pressed and not key_event.echo:
        if key_event.keycode == KEY_ESCAPE:
            dismiss()
            get_viewport().set_input_as_handled()

func _refresh_unlocks() -> void:
    var assembled := _placed.size() == _slots.size()
    _calibration.visible = assembled
    _lever.disabled = not assembled
    if assembled:
        _status.text = "Spatial equilibrium; temporal bias one division forward."

func _focus_first_available_token() -> void:
    for token in _tokens:
        if token.visible and not token.disabled:
            token.grab_focus()
            return
    if _calibration.visible:
        $Frame/Margin/Rows/Calibration/Spatial/Decrease.grab_focus()
```

- [ ] **Step 5: Create the full-screen workbench scene**

Create `game/workbench/model_workbench.tscn`:

```ini
[gd_scene load_steps=4 format=3]

[ext_resource type="Script" path="res://game/workbench/model_workbench.gd" id="1"]
[ext_resource type="Script" path="res://game/workbench/component_token.gd" id="2"]
[ext_resource type="Script" path="res://game/workbench/component_slot.gd" id="3"]

[node name="ModelWorkbench" type="Control"]
visible = false
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 1
script = ExtResource("1")

[node name="Backdrop" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.025, 0.035, 0.04, 0.96)

[node name="Frame" type="PanelContainer" parent="."]
layout_mode = 0
offset_left = 90.0
offset_top = 42.0
offset_right = 1190.0
offset_bottom = 678.0

[node name="Margin" type="MarginContainer" parent="Frame"]
layout_mode = 2
theme_override_constants/margin_left = 32
theme_override_constants/margin_top = 24
theme_override_constants/margin_right = 32
theme_override_constants/margin_bottom = 24

[node name="Rows" type="VBoxContainer" parent="Frame/Margin"]
layout_mode = 2
theme_override_constants/separation = 14

[node name="Header" type="HBoxContainer" parent="Frame/Margin/Rows"]
layout_mode = 2

[node name="Title" type="Label" parent="Frame/Margin/Rows/Header"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_font_sizes/font_size = 28
text = "The model"

[node name="Close" type="Button" parent="Frame/Margin/Rows/Header"]
custom_minimum_size = Vector2(42, 42)
layout_mode = 2
tooltip_text = "Return to workshop"
text = "X"

[node name="Machine" type="Control" parent="Frame/Margin/Rows"]
custom_minimum_size = Vector2(0, 150)
layout_mode = 2

[node name="Slots" type="HBoxContainer" parent="Frame/Margin/Rows/Machine"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 20
alignment = 1

[node name="GuidesSlot" type="Button" parent="Frame/Margin/Rows/Machine/Slots"]
custom_minimum_size = Vector2(260, 130)
layout_mode = 2
text = "Empty fitting\nIvory guides"
script = ExtResource("3")
slot_id = &"act00.slot.ivory_guides"
expected_item_id = &"act00.item.ivory_guides"
empty_label = "Empty fitting\nIvory guides"

[node name="PrismSlot" type="Button" parent="Frame/Margin/Rows/Machine/Slots"]
custom_minimum_size = Vector2(260, 130)
layout_mode = 2
text = "Empty fitting\nCrystal prism"
script = ExtResource("3")
slot_id = &"act00.slot.crystal_prism"
expected_item_id = &"act00.item.crystal_prism"
empty_label = "Empty fitting\nCrystal prism"

[node name="LeversSlot" type="Button" parent="Frame/Margin/Rows/Machine/Slots"]
custom_minimum_size = Vector2(260, 130)
layout_mode = 2
text = "Empty fitting\nControl levers"
script = ExtResource("3")
slot_id = &"act00.slot.control_levers"
expected_item_id = &"act00.item.control_levers"
empty_label = "Empty fitting\nControl levers"

[node name="TrayLabel" type="Label" parent="Frame/Margin/Rows"]
layout_mode = 2
text = "Components at hand"

[node name="Tray" type="HBoxContainer" parent="Frame/Margin/Rows"]
custom_minimum_size = Vector2(0, 70)
layout_mode = 2
theme_override_constants/separation = 18
alignment = 1

[node name="Guides" type="Button" parent="Frame/Margin/Rows/Tray"]
custom_minimum_size = Vector2(220, 54)
layout_mode = 2
text = "Ivory guides"
script = ExtResource("2")
item_id = &"act00.item.ivory_guides"

[node name="Prism" type="Button" parent="Frame/Margin/Rows/Tray"]
custom_minimum_size = Vector2(220, 54)
layout_mode = 2
text = "Crystalline prism"
script = ExtResource("2")
item_id = &"act00.item.crystal_prism"

[node name="Levers" type="Button" parent="Frame/Margin/Rows/Tray"]
custom_minimum_size = Vector2(220, 54)
layout_mode = 2
text = "Control levers"
script = ExtResource("2")
item_id = &"act00.item.control_levers"

[node name="Calibration" type="VBoxContainer" parent="Frame/Margin/Rows"]
visible = false
layout_mode = 2
theme_override_constants/separation = 8

[node name="Spatial" type="HBoxContainer" parent="Frame/Margin/Rows/Calibration"]
layout_mode = 2
alignment = 1

[node name="Name" type="Label" parent="Frame/Margin/Rows/Calibration/Spatial"]
custom_minimum_size = Vector2(210, 0)
layout_mode = 2
text = "Spatial equilibrium"

[node name="Decrease" type="Button" parent="Frame/Margin/Rows/Calibration/Spatial"]
custom_minimum_size = Vector2(54, 42)
layout_mode = 2
text = "<"

[node name="Value" type="Label" parent="Frame/Margin/Rows/Calibration/Spatial"]
custom_minimum_size = Vector2(70, 42)
layout_mode = 2
text = "+0"
horizontal_alignment = 1
vertical_alignment = 1

[node name="Increase" type="Button" parent="Frame/Margin/Rows/Calibration/Spatial"]
custom_minimum_size = Vector2(54, 42)
layout_mode = 2
text = ">"

[node name="Temporal" type="HBoxContainer" parent="Frame/Margin/Rows/Calibration"]
layout_mode = 2
alignment = 1

[node name="Name" type="Label" parent="Frame/Margin/Rows/Calibration/Temporal"]
custom_minimum_size = Vector2(210, 0)
layout_mode = 2
text = "Temporal bias"

[node name="Decrease" type="Button" parent="Frame/Margin/Rows/Calibration/Temporal"]
custom_minimum_size = Vector2(54, 42)
layout_mode = 2
text = "<"

[node name="Value" type="Label" parent="Frame/Margin/Rows/Calibration/Temporal"]
custom_minimum_size = Vector2(70, 42)
layout_mode = 2
text = "+0"
horizontal_alignment = 1
vertical_alignment = 1

[node name="Increase" type="Button" parent="Frame/Margin/Rows/Calibration/Temporal"]
custom_minimum_size = Vector2(54, 42)
layout_mode = 2
text = ">"

[node name="Lever" type="Button" parent="Frame/Margin/Rows"]
custom_minimum_size = Vector2(0, 58)
layout_mode = 2
disabled = true
text = "Pull the white departure lever"

[node name="Status" type="Label" parent="Frame/Margin/Rows"]
custom_minimum_size = Vector2(0, 44)
layout_mode = 2
autowrap_mode = 3
text = "Select a component, then its matching fitting."
horizontal_alignment = 1
```

- [ ] **Step 6: Run workbench tests and import verification**

Run:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_all.gd
```

Expected: exit 0; rejected placement, accepted placement, calibration, keyboard selection, and lever assertions pass.

- [ ] **Step 7: Commit the workbench**

```bash
git add game/workbench tests/test_model_workbench.gd tests/run_all.gd
git commit -m "feat: add model assembly and calibration workbench"
```

### Task 8: Workshop Location, Cold Open, and Chapter Flow

**Files:**
- Create: `game/act_00/workshop.gd`
- Create: `game/act_00/workshop.tscn`
- Create: `game/ui/cold_open.gd`
- Create: `game/ui/cold_open.tscn`
- Create: `game/ui/closing_card.gd`
- Create: `game/ui/closing_card.tscn`
- Replace: `game/main.gd`
- Replace: `game/main.tscn`
- Create: `tests/test_scene_flow.gd`
- Modify: `tests/run_all.gd`
- Modify: `game/ui/game_hud.gd`

**Interfaces:**
- Consumes: all systems from Tasks 2 through 7.
- Produces: a playable semantic path from cold open to closing card; `Act00Workshop.set_active()` and flow signals; `ColdOpen.begin()`; `ClosingCard.open()`; and a scene-instantiation smoke test.

- [ ] **Step 1: Write scene-instantiation and chapter-flow tests**

Create `tests/test_scene_flow.gd`:

```gdscript
extends RefCounted

const SCENES := {
    "res://game/main.tscn": "Main",
    "res://game/player/player.tscn": "Player",
    "res://game/ui/game_hud.tscn": "GameHUD",
    "res://game/workbench/model_workbench.tscn": "ModelWorkbench",
    "res://game/act_00/workshop.tscn": "Workshop",
    "res://game/ui/cold_open.tscn": "ColdOpen",
    "res://game/ui/closing_card.tscn": "ClosingCard",
}

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    for path in SCENES:
        var packed := load(path) as PackedScene
        suite.expect_not_null(packed, "%s loads" % path)
        if packed != null:
            var instance := packed.instantiate()
            suite.expect_equal(instance.name, SCENES[path], "%s root name" % path)
            instance.free()

    var main := load("res://game/main.tscn").instantiate()
    tree.root.add_child(main)
    await tree.process_frame
    suite.expect_true(main.get_node("ColdOpen").visible, "cold open starts visible")
    suite.expect_true(not main.get_node("Workshop").visible, "workshop starts inactive")
    main.get_node("ColdOpen").begin()
    await tree.process_frame
    suite.expect_true(main.get_node("Workshop").visible, "begin reveals workshop")
    main.get_node("Workshop").chapter_completed.emit()
    await tree.process_frame
    suite.expect_true(main.get_node("ClosingCard").visible, "completion reveals closing card")
    tree.root.remove_child(main)
    main.free()
    tree.paused = false
```

Append this preload to `TEST_SCRIPTS` in `tests/run_all.gd`:

```gdscript
    preload("res://tests/test_scene_flow.gd"),
```

- [ ] **Step 2: Run the scene-flow test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: load failure naming missing `workshop.tscn`, `cold_open.tscn`, or `closing_card.tscn`.

- [ ] **Step 3: Implement the cold open and closing card**

Create `game/ui/cold_open.gd`:

```gdscript
class_name ColdOpen
extends Control

signal start_requested

var _started := false

func _ready() -> void:
    $Panel/Margin/Rows/Begin.pressed.connect(begin)

func open() -> void:
    _started = false
    visible = true
    $Panel/Margin/Rows/Begin.grab_focus()

func begin() -> void:
    if _started:
        return
    _started = true
    visible = false
    start_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
    var key_event := event as InputEventKey
    if visible and key_event != null and key_event.pressed and not key_event.echo:
        if key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_E]:
            begin()
            get_viewport().set_input_as_handled()
```

Create `game/ui/cold_open.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://game/ui/cold_open.gd" id="1"]

[node name="ColdOpen" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 1
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.025, 0.035, 0.04, 1)

[node name="Panel" type="PanelContainer" parent="."]
layout_mode = 0
offset_left = 390.0
offset_top = 238.0
offset_right = 890.0
offset_bottom = 482.0

[node name="Margin" type="MarginContainer" parent="Panel"]
layout_mode = 2
theme_override_constants/margin_left = 36
theme_override_constants/margin_top = 30
theme_override_constants/margin_right = 36
theme_override_constants/margin_bottom = 30

[node name="Rows" type="VBoxContainer" parent="Panel/Margin"]
layout_mode = 2
theme_override_constants/separation = 18

[node name="Place" type="Label" parent="Panel/Margin/Rows"]
layout_mode = 2
theme_override_font_sizes/font_size = 30
text = "Richmond, 1895"
horizontal_alignment = 1

[node name="Time" type="Label" parent="Panel/Margin/Rows"]
layout_mode = 2
theme_override_font_sizes/font_size = 18
text = "Before the demonstration"
horizontal_alignment = 1

[node name="Begin" type="Button" parent="Panel/Margin/Rows"]
custom_minimum_size = Vector2(0, 48)
layout_mode = 2
text = "Begin"
```

Create `game/ui/closing_card.gd`:

```gdscript
class_name ClosingCard
extends Control

signal restart_requested
signal quit_requested

func _ready() -> void:
    $Panel/Margin/Rows/Commands/Restart.pressed.connect(
        func() -> void: restart_requested.emit()
    )
    $Panel/Margin/Rows/Commands/Quit.pressed.connect(func() -> void: quit_requested.emit())

func open() -> void:
    visible = true
    $Panel/Margin/Rows/Commands/Restart.grab_focus()
```

Create `game/ui/closing_card.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://game/ui/closing_card.gd" id="1"]

[node name="ClosingCard" type="Control"]
visible = false
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 1
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.02, 0.027, 0.03, 1)

[node name="Panel" type="PanelContainer" parent="."]
layout_mode = 0
offset_left = 330.0
offset_top = 190.0
offset_right = 950.0
offset_bottom = 530.0

[node name="Margin" type="MarginContainer" parent="Panel"]
layout_mode = 2
theme_override_constants/margin_left = 42
theme_override_constants/margin_top = 34
theme_override_constants/margin_right = 42
theme_override_constants/margin_bottom = 34

[node name="Rows" type="VBoxContainer" parent="Panel/Margin"]
layout_mode = 2
theme_override_constants/separation = 22

[node name="Title" type="Label" parent="Panel/Margin/Rows"]
layout_mode = 2
theme_override_font_sizes/font_size = 46
text = "TIME EXPEDITION"
horizontal_alignment = 1

[node name="Subtitle" type="Label" parent="Panel/Margin/Rows"]
layout_mode = 2
theme_override_font_sizes/font_size = 20
text = "The demonstration awaits."
horizontal_alignment = 1

[node name="Commands" type="HBoxContainer" parent="Panel/Margin/Rows"]
layout_mode = 2
theme_override_constants/separation = 16
alignment = 1

[node name="Restart" type="Button" parent="Panel/Margin/Rows/Commands"]
custom_minimum_size = Vector2(180, 48)
layout_mode = 2
text = "Restart"

[node name="Quit" type="Button" parent="Panel/Margin/Rows/Commands"]
custom_minimum_size = Vector2(180, 48)
layout_mode = 2
text = "Quit"
```

- [ ] **Step 4: Forward observation dismissal through the HUD**

Add this signal to `game/ui/game_hud.gd`:

```gdscript
signal observation_dismissed
```

Add this connection to `GameHUD._ready()`:

```gdscript
    _observation.dismissed.connect(func() -> void: observation_dismissed.emit())
```

- [ ] **Step 5: Implement workshop signal wiring**

Create `game/act_00/workshop.gd`:

```gdscript
class_name Act00Workshop
extends Node2D

signal chapter_completed
signal restart_requested
signal quit_requested

@onready var _director: WorkshopDirector = $WorkshopDirector
@onready var _player: PlayerController = $Player
@onready var _hud: GameHUD = $GameHUD
@onready var _workbench: ModelWorkbench = $WorkbenchLayer/ModelWorkbench

func _ready() -> void:
    _director.initialize(GameSession)
    _hud.bind(GameSession, ContentRegistry)
    _player.interaction_requested.connect(_director.handle_action)
    _player.focus_prompt_changed.connect(_hud.set_focus_prompt)
    _director.observation_requested.connect(_show_observation)
    _director.workbench_requested.connect(_open_workbench)
    _director.excursion_requested.connect(_play_accelerated_excursion)
    _director.chapter_completed.connect(_finish_chapter_after_observation)
    _workbench.placement_requested.connect(_place_component)
    _workbench.calibration_changed.connect(_director.update_calibration)
    _workbench.lever_pulled.connect(_pull_lever)
    _workbench.closed.connect(_close_workbench)
    _hud.pause_changed.connect(_on_pause_changed)
    _hud.observation_dismissed.connect(_on_observation_dismissed)
    _hud.external_modal_close_requested.connect(_workbench.dismiss)
    _hud.restart_requested.connect(func() -> void: restart_requested.emit())
    _hud.quit_requested.connect(func() -> void: quit_requested.emit())

func set_active(active: bool) -> void:
    visible = active
    process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
    _hud.visible = active
    _hud.process_mode = Node.PROCESS_MODE_ALWAYS if active else Node.PROCESS_MODE_DISABLED
    if not active:
        _workbench.visible = false
        _hud.set_external_modal_open(false)
    _player.set_input_enabled(active)

func _show_observation(id: StringName) -> void:
    _player.set_input_enabled(false)
    _hud.show_observation(id)

func _on_observation_dismissed() -> void:
    if not _workbench.visible and _director.phase != WorkshopDirector.Phase.COMPLETE and not get_tree().paused:
        _player.set_input_enabled(true)

func _open_workbench() -> void:
    _player.set_input_enabled(false)
    _hud.set_external_modal_open(true)
    _workbench.open_with_items(
        GameSession.item_ids(),
        _director.placed_slots(),
        _director.spatial_alignment,
        _director.temporal_bias
    )

func _close_workbench() -> void:
    _hud.set_external_modal_open(false)
    if _director.phase != WorkshopDirector.Phase.COMPLETE:
        _player.set_input_enabled(true)

func _place_component(item_id: StringName, slot_id: StringName) -> void:
    var accepted := _director.request_place_component(item_id, slot_id)
    _workbench.apply_placement_result(item_id, slot_id, accepted)

func _pull_lever() -> void:
    if not _director.pull_lever():
        _workbench.show_status("The model shudders, but the displacement collapses.")

func _play_accelerated_excursion() -> void:
    if _hud.observation_visible():
        await _hud.observation_dismissed
    _workbench.show_status("The model leaves the present.")
    await get_tree().create_timer(0.25).timeout
    if is_inside_tree():
        _director.complete_excursion()

func _finish_chapter_after_observation() -> void:
    _workbench.visible = false
    _hud.set_external_modal_open(false)
    _player.set_input_enabled(false)
    if _hud.observation_visible():
        await _hud.observation_dismissed
    chapter_completed.emit()

func _on_pause_changed(paused: bool) -> void:
    if paused:
        _player.set_input_enabled(false)
    elif not _workbench.visible and _director.phase != WorkshopDirector.Phase.COMPLETE:
        _player.set_input_enabled(true)
```

- [ ] **Step 6: Create the blocked workshop with every interactable**

Create `game/act_00/workshop.tscn`:

```ini
[gd_scene load_steps=9 format=3]

[ext_resource type="Script" path="res://game/act_00/workshop.gd" id="1"]
[ext_resource type="Script" path="res://game/act_00/workshop_director.gd" id="2"]
[ext_resource type="Script" path="res://game/shared/interactable.gd" id="3"]
[ext_resource type="PackedScene" path="res://game/player/player.tscn" id="4"]
[ext_resource type="PackedScene" path="res://game/ui/game_hud.tscn" id="5"]
[ext_resource type="PackedScene" path="res://game/workbench/model_workbench.tscn" id="6"]

[sub_resource type="RectangleShape2D" id="FloorShape"]
size = Vector2(3200, 40)

[sub_resource type="RectangleShape2D" id="InteractShape"]
size = Vector2(150, 130)

[node name="Workshop" type="Node2D"]
visible = false
process_mode = 4
script = ExtResource("1")

[node name="Backdrop" type="Polygon2D" parent="."]
polygon = PackedVector2Array(0, 0, 3200, 0, 3200, 720, 0, 720)
color = Color(0.075, 0.09, 0.1, 1)

[node name="WindowLight" type="Polygon2D" parent="."]
polygon = PackedVector2Array(1880, 90, 2350, 90, 2480, 620, 1750, 620)
color = Color(0.16, 0.25, 0.28, 0.38)

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(1600, 670)
collision_layer = 1
collision_mask = 1

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("FloorShape")

[node name="LeftWall" type="StaticBody2D" parent="."]
position = Vector2(-20, 360)
collision_layer = 1
collision_mask = 1

[node name="CollisionShape2D" type="CollisionShape2D" parent="LeftWall"]
rotation = 1.570796
shape = SubResource("FloorShape")

[node name="RightWall" type="StaticBody2D" parent="."]
position = Vector2(3220, 360)
collision_layer = 1
collision_mask = 1

[node name="CollisionShape2D" type="CollisionShape2D" parent="RightWall"]
rotation = 1.570796
shape = SubResource("FloorShape")

[node name="FloorVisual" type="Polygon2D" parent="."]
polygon = PackedVector2Array(0, 650, 3200, 650, 3200, 720, 0, 720)
color = Color(0.11, 0.105, 0.095, 1)

[node name="WorkshopDirector" type="Node" parent="."]
script = ExtResource("2")

[node name="Player" parent="." instance=ExtResource("4")]
position = Vector2(300, 650)

[node name="Camera2D" type="Camera2D" parent="Player"]
position = Vector2(0, -290)
position_smoothing_enabled = true
position_smoothing_speed = 5.0
limit_left = 0
limit_top = 0
limit_right = 3200
limit_bottom = 720

[node name="Props" type="Node2D" parent="."]

[node name="Notebook" type="Area2D" parent="Props"]
position = Vector2(420, 560)
collision_layer = 2
collision_mask = 0
script = ExtResource("3")
action_id = &"act00.action.notebook"
prompt_verb = "Inspect"
prompt_name = "notebook"
focus_priority = 1

[node name="CollisionShape2D" type="CollisionShape2D" parent="Props/Notebook"]
shape = SubResource("InteractShape")

[node name="Visual" type="Polygon2D" parent="Props/Notebook"]
polygon = PackedVector2Array(-58, -18, 58, -18, 48, 18, -48, 18)
color = Color(0.72, 0.69, 0.57, 1)

[node name="FocusVisual" type="Polygon2D" parent="Props/Notebook"]
visible = false
polygon = PackedVector2Array(-67, -27, 67, -27, 59, 27, -59, 27)
color = Color(0.84, 0.91, 0.78, 0.48)

[node name="Drawer" type="Area2D" parent="Props"]
position = Vector2(860, 560)
collision_layer = 2
collision_mask = 0
script = ExtResource("3")
action_id = &"act00.action.collect_guides"
prompt_verb = "Open"
prompt_name = "measuring drawer"

[node name="CollisionShape2D" type="CollisionShape2D" parent="Props/Drawer"]
shape = SubResource("InteractShape")

[node name="Visual" type="Polygon2D" parent="Props/Drawer"]
polygon = PackedVector2Array(-75, -58, 75, -58, 75, 58, -75, 58)
color = Color(0.28, 0.24, 0.2, 1)

[node name="FocusVisual" type="Polygon2D" parent="Props/Drawer"]
visible = false
polygon = PackedVector2Array(-84, -67, 84, -67, 84, 67, -84, 67)
color = Color(0.78, 0.85, 0.68, 0.38)

[node name="Clock" type="Area2D" parent="Props"]
position = Vector2(1220, 560)
collision_layer = 2
collision_mask = 0
script = ExtResource("3")
action_id = &"act00.action.clock"
prompt_verb = "Inspect"
prompt_name = "house clock"

[node name="CollisionShape2D" type="CollisionShape2D" parent="Props/Clock"]
shape = SubResource("InteractShape")

[node name="Visual" type="Polygon2D" parent="Props/Clock"]
position = Vector2(0, -310)
polygon = PackedVector2Array(-52, -66, 52, -66, 52, 66, -52, 66)
color = Color(0.2, 0.25, 0.23, 1)

[node name="FocusVisual" type="Polygon2D" parent="Props/Clock"]
visible = false
position = Vector2(0, -310)
polygon = PackedVector2Array(-61, -75, 61, -75, 61, 75, -61, 75)
color = Color(0.78, 0.85, 0.68, 0.38)

[node name="Bench" type="Area2D" parent="Props"]
position = Vector2(1600, 540)
collision_layer = 2
collision_mask = 0
script = ExtResource("3")
action_id = &"act00.action.bench"
prompt_verb = "Work at"
prompt_name = "model bench"
focus_priority = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="Props/Bench"]
shape = SubResource("InteractShape")

[node name="Visual" type="Polygon2D" parent="Props/Bench"]
polygon = PackedVector2Array(-110, -72, 110, -72, 122, 72, -122, 72)
color = Color(0.35, 0.29, 0.22, 1)

[node name="FocusVisual" type="Polygon2D" parent="Props/Bench"]
visible = false
polygon = PackedVector2Array(-122, -84, 122, -84, 134, 84, -134, 84)
color = Color(0.82, 0.88, 0.67, 0.42)

[node name="Window" type="Area2D" parent="Props"]
position = Vector2(2070, 560)
collision_layer = 2
collision_mask = 0
script = ExtResource("3")
action_id = &"act00.action.window"
prompt_verb = "Look through"
prompt_name = "window"

[node name="CollisionShape2D" type="CollisionShape2D" parent="Props/Window"]
shape = SubResource("InteractShape")

[node name="Visual" type="Polygon2D" parent="Props/Window"]
position = Vector2(0, -280)
polygon = PackedVector2Array(-100, -120, 100, -120, 100, 120, -100, 120)
color = Color(0.18, 0.32, 0.35, 1)

[node name="FocusVisual" type="Polygon2D" parent="Props/Window"]
visible = false
position = Vector2(0, -280)
polygon = PackedVector2Array(-110, -130, 110, -130, 110, 130, -110, 130)
color = Color(0.65, 0.82, 0.82, 0.34)

[node name="Prism" type="Area2D" parent="Props"]
position = Vector2(2340, 560)
collision_layer = 2
collision_mask = 0
script = ExtResource("3")
action_id = &"act00.action.collect_prism"
prompt_verb = "Take"
prompt_name = "crystalline prism"

[node name="CollisionShape2D" type="CollisionShape2D" parent="Props/Prism"]
shape = SubResource("InteractShape")

[node name="Visual" type="Polygon2D" parent="Props/Prism"]
polygon = PackedVector2Array(-42, 45, 0, -48, 42, 45)
color = Color(0.58, 0.82, 0.84, 0.9)

[node name="FocusVisual" type="Polygon2D" parent="Props/Prism"]
visible = false
polygon = PackedVector2Array(-53, 54, 0, -61, 53, 54)
color = Color(0.76, 0.96, 0.9, 0.45)

[node name="Levers" type="Area2D" parent="Props"]
position = Vector2(2730, 560)
collision_layer = 2
collision_mask = 0
script = ExtResource("3")
action_id = &"act00.action.collect_levers"
prompt_verb = "Recover"
prompt_name = "control levers"

[node name="CollisionShape2D" type="CollisionShape2D" parent="Props/Levers"]
shape = SubResource("InteractShape")

[node name="Visual" type="Polygon2D" parent="Props/Levers"]
polygon = PackedVector2Array(-68, 42, -46, -44, -18, -39, 0, 42, 18, 42, 39, -50, 66, -45, 68, 42)
color = Color(0.54, 0.52, 0.43, 1)

[node name="FocusVisual" type="Polygon2D" parent="Props/Levers"]
visible = false
polygon = PackedVector2Array(-78, 52, -56, -54, -8, -49, 10, 52, 28, 52, 49, -60, 76, -55, 78, 52)
color = Color(0.83, 0.9, 0.68, 0.4)

[node name="Apparatus" type="Area2D" parent="Props"]
position = Vector2(3060, 530)
collision_layer = 2
collision_mask = 0
script = ExtResource("3")
action_id = &"act00.action.apparatus"
prompt_verb = "Inspect"
prompt_name = "failed apparatus"

[node name="CollisionShape2D" type="CollisionShape2D" parent="Props/Apparatus"]
shape = SubResource("InteractShape")

[node name="Visual" type="Polygon2D" parent="Props/Apparatus"]
polygon = PackedVector2Array(-82, -74, 62, -74, 82, 74, -72, 74)
color = Color(0.17, 0.22, 0.21, 1)

[node name="FocusVisual" type="Polygon2D" parent="Props/Apparatus"]
visible = false
polygon = PackedVector2Array(-92, -84, 72, -84, 92, 84, -82, 84)
color = Color(0.72, 0.84, 0.68, 0.35)

[node name="GameHUD" parent="." instance=ExtResource("5")]

[node name="WorkbenchLayer" type="CanvasLayer" parent="."]
layer = 20

[node name="ModelWorkbench" parent="WorkbenchLayer" instance=ExtResource("6")]
```

- [ ] **Step 7: Replace the project entry point with chapter flow**

Replace `game/main.gd` with:

```gdscript
extends Node

@onready var _cold_open: ColdOpen = $ColdOpen
@onready var _workshop: Act00Workshop = $Workshop
@onready var _closing_card: ClosingCard = $ClosingCard

func _ready() -> void:
    get_tree().paused = false
    GameSession.reset()
    _cold_open.start_requested.connect(_start_chapter)
    _workshop.chapter_completed.connect(_finish_chapter)
    _workshop.restart_requested.connect(_restart)
    _workshop.quit_requested.connect(_quit)
    _closing_card.restart_requested.connect(_restart)
    _closing_card.quit_requested.connect(_quit)
    _workshop.set_active(false)
    _closing_card.visible = false
    _cold_open.open()

func _start_chapter() -> void:
    _workshop.set_active(true)

func _finish_chapter() -> void:
    _workshop.set_active(false)
    _closing_card.open()

func _restart() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _quit() -> void:
    get_tree().quit()
```

Replace `game/main.tscn` with:

```ini
[gd_scene load_steps=5 format=3]

[ext_resource type="Script" path="res://game/main.gd" id="1"]
[ext_resource type="PackedScene" path="res://game/act_00/workshop.tscn" id="2"]
[ext_resource type="PackedScene" path="res://game/ui/cold_open.tscn" id="3"]
[ext_resource type="PackedScene" path="res://game/ui/closing_card.tscn" id="4"]

[node name="Main" type="Node"]
script = ExtResource("1")

[node name="Workshop" parent="." instance=ExtResource("2")]
[node name="ColdOpen" parent="." instance=ExtResource("3")]
[node name="ClosingCard" parent="." instance=ExtResource("4")]
```

- [ ] **Step 8: Run import, startup, unit, and scene-flow verification**

Run:

```bash
godot --headless --path . --import
godot --headless --path . --quit-after 1
godot --headless --path . --script res://tests/run_all.gd
```

Expected: all commands exit 0; every shipped scene instantiates; the cold open, workshop, and closing-card flow assertions pass.

- [ ] **Step 9: Perform the first keyboard smoke path**

Run:

```bash
godot --path .
```

Use `Enter` to begin, arrows or `A`/`D` to traverse the full room, `E` or `Space` to inspect each object, `J` and `I` to open overlays, assemble all components with both click/drag and keyboard focus, set calibration to `0` and `+1`, and pull the lever.

Expected: the player reaches the closing card with no soft lock; the excursion is deliberately accelerated to 0.25 seconds at this task boundary and receives its final four-second treatment in Task 9.

- [ ] **Step 10: Commit the first complete semantic playthrough**

```bash
git add game/main.gd game/main.tscn game/act_00/workshop.gd game/act_00/workshop.tscn game/ui/game_hud.gd game/ui/cold_open.gd game/ui/cold_open.tscn game/ui/closing_card.gd game/ui/closing_card.tscn tests/test_scene_flow.gd tests/run_all.gd
git commit -m "feat: connect the playable Act 0 workshop flow"
```

### Task 9: Temporal Excursion, Reduced Motion, and Original Audio

**Files:**
- Create: `game/effects/temporal_effect.gd`
- Create: `game/effects/temporal_effect.gdshader`
- Create: `game/audio/act_00_audio.gd`
- Create: `tools/generate_audio.py`
- Generate: `assets/audio/act_00/ambient_workshop.wav`
- Generate: `assets/audio/act_00/paper.wav`
- Generate: `assets/audio/act_00/ivory_click.wav`
- Generate: `assets/audio/act_00/glass_chime.wav`
- Generate: `assets/audio/act_00/metal_click.wav`
- Generate: `assets/audio/act_00/misfire.wav`
- Generate: `assets/audio/act_00/departure.wav`
- Generate: `assets/audio/act_00/return.wav`
- Generate: `assets/audio/act_00/door_bell.wav`
- Create: `tests/test_temporal_audio.gd`
- Modify: `tests/run_all.gd`
- Modify: `game/workbench/model_workbench.gd`
- Modify: `game/workbench/model_workbench.tscn`
- Modify: `game/act_00/workshop.gd`
- Modify: `game/act_00/workshop.tscn`

**Interfaces:**
- Consumes: `GameHUD.reduced_motion_enabled()` and the excursion signal from `WorkshopDirector`.
- Produces: `TemporalEffect.play(target, overlay, reduced_motion, absence_seconds)`, `ModelWorkbench.play_excursion()`, `excursion_finished`, and `Act00Audio.play_event()`.

- [ ] **Step 1: Write temporal-branch and generated-audio tests**

Create `tests/test_temporal_audio.gd`:

```gdscript
extends RefCounted

const EffectScript := preload("res://game/effects/temporal_effect.gd")
const AUDIO_PATHS := [
    "res://assets/audio/act_00/ambient_workshop.wav",
    "res://assets/audio/act_00/paper.wav",
    "res://assets/audio/act_00/ivory_click.wav",
    "res://assets/audio/act_00/glass_chime.wav",
    "res://assets/audio/act_00/metal_click.wav",
    "res://assets/audio/act_00/misfire.wav",
    "res://assets/audio/act_00/departure.wav",
    "res://assets/audio/act_00/return.wav",
    "res://assets/audio/act_00/door_bell.wav",
]

func run(suite: TestSuite, tree: SceneTree) -> void:
    for path in AUDIO_PATHS:
        var stream := load(path)
        suite.expect_true(stream is AudioStreamWAV, "%s imports as WAV" % path)

    var host := Control.new()
    var target := ColorRect.new()
    var overlay := ColorRect.new()
    var material := ShaderMaterial.new()
    material.shader = load("res://game/effects/temporal_effect.gdshader")
    overlay.material = material
    var effect := EffectScript.new()
    host.add_child(target)
    host.add_child(overlay)
    host.add_child(effect)
    tree.root.add_child(host)
    await tree.process_frame

    await effect.play(target, overlay, true, 0.01)
    suite.expect_equal(effect.last_mode, "reduced", "reduced-motion branch selected")
    suite.expect_true(target.visible, "target restored after reduced excursion")
    suite.expect_true(not overlay.visible, "shader overlay unused in reduced motion")

    await effect.play(target, overlay, false, 0.01)
    suite.expect_equal(effect.last_mode, "full", "full-motion branch selected")
    suite.expect_true(target.visible, "target restored after full excursion")
    suite.expect_true(not overlay.visible, "shader overlay cleared after excursion")

    tree.root.remove_child(host)
    host.free()
```

Append this preload to `TEST_SCRIPTS` in `tests/run_all.gd`:

```gdscript
    preload("res://tests/test_temporal_audio.gd"),
```

- [ ] **Step 2: Run the temporal/audio test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: parse/load failure naming missing `temporal_effect.gd` or an audio path.

- [ ] **Step 3: Implement the excursion shader and animation controller**

Create `game/effects/temporal_effect.gdshader`:

```glsl
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 wave = vec2(
        sin(SCREEN_UV.y * 90.0 + TIME * 18.0),
        cos(SCREEN_UV.x * 55.0 - TIME * 13.0)
    ) * 0.0035 * intensity;
    vec2 split = vec2(0.006 * intensity, 0.0);
    float red = texture(screen_texture, SCREEN_UV + wave + split).r;
    float green = texture(screen_texture, SCREEN_UV + wave).g;
    float blue = texture(screen_texture, SCREEN_UV + wave - split).b;
    float alpha = smoothstep(0.0, 0.15, intensity) * 0.82;
    COLOR = vec4(red, green, blue, alpha);
}
```

Create `game/effects/temporal_effect.gd`:

```gdscript
class_name TemporalEffect
extends Node

var last_mode := ""

func play(
    target: CanvasItem,
    overlay: ColorRect,
    reduced_motion: bool,
    absence_seconds := 4.0
) -> void:
    last_mode = "reduced" if reduced_motion else "full"
    target.visible = true
    target.modulate = Color.WHITE
    overlay.visible = not reduced_motion

    if reduced_motion:
        var fade_out := create_tween()
        fade_out.tween_property(target, "modulate:a", 0.0, 0.22)
        await fade_out.finished
    else:
        var material := overlay.material as ShaderMaterial
        material.set_shader_parameter("intensity", 0.0)
        var depart := create_tween().set_parallel(true)
        depart.tween_method(
            func(value: float) -> void: material.set_shader_parameter("intensity", value),
            0.0,
            1.0,
            0.42
        )
        depart.tween_property(target, "modulate:a", 0.0, 0.42)
        await depart.finished

    target.visible = false
    await get_tree().create_timer(absence_seconds).timeout
    target.visible = true

    if reduced_motion:
        var fade_in := create_tween()
        fade_in.tween_property(target, "modulate:a", 1.0, 0.22)
        await fade_in.finished
    else:
        var material := overlay.material as ShaderMaterial
        material.set_shader_parameter("intensity", 1.0)
        var arrive := create_tween().set_parallel(true)
        arrive.tween_method(
            func(value: float) -> void: material.set_shader_parameter("intensity", value),
            1.0,
            0.0,
            0.48
        )
        arrive.tween_property(target, "modulate:a", 1.0, 0.48)
        await arrive.finished
    overlay.visible = false
    target.modulate = Color.WHITE
```

- [ ] **Step 4: Add deterministic audio synthesis and playback**

Create `tools/generate_audio.py`:

```python
#!/usr/bin/env python3
from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

RATE = 44_100
OUTPUT = Path(__file__).resolve().parents[1] / "assets/audio/act_00"


def envelope(index: int, length: int, attack: float = 0.04, release: float = 0.18) -> float:
    attack_samples = max(1, int(length * attack))
    release_samples = max(1, int(length * release))
    rise = min(1.0, index / attack_samples)
    fall = min(1.0, (length - 1 - index) / release_samples)
    return max(0.0, min(rise, fall))


def sine(frequency: float, duration: float, amplitude: float = 0.4) -> list[float]:
    length = int(RATE * duration)
    return [
        amplitude
        * envelope(i, length)
        * math.sin(2.0 * math.pi * frequency * i / RATE)
        for i in range(length)
    ]


def chirp(start: float, end: float, duration: float, amplitude: float = 0.4) -> list[float]:
    length = int(RATE * duration)
    result: list[float] = []
    phase = 0.0
    for i in range(length):
        progress = i / max(1, length - 1)
        frequency = start + (end - start) * progress
        phase += 2.0 * math.pi * frequency / RATE
        result.append(amplitude * envelope(i, length, 0.06, 0.22) * math.sin(phase))
    return result


def noise(duration: float, amplitude: float, seed: int) -> list[float]:
    rng = random.Random(seed)
    length = int(RATE * duration)
    return [
        rng.uniform(-amplitude, amplitude) * envelope(i, length, 0.02, 0.25)
        for i in range(length)
    ]


def mix(*tracks: list[float]) -> list[float]:
    length = max(len(track) for track in tracks)
    result = [0.0] * length
    for track in tracks:
        for i, value in enumerate(track):
            result[i] += value
    peak = max(1.0, max(abs(value) for value in result) / 0.92)
    return [value / peak for value in result]


def ambient() -> list[float]:
    rng = random.Random(1895)
    length = RATE * 8
    result: list[float] = []
    smooth = 0.0
    for i in range(length):
        smooth = smooth * 0.992 + rng.uniform(-1.0, 1.0) * 0.008
        value = smooth * 0.16
        tick_phase = i % RATE
        if tick_phase < 850:
            value += 0.18 * math.exp(-tick_phase / 150.0) * math.sin(
                2.0 * math.pi * 1_450.0 * tick_phase / RATE
            )
        result.append(value)
    return result


def bell() -> list[float]:
    duration = 1.8
    length = int(RATE * duration)
    frequencies = (392.0, 784.0, 1_176.0, 1_568.0)
    result: list[float] = []
    for i in range(length):
        time = i / RATE
        decay = math.exp(-2.4 * time)
        value = sum(
            math.sin(2.0 * math.pi * frequency * time) / (index + 1)
            for index, frequency in enumerate(frequencies)
        )
        result.append(0.36 * decay * value)
    return result


def write_wav(name: str, samples: list[float]) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    path = OUTPUT / name
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        frames = b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, value)) * 32_767))
            for value in samples
        )
        handle.writeframes(frames)
    print(path.relative_to(OUTPUT.parents[2]))


def main() -> None:
    write_wav("ambient_workshop.wav", ambient())
    write_wav("paper.wav", mix(noise(0.34, 0.34, 12), sine(180.0, 0.34, 0.06)))
    write_wav("ivory_click.wav", mix(sine(820.0, 0.12, 0.34), noise(0.12, 0.08, 4)))
    write_wav("glass_chime.wav", mix(sine(1_180.0, 0.48, 0.34), sine(1_765.0, 0.48, 0.18)))
    write_wav("metal_click.wav", mix(sine(410.0, 0.17, 0.32), noise(0.17, 0.14, 8)))
    write_wav("misfire.wav", mix(chirp(240.0, 72.0, 0.9, 0.42), noise(0.9, 0.13, 31)))
    write_wav("departure.wav", mix(chirp(110.0, 2_200.0, 1.8, 0.44), sine(55.0, 1.8, 0.18)))
    write_wav("return.wav", mix(chirp(2_000.0, 180.0, 1.2, 0.4), sine(660.0, 1.2, 0.16)))
    write_wav("door_bell.wav", bell())


if __name__ == "__main__":
    main()
```

Run:

```bash
python3 tools/generate_audio.py
```

Expected: nine relative WAV paths are printed under `assets/audio/act_00/`.

Create `game/audio/act_00_audio.gd`:

```gdscript
class_name Act00Audio
extends Node

var _players := {}

func _ready() -> void:
    for child in get_children():
        var player := child as AudioStreamPlayer
        if player != null:
            _players[StringName(String(player.name).to_snake_case())] = player
    var ambient_player := _players.get(&"ambient") as AudioStreamPlayer
    if ambient_player != null:
        ambient_player.finished.connect(ambient_player.play)
        ambient_player.play()

func play_event(id: StringName) -> bool:
    var player := _players.get(id) as AudioStreamPlayer
    if player == null or player.stream == null:
        push_error("Missing audio event: %s" % id)
        return false
    player.stop()
    player.play()
    return true

func stop_all() -> void:
    for player in _players.values():
        player.stop()
```

- [ ] **Step 5: Integrate the temporal effect into the workbench**

Add this signal and these node references to `game/workbench/model_workbench.gd`:

```gdscript
signal excursion_finished

@onready var _temporal_effect: TemporalEffect = $TemporalEffect
@onready var _temporal_overlay: ColorRect = $TemporalOverlay
```

Add this method to `ModelWorkbench`:

```gdscript
func play_excursion(reduced_motion: bool) -> void:
    _status.text = "For four seconds the bench is indisputably empty."
    await _temporal_effect.play(
        $Frame/Margin/Rows/Machine,
        _temporal_overlay,
        reduced_motion,
        4.0
    )
    _status.text = "The onboard chronometer has advanced fifteen seconds."
    excursion_finished.emit()
```

Change the header of `game/workbench/model_workbench.tscn` to:

```ini
[gd_scene load_steps=7 format=3]

[ext_resource type="Script" path="res://game/workbench/model_workbench.gd" id="1"]
[ext_resource type="Script" path="res://game/workbench/component_token.gd" id="2"]
[ext_resource type="Script" path="res://game/workbench/component_slot.gd" id="3"]
[ext_resource type="Script" path="res://game/effects/temporal_effect.gd" id="4"]
[ext_resource type="Shader" path="res://game/effects/temporal_effect.gdshader" id="5"]

[sub_resource type="ShaderMaterial" id="TemporalMaterial"]
shader = ExtResource("5")
```

Append these nodes to the scene after `Status`:

```ini
[node name="TemporalOverlay" type="ColorRect" parent="."]
visible = false
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
material = SubResource("TemporalMaterial")
color = Color(1, 1, 1, 1)

[node name="TemporalEffect" type="Node" parent="."]
script = ExtResource("4")
```

- [ ] **Step 6: Replace workshop wiring with timed excursion and material audio**

Replace `game/act_00/workshop.gd` with:

```gdscript
class_name Act00Workshop
extends Node2D

signal chapter_completed
signal restart_requested
signal quit_requested

@onready var _director: WorkshopDirector = $WorkshopDirector
@onready var _player: PlayerController = $Player
@onready var _hud: GameHUD = $GameHUD
@onready var _workbench: ModelWorkbench = $WorkbenchLayer/ModelWorkbench
@onready var _audio: Act00Audio = $Act00Audio

func _ready() -> void:
    _director.initialize(GameSession)
    _hud.bind(GameSession, ContentRegistry)
    _player.interaction_requested.connect(_director.handle_action)
    _player.focus_prompt_changed.connect(_hud.set_focus_prompt)
    _director.observation_requested.connect(_show_observation)
    _director.workbench_requested.connect(_open_workbench)
    _director.excursion_requested.connect(_play_excursion)
    _director.chapter_completed.connect(_finish_chapter_after_observation)
    _workbench.placement_requested.connect(_place_component)
    _workbench.calibration_changed.connect(_director.update_calibration)
    _workbench.lever_pulled.connect(_pull_lever)
    _workbench.closed.connect(_close_workbench)
    _hud.pause_changed.connect(_on_pause_changed)
    _hud.observation_dismissed.connect(_on_observation_dismissed)
    _hud.external_modal_close_requested.connect(_workbench.dismiss)
    _hud.restart_requested.connect(func() -> void: restart_requested.emit())
    _hud.quit_requested.connect(func() -> void: quit_requested.emit())

func set_active(active: bool) -> void:
    visible = active
    process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
    _hud.visible = active
    _hud.process_mode = Node.PROCESS_MODE_ALWAYS if active else Node.PROCESS_MODE_DISABLED
    if not active:
        _workbench.visible = false
        _hud.set_external_modal_open(false)
    _player.set_input_enabled(active)

func _show_observation(id: StringName) -> void:
    _player.set_input_enabled(false)
    _hud.show_observation(id)
    match id:
        &"act00.observation.notebook":
            _audio.play_event(&"paper")
        &"act00.observation.take_guides":
            _audio.play_event(&"ivory_click")
        &"act00.observation.take_prism":
            _audio.play_event(&"glass_chime")
        &"act00.observation.take_levers":
            _audio.play_event(&"metal_click")

func _on_observation_dismissed() -> void:
    if not _workbench.visible and _director.phase != WorkshopDirector.Phase.COMPLETE and not get_tree().paused:
        _player.set_input_enabled(true)

func _open_workbench() -> void:
    _player.set_input_enabled(false)
    _hud.set_external_modal_open(true)
    _workbench.open_with_items(
        GameSession.item_ids(),
        _director.placed_slots(),
        _director.spatial_alignment,
        _director.temporal_bias
    )

func _close_workbench() -> void:
    _hud.set_external_modal_open(false)
    if _director.phase != WorkshopDirector.Phase.COMPLETE:
        _player.set_input_enabled(true)

func _place_component(item_id: StringName, slot_id: StringName) -> void:
    var accepted := _director.request_place_component(item_id, slot_id)
    _workbench.apply_placement_result(item_id, slot_id, accepted)
    if not accepted:
        return
    match item_id:
        &"act00.item.ivory_guides":
            _audio.play_event(&"ivory_click")
        &"act00.item.crystal_prism":
            _audio.play_event(&"glass_chime")
        &"act00.item.control_levers":
            _audio.play_event(&"metal_click")

func _pull_lever() -> void:
    if not _director.pull_lever():
        _audio.play_event(&"misfire")
        _workbench.show_status("The model shudders, but the displacement collapses.")

func _play_excursion() -> void:
    if _hud.observation_visible():
        await _hud.observation_dismissed
    _audio.play_event(&"departure")
    await _workbench.play_excursion(_hud.reduced_motion_enabled())
    _audio.play_event(&"return")
    _director.complete_excursion()

func _finish_chapter_after_observation() -> void:
    _workbench.visible = false
    _hud.set_external_modal_open(false)
    _player.set_input_enabled(false)
    if _hud.observation_visible():
        await _hud.observation_dismissed
    _audio.play_event(&"door_bell")
    await get_tree().create_timer(1.5).timeout
    chapter_completed.emit()

func _on_pause_changed(paused: bool) -> void:
    if paused:
        _player.set_input_enabled(false)
    elif not _workbench.visible and _director.phase != WorkshopDirector.Phase.COMPLETE:
        _player.set_input_enabled(true)
```

Change the header of `game/act_00/workshop.tscn` to:

```ini
[gd_scene load_steps=19 format=3]

[ext_resource type="Script" path="res://game/act_00/workshop.gd" id="1"]
[ext_resource type="Script" path="res://game/act_00/workshop_director.gd" id="2"]
[ext_resource type="Script" path="res://game/shared/interactable.gd" id="3"]
[ext_resource type="PackedScene" path="res://game/player/player.tscn" id="4"]
[ext_resource type="PackedScene" path="res://game/ui/game_hud.tscn" id="5"]
[ext_resource type="PackedScene" path="res://game/workbench/model_workbench.tscn" id="6"]
[ext_resource type="Script" path="res://game/audio/act_00_audio.gd" id="7"]
[ext_resource type="AudioStream" path="res://assets/audio/act_00/ambient_workshop.wav" id="8"]
[ext_resource type="AudioStream" path="res://assets/audio/act_00/paper.wav" id="9"]
[ext_resource type="AudioStream" path="res://assets/audio/act_00/ivory_click.wav" id="10"]
[ext_resource type="AudioStream" path="res://assets/audio/act_00/glass_chime.wav" id="11"]
[ext_resource type="AudioStream" path="res://assets/audio/act_00/metal_click.wav" id="12"]
[ext_resource type="AudioStream" path="res://assets/audio/act_00/misfire.wav" id="13"]
[ext_resource type="AudioStream" path="res://assets/audio/act_00/departure.wav" id="14"]
[ext_resource type="AudioStream" path="res://assets/audio/act_00/return.wav" id="15"]
[ext_resource type="AudioStream" path="res://assets/audio/act_00/door_bell.wav" id="16"]

[sub_resource type="RectangleShape2D" id="FloorShape"]
size = Vector2(3200, 40)

[sub_resource type="RectangleShape2D" id="InteractShape"]
size = Vector2(150, 130)
```

Append these nodes to `workshop.tscn` after `ModelWorkbench`:

```ini
[node name="Act00Audio" type="Node" parent="."]
script = ExtResource("7")

[node name="Ambient" type="AudioStreamPlayer" parent="Act00Audio"]
stream = ExtResource("8")
volume_db = -18.0

[node name="Paper" type="AudioStreamPlayer" parent="Act00Audio"]
stream = ExtResource("9")
volume_db = -8.0

[node name="IvoryClick" type="AudioStreamPlayer" parent="Act00Audio"]
stream = ExtResource("10")
volume_db = -7.0

[node name="GlassChime" type="AudioStreamPlayer" parent="Act00Audio"]
stream = ExtResource("11")
volume_db = -8.0

[node name="MetalClick" type="AudioStreamPlayer" parent="Act00Audio"]
stream = ExtResource("12")
volume_db = -7.0

[node name="Misfire" type="AudioStreamPlayer" parent="Act00Audio"]
stream = ExtResource("13")
volume_db = -5.0

[node name="Departure" type="AudioStreamPlayer" parent="Act00Audio"]
stream = ExtResource("14")
volume_db = -4.0

[node name="Return" type="AudioStreamPlayer" parent="Act00Audio"]
stream = ExtResource("15")
volume_db = -4.0

[node name="DoorBell" type="AudioStreamPlayer" parent="Act00Audio"]
stream = ExtResource("16")
volume_db = -5.0
```

- [ ] **Step 7: Run generated-audio, temporal, import, and full-suite verification**

Run:

```bash
python3 tools/generate_audio.py
godot --headless --path . --import
godot --headless --path . --quit-after 1
godot --headless --path . --script res://tests/run_all.gd
```

Expected: nine WAV paths print; all commands exit 0; both temporal branches restore the target; all audio streams import as `AudioStreamWAV`.

- [ ] **Step 8: Play both excursion modes**

Run `godot --path .` twice. Complete the chapter once normally and once after enabling reduced motion in the pause menu.

Expected in normal mode: chromatic distortion and a pressure-wave treatment surround disappearance and return, with the model absent for four seconds. Expected in reduced mode: opacity-only departure and return, still with the same four-second information-bearing absence.

- [ ] **Step 9: Commit effects and audio**

```bash
git add game/effects game/audio game/workbench/model_workbench.gd game/workbench/model_workbench.tscn game/act_00/workshop.gd game/act_00/workshop.tscn tools/generate_audio.py assets/audio tests/test_temporal_audio.gd tests/run_all.gd
git commit -m "feat: add temporal excursion effects and original audio"
```

### Task 10: Generated Art and Coherent Visual Integration

**Files:**
- Create: `assets/art/act_00/source/.gdignore`
- Create: `assets/art/act_00/source/workshop_master.png`
- Create: `assets/art/act_00/source/time_traveller_master.png`
- Create: `assets/art/act_00/source/workbench_master.png`
- Create: `assets/art/act_00/source/model_frame_master.png`
- Create: `assets/art/act_00/source/icon_strip_master.png`
- Create: `assets/art/act_00/workshop_background.png`
- Create: `assets/art/act_00/time_traveller_strip.png`
- Create: `assets/art/act_00/workbench_background.png`
- Create: `assets/art/act_00/model_frame.png`
- Create: `assets/art/act_00/ivory_guides.png`
- Create: `assets/art/act_00/crystal_prism.png`
- Create: `assets/art/act_00/control_levers.png`
- Create: `assets/art/act_00/journal_icon.png`
- Create: `assets/art/act_00/inventory_icon.png`
- Create: `assets/art/act_00/ASSET_PROVENANCE.md`
- Create: `tests/test_art_assets.gd`
- Modify: `tests/run_all.gd`
- Modify: `tools/build_content.gd`
- Regenerate: `game/content/act_00/act_00_manifest.tres`
- Modify: `game/player/player_controller.gd`
- Modify: `game/player/player.tscn`
- Modify: `game/ui/inventory_tray.gd`
- Modify: `game/ui/game_hud.tscn`
- Modify: `game/workbench/model_workbench.tscn`
- Modify: `game/act_00/workshop.tscn`

**Interfaces:**
- Consumes: the tested 3200x720 workshop blockout and ImageGen access.
- Produces: repository-owned raster assets with exact dimensions, documented prompts, a four-frame `AnimatedSprite2D`, item/UI icons, and art-backed workshop/workbench scenes.

- [ ] **Step 1: Write exact asset-contract tests before generation**

Create `tests/test_art_assets.gd`:

```gdscript
extends RefCounted

const EXPECTED_SIZES := {
    "res://assets/art/act_00/workshop_background.png": Vector2i(3200, 720),
    "res://assets/art/act_00/time_traveller_strip.png": Vector2i(2048, 512),
    "res://assets/art/act_00/workbench_background.png": Vector2i(1280, 720),
    "res://assets/art/act_00/model_frame.png": Vector2i(1024, 300),
    "res://assets/art/act_00/ivory_guides.png": Vector2i(256, 256),
    "res://assets/art/act_00/crystal_prism.png": Vector2i(256, 256),
    "res://assets/art/act_00/control_levers.png": Vector2i(256, 256),
    "res://assets/art/act_00/journal_icon.png": Vector2i(256, 256),
    "res://assets/art/act_00/inventory_icon.png": Vector2i(256, 256),
}

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    for path in EXPECTED_SIZES:
        var texture := load(path) as Texture2D
        suite.expect_not_null(texture, "%s imports as texture" % path)
        if texture != null:
            suite.expect_equal(
                Vector2i(texture.get_width(), texture.get_height()),
                EXPECTED_SIZES[path],
                "%s dimensions" % path
            )
```

Append this preload to `TEST_SCRIPTS` in `tests/run_all.gd`:

```gdscript
    preload("res://tests/test_art_assets.gd"),
```

- [ ] **Step 2: Run the asset test and confirm the red state**

Run:

```bash
godot --headless --path . --script res://tests/run_all.gd
```

Expected: failures name each missing `res://assets/art/act_00/` texture.

- [ ] **Step 3: Generate five source plates with ImageGen**

Read and follow the current `imagegen` skill before generating. Save every returned bitmap directly under `assets/art/act_00/source/`, not under the Codex home directory.

Create `assets/art/act_00/source/.gdignore` first:

```text
# Preserve generation sources without importing them into the Godot runtime.
```

Generate `workshop_master.png` with this exact prompt:

```text
An original illustrated 1895 scientific workshop in Richmond, seen as a clean side-on theatrical cross-section for a 2D narrative adventure game. Extremely wide panoramic composition spanning three connected zones: left drafting desk with open notebook and measuring drawers, centre main bench with a small unfinished delicate experimental frame, right optical bench with an empty prism stand and a tray of incomplete rejected frames but no loose control levers. No people. No legible writing. No completed time machine. Cool blue-grey rain light through tall windows balanced by restrained warm gas lamps, ivory paper and ceramics, dark neutral iron, green oxidised copper, brass and mahogany only as accents. Readable silhouettes, uncluttered walkable floor along the bottom, modest parallax layers, animated scientific-plate aesthetic, painterly but precise, no steampunk excess, no film or television adaptation resemblance, no text, no border. Ultra-wide landscape game background.
```

Generate `time_traveller_master.png` with this exact prompt:

```text
Original unnamed late-Victorian scientist character for a 2D side-view adventure game, lean adult man in shirtsleeves and a dark waistcoat, slightly disordered from concentrated workshop labour, intelligent and impatient rather than heroic. One horizontal sprite strip containing exactly four evenly sized side-profile cells in this order: neutral standing idle, left foot forward walk, right foot forward walk, leaning to inspect a mechanism. Identical character proportions, clothing, lighting, and scale in every cell. Full body visible with generous padding, feet on one baseline, facing right, crisp illustrated scientific-plate style, readable silhouette, no resemblance to any film actor or adaptation. Flat pure chroma green #00FF00 background, no cast shadows, no labels, no extra objects.
```

Generate `workbench_master.png` with this exact prompt:

```text
Original full-screen work-surface background for assembling a small Victorian model Time Machine, viewed slightly from above on a dark neutral workbench. Show an engraved mounting plate with three unmistakably different empty mounting regions arranged left to right for twin ivory guide bars, a transparent crystalline prism, and paired control levers, but no metallic machine frame and none of the required components. Fine coordinate marks, two restrained calibration scales beneath the mounting plate, instrument cloth and precise hand tools around the edges. Cool glass highlights, ivory and oxidised green accents, selective warm lamp reflection, rigorous scientific instrument rather than ornate steampunk fantasy. No people, no hands, no text, no labels, no recognisable film design, no border, wide 16:9 composition with clear central negative space for game controls.
```

Generate `model_frame_master.png` with this exact prompt:

```text
An original delicate miniature Time Machine framework for a Victorian scientific adventure game, side-on instrument view. A fine metallic skeleton scarcely larger than a clock, with three clearly empty mounting regions arranged left to right for twin ivory guide bars, one transparent crystalline prism, and paired control levers. Precise, plausible, restrained scientific construction with thin nickel and brass members, no chair, no sled, no ornate steampunk decoration, no resemblance to any film or television Time Machine. Entire framework visible and centred with generous padding, no components installed, no people, no hands, no labels, no text, no cast shadow. Flat pure chroma green #00FF00 background, wide horizontal composition.
```

Generate `icon_strip_master.png` with this exact prompt:

```text
Five original Victorian scientific-adventure inventory icons in one horizontal strip, exactly five evenly sized cells, each object centred and fully visible in this order: twin ivory guide bars, a transparent crystalline prism, paired miniature control levers with one white lever, a closed dark-green laboratory journal, a compact dark leather instrument satchel. Consistent illustrated scientific-plate style, crisp readable silhouette, soft neutral front light, no labels, no text, no hands, no cast shadow, no overlap, no film adaptation resemblance. Flat pure chroma green #00FF00 background.
```

- [ ] **Step 4: Normalise source plates deterministically**

Run:

```bash
mkdir -p assets/art/act_00
magick assets/art/act_00/source/workshop_master.png -resize '3200x720^' -gravity center -extent 3200x720 assets/art/act_00/workshop_background.png
magick assets/art/act_00/source/time_traveller_master.png -fuzz 14% -transparent '#00FF00' -resize '2048x512!' assets/art/act_00/time_traveller_strip.png
magick assets/art/act_00/source/workbench_master.png -resize '1280x720^' -gravity center -extent 1280x720 assets/art/act_00/workbench_background.png
magick assets/art/act_00/source/model_frame_master.png -fuzz 14% -transparent '#00FF00' -resize '1024x300!' assets/art/act_00/model_frame.png
magick assets/art/act_00/source/icon_strip_master.png -fuzz 14% -transparent '#00FF00' -resize '1280x256!' /tmp/time-expedition-icons.png
magick /tmp/time-expedition-icons.png -crop 256x256+0+0 +repage assets/art/act_00/ivory_guides.png
magick /tmp/time-expedition-icons.png -crop 256x256+256+0 +repage assets/art/act_00/crystal_prism.png
magick /tmp/time-expedition-icons.png -crop 256x256+512+0 +repage assets/art/act_00/control_levers.png
magick /tmp/time-expedition-icons.png -crop 256x256+768+0 +repage assets/art/act_00/journal_icon.png
magick /tmp/time-expedition-icons.png -crop 256x256+1024+0 +repage assets/art/act_00/inventory_icon.png
identify -format '%f %wx%h %[channels]\n' assets/art/act_00/*.png
```

Expected: dimensions exactly match `EXPECTED_SIZES`; the character and five icons report an alpha channel. Visually inspect all outputs with `view_image` before integration; regenerate a source plate when object count, cell order, silhouette, or adaptation-independence is wrong rather than patching a semantically wrong image.

- [ ] **Step 5: Record exact asset provenance**

Create `assets/art/act_00/ASSET_PROVENANCE.md` with:

```markdown
# Act 0 Art Provenance

All source plates in this directory were generated for Time Expedition on 10 July 2026 with OpenAI ImageGen. The project claims no rights in H. G. Wells' public-domain concepts; these visual interpretations are original and intentionally avoid later adaptations.

## Workshop panorama

- Source: `source/workshop_master.png`
- Runtime: `workshop_background.png`
- Prompt: the exact workshop prompt recorded in Task 10 of `docs/superpowers/plans/2026-07-10-time-expedition-act-0.md`
- Transformation: ImageMagick aspect-fill resize and centre crop to 3200x720

## Time Traveller

- Source: `source/time_traveller_master.png`
- Runtime: `time_traveller_strip.png`
- Prompt: the exact Time Traveller prompt recorded in Task 10 of the implementation plan
- Transformation: 14 percent chroma-key tolerance and resize to a four-cell 2048x512 strip

## Model workbench

- Source: `source/workbench_master.png`
- Runtime: `workbench_background.png`
- Prompt: the exact workbench prompt recorded in Task 10 of the implementation plan
- Transformation: ImageMagick aspect-fill resize and centre crop to 1280x720

## Model framework

- Source: `source/model_frame_master.png`
- Runtime: `model_frame.png`
- Prompt: the exact model-framework prompt recorded in Task 10 of the implementation plan
- Transformation: 14 percent chroma-key tolerance and resize to 1024x300

## Item and UI icons

- Source: `source/icon_strip_master.png`
- Runtime: `ivory_guides.png`, `crystal_prism.png`, `control_levers.png`, `journal_icon.png`, `inventory_icon.png`
- Prompt: the exact icon-strip prompt recorded in Task 10 of the implementation plan
- Transformation: 14 percent chroma-key tolerance, resize to 1280x256, then five equal 256x256 crops
```

Append source and runtime SHA-256 values:

```bash
shasum -a 256 assets/art/act_00/source/*.png assets/art/act_00/*.png >> assets/art/act_00/ASSET_PROVENANCE.md
```

- [ ] **Step 6: Attach item icons to immutable content and inventory UI**

Add this constant near the top of `tools/build_content.gd`:

```gdscript
const ITEM_ICON_PATHS := {
    &"act00.item.ivory_guides": "res://assets/art/act_00/ivory_guides.png",
    &"act00.item.crystal_prism": "res://assets/art/act_00/crystal_prism.png",
    &"act00.item.control_levers": "res://assets/art/act_00/control_levers.png",
}
```

Add this line before `return value` in `_item()`:

```gdscript
    value.icon = load(ITEM_ICON_PATHS[id]) as Texture2D
```

In `InventoryTray.populate()`, insert this block before the title label is created:

```gdscript
        if definition.icon != null:
            var icon := TextureRect.new()
            icon.custom_minimum_size = Vector2(72, 72)
            icon.texture = definition.icon
            icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            column.add_child(icon)
```

Regenerate the manifest:

```bash
godot --headless --path . --script res://tools/build_content.gd
```

Expected: exit 0; all three `ItemDefinition.icon` fields resolve to imported textures.

- [ ] **Step 7: Replace the blocked player with a four-frame sprite**

In `game/player/player_controller.gd`, replace `_visual` with:

```gdscript
@onready var _sprite: AnimatedSprite2D = $Visual/AnimatedSprite2D
```

Add this `_ready()` method:

```gdscript
func _ready() -> void:
    _sprite.animation_finished.connect(
        func() -> void:
            if _sprite.animation == &"inspect":
                _sprite.play(&"idle")
    )
```

Replace the visual flip in `_physics_process()` and add animation selection:

```gdscript
    if not is_zero_approx(direction):
        facing = 1 if direction > 0.0 else -1
    _sprite.flip_h = facing < 0
    _update_animation(direction)
```

Add this helper:

```gdscript
func _update_animation(direction: float) -> void:
    if _sprite.animation == &"inspect" and _sprite.is_playing():
        return
    if is_zero_approx(direction):
        _sprite.play(&"idle")
    else:
        _sprite.play(&"walk")
```

Immediately before `_focused.trigger()` in `_unhandled_input()`, add:

```gdscript
        _sprite.play(&"inspect")
```

Replace `game/player/player.tscn` with:

```ini
[gd_scene load_steps=10 format=3]

[ext_resource type="Script" path="res://game/player/player_controller.gd" id="1_player"]
[ext_resource type="Texture2D" path="res://assets/art/act_00/time_traveller_strip.png" id="2_strip"]

[sub_resource type="CapsuleShape2D" id="Capsule_player"]
radius = 18.0
height = 92.0

[sub_resource type="RectangleShape2D" id="Range_shape"]
size = Vector2(220, 150)

[sub_resource type="AtlasTexture" id="IdleFrame"]
atlas = ExtResource("2_strip")
region = Rect2(0, 0, 512, 512)

[sub_resource type="AtlasTexture" id="WalkAFrame"]
atlas = ExtResource("2_strip")
region = Rect2(512, 0, 512, 512)

[sub_resource type="AtlasTexture" id="WalkBFrame"]
atlas = ExtResource("2_strip")
region = Rect2(1024, 0, 512, 512)

[sub_resource type="AtlasTexture" id="InspectFrame"]
atlas = ExtResource("2_strip")
region = Rect2(1536, 0, 512, 512)

[sub_resource type="SpriteFrames" id="TravellerFrames"]
animations = [{
"frames": [{"duration": 1.0, "texture": SubResource("IdleFrame")}],
"loop": true,
"name": &"idle",
"speed": 1.0
}, {
"frames": [{"duration": 1.0, "texture": SubResource("WalkAFrame")}, {"duration": 1.0, "texture": SubResource("WalkBFrame")}],
"loop": true,
"name": &"walk",
"speed": 6.0
}, {
"frames": [{"duration": 1.0, "texture": SubResource("InspectFrame")}],
"loop": false,
"name": &"inspect",
"speed": 2.5
}]

[node name="Player" type="CharacterBody2D"]
collision_layer = 1
collision_mask = 1
script = ExtResource("1_player")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, -46)
shape = SubResource("Capsule_player")

[node name="Visual" type="Node2D" parent="."]

[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="Visual"]
position = Vector2(0, -88)
scale = Vector2(0.34, 0.34)
sprite_frames = SubResource("TravellerFrames")
animation = &"idle"
autoplay = "idle"

[node name="InteractionRange" type="Area2D" parent="."]
position = Vector2(0, -55)
collision_layer = 0
collision_mask = 2
monitoring = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="InteractionRange"]
shape = SubResource("Range_shape")
```

- [ ] **Step 8: Integrate the workshop, workbench, and HUD plates**

In `game/act_00/workshop.tscn`, change `load_steps` to `20`, add:

```ini
[ext_resource type="Texture2D" path="res://assets/art/act_00/workshop_background.png" id="17"]
```

Insert this node immediately after `Backdrop`:

```ini
[node name="BackgroundArt" type="Sprite2D" parent="."]
texture = ExtResource("17")
centered = false
```

Set `visible = false` on the `Visual` polygon under each of `Notebook`, `Drawer`, `Clock`, `Bench`, `Window`, `Prism`, `Levers`, and `Apparatus`. Keep every `FocusVisual` active. Add these item sprites:

```ini
[node name="ItemArt" type="Sprite2D" parent="Props/Prism"]
scale = Vector2(0.28, 0.28)
texture = ExtResource("18")

[node name="ItemArt" type="Sprite2D" parent="Props/Levers"]
scale = Vector2(0.28, 0.28)
texture = ExtResource("19")
```

Add the matching texture resources and change `load_steps` to `22`:

```ini
[ext_resource type="Texture2D" path="res://assets/art/act_00/crystal_prism.png" id="18"]
[ext_resource type="Texture2D" path="res://assets/art/act_00/control_levers.png" id="19"]
```

In `Act00Workshop._show_observation()`, hide collected item art in the corresponding branches:

```gdscript
        &"act00.observation.take_prism":
            $Props/Prism/ItemArt.visible = false
            _audio.play_event(&"glass_chime")
        &"act00.observation.take_levers":
            $Props/Levers/ItemArt.visible = false
            _audio.play_event(&"metal_click")
```

In `game/workbench/model_workbench.tscn`, change `load_steps` to `12` and add:

```ini
[ext_resource type="Texture2D" path="res://assets/art/act_00/workbench_background.png" id="6"]
[ext_resource type="Texture2D" path="res://assets/art/act_00/ivory_guides.png" id="7"]
[ext_resource type="Texture2D" path="res://assets/art/act_00/crystal_prism.png" id="8"]
[ext_resource type="Texture2D" path="res://assets/art/act_00/control_levers.png" id="9"]
[ext_resource type="Texture2D" path="res://assets/art/act_00/model_frame.png" id="10"]
```

Insert this node as the first child of `Frame`, before `Margin`:

```ini
[node name="Plate" type="TextureRect" parent="Frame"]
layout_mode = 2
mouse_filter = 2
texture = ExtResource("6")
expand_mode = 1
stretch_mode = 6
modulate = Color(1, 1, 1, 0.62)
```

Insert this node as the first child of `Frame/Margin/Rows/Machine`, before `Slots`:

```ini
[node name="FrameArt" type="TextureRect" parent="Frame/Margin/Rows/Machine"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
texture = ExtResource("10")
expand_mode = 1
stretch_mode = 5
modulate = Color(1, 1, 1, 0.82)
```

Set the token button icons:

```ini
[node name="Guides" type="Button" parent="Frame/Margin/Rows/Tray"]
icon = ExtResource("7")
expand_icon = true

[node name="Prism" type="Button" parent="Frame/Margin/Rows/Tray"]
icon = ExtResource("8")
expand_icon = true

[node name="Levers" type="Button" parent="Frame/Margin/Rows/Tray"]
icon = ExtResource("9")
expand_icon = true
```

In `game/ui/game_hud.tscn`, change `load_steps` to `8`, add:

```ini
[ext_resource type="Texture2D" path="res://assets/art/act_00/journal_icon.png" id="6"]
[ext_resource type="Texture2D" path="res://assets/art/act_00/inventory_icon.png" id="7"]
```

Change the toolbar buttons to icon controls:

```ini
[node name="Journal" type="Button" parent="Toolbar/Buttons"]
custom_minimum_size = Vector2(52, 52)
layout_mode = 2
tooltip_text = "Journal (J)"
icon = ExtResource("6")
expand_icon = true

[node name="Inventory" type="Button" parent="Toolbar/Buttons"]
custom_minimum_size = Vector2(52, 52)
layout_mode = 2
tooltip_text = "Inventory (I)"
icon = ExtResource("7")
expand_icon = true
```

- [ ] **Step 9: Import assets, run tests, and visually align hit areas**

Run:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tools/build_content.gd
godot --headless --path . --script res://tests/run_all.gd
```

Expected: exit 0; all texture dimensions and scene references pass. Launch `godot --path .`, traverse the room, and compare each focus outline to the visible notebook, drawer, clock, bench, window, prism, levers, and apparatus. Adjust only the corresponding `Area2D.position` and collision-shape size until every outline encloses its rendered object and no two prompts fight at normal standing positions.

Inspect 1280x720 screenshots of the cold open, left workshop, centre bench, right workshop, workbench, normal excursion, reduced-motion excursion, journal, inventory, pause, and closing card. Regenerate source art when composition or object identity is wrong; use Godot positioning only for alignment and scale corrections.

- [ ] **Step 10: Commit the visual pass**

```bash
git add assets/art game/content/act_00/act_00_manifest.tres tools/build_content.gd game/player game/ui/inventory_tray.gd game/ui/game_hud.tscn game/workbench/model_workbench.tscn game/act_00/workshop.gd game/act_00/workshop.tscn tests/test_art_assets.gd tests/run_all.gd
git commit -m "feat: add original Act 0 art and visual integration"
```

### Task 11: Licensing, Reproducible Verification, and Playtest Evidence

**Files:**
- Create: `LICENSE`
- Create: `CONTENT_LICENSE.md`
- Create: `README.md`
- Create: `docs/sources.md`
- Create: `scripts/verify.sh`
- Create after verification: `docs/qa/act-00-playtest.md`

**Interfaces:**
- Consumes: all completed runtime, generated source recipes, and tests.
- Produces: `scripts/verify.sh` as the one-command quality gate, complete source/licence provenance, a reproducible run guide, and recorded visual/playthrough evidence.

- [ ] **Step 1: Add the code and content licences**

Create `LICENSE`:

```text
MIT License

Copyright (c) 2026 Barry W. Brook and Time Expedition contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Create `CONTENT_LICENSE.md`:

```markdown
# Content Licence

Unless a file or provenance entry says otherwise, original narrative text, raster art, and audio in Time Expedition are licensed under the [Creative Commons Attribution 4.0 International licence](https://creativecommons.org/licenses/by/4.0/).

Suggested attribution: "Time Expedition original content by Barry W. Brook and project contributors, CC BY 4.0."

Game code and tooling are separately licensed under the repository's MIT `LICENSE`.

H. G. Wells' *The Time Machine* was first published in 1895. Wells' original text and concepts used by this project are public domain; the project claims no exclusive rights in them. Source-edition details are recorded in `docs/sources.md`.

No visual, dialogue, music, character likeness, machine design, or other expressive material from a later film, television production, illustrated edition, audiobook, or game is included or authorised by this notice.

Act 0 contains no third-party runtime asset. ImageGen source prompts and transformations are recorded in `assets/art/act_00/ASSET_PROVENANCE.md`; deterministic audio recipes are committed in `tools/generate_audio.py`.
```

- [ ] **Step 2: Record literary source provenance**

Create `docs/sources.md`:

```markdown
# Literary Sources

## Work

- Title: *The Time Machine*
- Author: H. G. Wells (1866-1946)
- Original book publication: 1895
- Retrieval date for project reference sources: 10 July 2026

Wells' original text is public domain. Time Expedition uses the unnamed Time Traveller, the model-machine description, and the novel's time-travel premise. Act 0's events and prose are original pre-book material.

## Structured reference

- Edition source: [Standard Ebooks: H. G. Wells, The Time Machine](https://github.com/standardebooks/h-g-wells_the-time-machine)
- Pinned commit: [`9255fefede65b1fd3138d6a802cfd7cde431133c`](https://github.com/standardebooks/h-g-wells_the-time-machine/commit/9255fefede65b1fd3138d6a802cfd7cde431133c)
- Use: chapter structure, semantic XHTML, wording checks, and metadata

Standard Ebooks is a provenance source, not project branding. Time Expedition is not presented as a Standard Ebooks edition.

## Independent text cross-check

- Edition source: [Project Gutenberg eBook 35](https://www.gutenberg.org/ebooks/35)
- Use: independent plain-text comparison against Wells' wording

Project Gutenberg is a provenance source, not project branding. Modified game material is not presented as a Project Gutenberg edition.

## Adaptation boundary

Later films, television productions, illustrated editions, audiobooks, and games are outside the project's reference set unless a future provenance entry establishes a separate compatible licence. In particular, no later adaptation's Time Machine, Morlocks, dialogue, music, actor likenesses, or production design may be copied.
```

- [ ] **Step 3: Add the run guide**

Create `README.md`:

```markdown
# Time Expedition

Time Expedition is an open-source 2D narrative adventure built in Godot. Act 0, "The Model", is an original prologue to H. G. Wells' *The Time Machine*: the Time Traveller finishes and first tests the model machine shortly before his dinner guests arrive.

## Requirements

- Godot `4.7.stable.official.5b4e0cb0f`
- Python 3 for deterministic audio regeneration
- ImageMagick 7 only when regenerating raster derivatives

## Run

```bash
godot --path .
```

## Controls

- Move: `A`/`D` or left/right arrows
- Interact or advance: `E`, `Space`, or `Enter`
- Journal: `J`
- Inventory: `I`
- Pause and reduced-motion option: `Escape`
- Workbench: mouse drag/drop or keyboard focus and confirm

## Verify

```bash
scripts/verify.sh
```

The verification script regenerates deterministic content and audio, imports the project, checks startup, runs every headless test, and confirms generated outputs are unchanged.

## Sources and licences

- Code: MIT, see `LICENSE`
- Original narrative, art, and audio: CC BY 4.0, see `CONTENT_LICENSE.md`
- Wells and edition provenance: `docs/sources.md`
- Generated art provenance: `assets/art/act_00/ASSET_PROVENANCE.md`
```

- [ ] **Step 4: Add the one-command verification gate**

Create `scripts/verify.sh`:

```sh
#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

python3 tools/generate_audio.py
godot --headless --path . --script res://tools/build_content.gd
godot --headless --path . --import
godot --headless --path . --quit-after 1
godot --headless --path . --script res://tests/run_all.gd
git diff --exit-code -- game/content/act_00/act_00_manifest.tres assets/audio/act_00
```

Make it executable:

```bash
chmod +x scripts/verify.sh
```

- [ ] **Step 5: Run the complete verification gate from a clean process**

Run:

```bash
scripts/verify.sh
```

Expected: every command exits 0, the test runner reports no failures, and `git diff --exit-code` confirms that content and audio recipes are deterministic.

- [ ] **Step 6: Verify the three required viewport classes**

Launch and complete the chapter at each size:

```bash
godot --path . --resolution 1280x720
godot --path . --resolution 1440x900
godot --path . --resolution 1920x1080
```

At each size inspect cold open, all three workshop zones, observation band, inventory, journal, workbench, pause, normal and reduced-motion excursion, and closing card. Confirm:

- text remains inside its parent and no UI overlaps;
- focus indicators enclose the intended prop;
- the player and camera remain inside the 3200x720 room;
- workbench controls do not move as labels or values change;
- icon buttons remain square and their tooltips identify them;
- both excursion modes communicate departure, four-second absence, return, and the fifteen-versus-four-second discrepancy.

Fix any failed viewport at its owning scene, rerun `scripts/verify.sh`, and repeat all three viewport checks before recording a pass.

- [ ] **Step 7: Perform the complete authored playtest matrix**

Run these paths in a fresh session each time:

1. Notebook, all components, correct slots, wrong calibration, corrected calibration, success.
2. Components before notebook, bench before all components, close/reopen workbench after each placement, success.
3. Every component used on at least one wrong slot, repeated collection of all items, repeated lever during excursion, success.
4. Open/close inventory and journal during discovery and assembly; pause/resume in workshop and workbench; restart from pause.
5. Full success once with reduced motion enabled.

Expected: every path reaches the closing card, no item duplicates, no journal entry duplicates, no overlay traps input, and no sequence soft-locks.

- [ ] **Step 8: Record evidence only after the checks pass**

Create `docs/qa/act-00-playtest.md` with this content after Steps 5 through 7 have passed:

```markdown
# Act 0 Playtest Evidence

Date: 10 July 2026
Engine: Godot 4.7 stable
Host: Barry's Apple Silicon Mac mini

## Automated verification

- Deterministic content build: PASS
- Deterministic audio build: PASS
- Headless Godot import: PASS
- Headless project startup: PASS
- Complete GDScript test suite: PASS

## Viewports

| Viewport | Text and overlays | Camera and room | Workbench | Effects |
| --- | --- | --- | --- | --- |
| 1280x720 | PASS | PASS | PASS | PASS |
| 1440x900 | PASS | PASS | PASS | PASS |
| 1920x1080 | PASS | PASS | PASS | PASS |

## Playthroughs

- Canonical path including misfire: PASS
- Out-of-order discovery and workbench reopening: PASS
- Wrong-slot and repeated-action path: PASS
- Overlay, pause, resume, and restart path: PASS
- Reduced-motion completion path: PASS

## Residual scope

Save files, controller support, localisation, voice acting, combat, hazards, branching dialogue, web export, the dinner-party demonstration, and later time periods are intentionally outside Act 0.

Barry's end-user playtest is the next product-feedback gate after this implementation milestone.
```

- [ ] **Step 9: Run final verification, inspect the exact footprint, and commit**

Run:

```bash
scripts/verify.sh
git add LICENSE CONTENT_LICENSE.md README.md docs/sources.md docs/qa/act-00-playtest.md scripts/verify.sh
git add game assets tests tools project.godot
git diff --cached --check
git diff --cached --name-status
```

Expected: verification exits 0, the staged whitespace check prints nothing, and the staged name/status list contains only the intended documentation, verification files, and any viewport fixes made during this task.

Commit:

```bash
git commit -m "docs: complete Act 0 verification and provenance"
```

- [ ] **Step 10: Push the completed milestone and open it for end-user play**

Run:

```bash
git push origin main
godot --path .
```

Expected: `origin/main` points to the final verified commit and the cold open is visible in a local Godot game window ready for Barry's first playtest.

## Execution Strategy

Use **Subagent-Driven Development**. Barry's standing instruction to use subagents liberally resolves the normal handoff choice in favour of the recommended option: dispatch a fresh implementer for each task, then perform specification-compliance and code-quality review before accepting that task's commit. Keep tasks sequential because later scenes consume interfaces established by earlier tasks; use parallel sidecars only for independent asset, prose, or verification review.
