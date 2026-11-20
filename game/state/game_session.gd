extends Node

signal item_acquired(id: StringName)
signal journal_added(id: StringName)

var _items := {}
var _journal_entries := {}

func reset() -> void:
    _items.clear()
    _journal_entries.clear()

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
