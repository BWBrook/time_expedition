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
    return (
        data is Dictionary
        and data.has("item_id")
        and StringName(data["item_id"]) == expected_item_id
        and filled_item_id == StringName()
    )


func _drop_data(at_position: Vector2, data: Variant) -> void:
    if not _can_drop_data(at_position, data):
        return
    drop_requested.emit(StringName(data["item_id"]), slot_id)
