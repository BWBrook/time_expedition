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
