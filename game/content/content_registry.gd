extends Node

const DEFAULT_MANIFEST := preload("res://game/content/act_00/act_00_manifest.tres")
const REQUIRED_ITEM_IDS := [
    &"act00.item.ivory_guides",
    &"act00.item.crystal_prism",
    &"act00.item.control_levers",
]
const REQUIRED_JOURNAL_IDS := [
    &"act00.journal.experiment",
    &"act00.journal.components",
    &"act00.journal.calibration",
    &"act00.journal.misfire",
    &"act00.journal.success",
]
const REQUIRED_OBSERVATION_IDS := [
    &"act00.observation.notebook",
    &"act00.observation.take_guides",
    &"act00.observation.guides_taken",
    &"act00.observation.take_prism",
    &"act00.observation.prism_taken",
    &"act00.observation.take_levers",
    &"act00.observation.levers_taken",
    &"act00.observation.bench_missing",
    &"act00.observation.bench_ready",
    &"act00.observation.wrong_slot",
    &"act00.observation.component_fitted",
    &"act00.observation.assembly_complete",
    &"act00.observation.misfire",
    &"act00.observation.excursion",
    &"act00.observation.return",
    &"act00.observation.clock",
    &"act00.observation.window",
    &"act00.observation.apparatus",
]

var _items := {}
var _journal_entries := {}
var _observations := {}

func _ready() -> void:
    var errors := load_default_manifest()
    for message in errors:
        push_error(message)
    if not errors.is_empty():
        get_tree().quit(1)

func load_manifest(manifest: ActManifest) -> PackedStringArray:
    var errors := _validate_manifest(manifest)
    if not errors.is_empty():
        return errors

    _store_manifest(manifest)
    return PackedStringArray()


func load_default_manifest(manifest: ActManifest = DEFAULT_MANIFEST) -> PackedStringArray:
    var errors := _validate_manifest(manifest)
    if errors.is_empty():
        errors.append_array(_validate_act_00_contract(manifest))
    if not errors.is_empty():
        return errors

    _store_manifest(manifest)
    return PackedStringArray()


func _store_manifest(manifest: ActManifest) -> void:

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


func _validate_act_00_contract(manifest: ActManifest) -> PackedStringArray:
    var errors := PackedStringArray()
    if manifest.act_id != &"act00":
        errors.append("Act 0 manifest has the wrong act ID: %s" % manifest.act_id)
    if manifest.title.strip_edges().is_empty():
        errors.append("Act 0 manifest has a blank title")

    var items := {}
    for item in manifest.items:
        if item != null:
            items[item.id] = item
    var journals := {}
    for entry in manifest.journal_entries:
        if entry != null:
            journals[entry.id] = entry
    var observations := {}
    for observation in manifest.observations:
        if observation != null:
            observations[observation.id] = observation

    for id in REQUIRED_ITEM_IDS:
        if not items.has(id):
            errors.append("Act 0 manifest is missing required item ID: %s" % id)
            continue
        var item := items[id] as ItemDefinition
        if item.display_name.strip_edges().is_empty():
            errors.append("Act 0 item %s has a blank display name" % id)
        if item.description.strip_edges().is_empty():
            errors.append("Act 0 item %s has a blank description" % id)
        if item.icon == null:
            errors.append("Act 0 item %s has no icon" % id)

    for id in REQUIRED_JOURNAL_IDS:
        if not journals.has(id):
            errors.append("Act 0 manifest is missing required journal ID: %s" % id)
            continue
        var entry := journals[id] as JournalEntryDefinition
        if entry.title.strip_edges().is_empty():
            errors.append("Act 0 journal %s has a blank title" % id)
        if entry.body.strip_edges().is_empty():
            errors.append("Act 0 journal %s has a blank body" % id)

    for id in REQUIRED_OBSERVATION_IDS:
        if not observations.has(id):
            errors.append("Act 0 manifest is missing required observation ID: %s" % id)
            continue
        var observation := observations[id] as ObservationDefinition
        if observation.text.strip_edges().is_empty():
            errors.append("Act 0 observation %s has blank text" % id)
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
