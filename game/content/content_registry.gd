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
