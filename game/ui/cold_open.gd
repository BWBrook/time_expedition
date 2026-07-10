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
