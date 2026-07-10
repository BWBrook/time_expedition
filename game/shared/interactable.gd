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
