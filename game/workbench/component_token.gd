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
