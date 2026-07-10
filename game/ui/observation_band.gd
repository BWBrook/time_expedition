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
