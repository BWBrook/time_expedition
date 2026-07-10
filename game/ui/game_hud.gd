class_name GameHUD
extends CanvasLayer

signal restart_requested
signal quit_requested
signal pause_changed(paused: bool)
signal reduced_motion_changed(enabled: bool)
signal external_modal_close_requested
signal observation_dismissed

var _session: Node
var _registry: Node
var _reduced_motion := false
var _external_modal_open := false
var _observation_queue: Array[String] = []
@onready var _observation: ObservationBand = $ObservationBand
@onready var _inventory: InventoryTray = $InventoryTray
@onready var _journal: JournalOverlay = $JournalOverlay
@onready var _pause: PauseOverlay = $PauseOverlay
@onready var _focus_prompt: PanelContainer = $FocusPrompt
@onready var _focus_label: Label = $FocusPrompt/Label

func _ready() -> void:
    $Toolbar/Buttons/Journal.pressed.connect(open_journal)
    $Toolbar/Buttons/Inventory.pressed.connect(open_inventory)
    _observation.dismissed.connect(_advance_observation_queue)
    _pause.resume_requested.connect(resume)
    _pause.restart_requested.connect(func() -> void: restart_requested.emit())
    _pause.quit_requested.connect(func() -> void: quit_requested.emit())
    _pause.reduced_motion_changed.connect(set_reduced_motion)

func bind(session: Node, registry: Node) -> void:
    _session = session
    _registry = registry

func show_observation(id: StringName) -> void:
    if _pause.visible:
        resume()
    _inventory.close()
    _journal.close()
    var text := _resolve_observation_text(id)
    if _observation.visible:
        _observation_queue.append(text)
        return
    _observation.show_text(text)

func set_focus_prompt(text: String, is_visible: bool) -> void:
    _focus_label.text = text
    _focus_prompt.visible = is_visible

func set_external_modal_open(open: bool) -> void:
    if open:
        resume()
        _close_local_modals()
    _external_modal_open = open

func open_inventory() -> void:
    if not _has_content_binding() or _observation.visible or _pause.visible or _external_modal_open:
        return
    _journal.close()
    _inventory.populate(_session.item_ids(), _registry)
    _inventory.open()

func open_journal() -> void:
    if not _has_content_binding() or _observation.visible or _pause.visible or _external_modal_open:
        return
    _inventory.close()
    _journal.populate(_session.journal_entry_ids(), _registry)
    _journal.open()

func toggle_pause() -> void:
    if _observation.visible:
        return
    if _external_modal_open:
        external_modal_close_requested.emit()
        return
    if _pause.visible:
        resume()
        return
    _close_local_modals()
    _pause.open(_reduced_motion)
    get_tree().paused = true
    pause_changed.emit(true)

func resume() -> void:
    if not _pause.visible:
        return
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

func _has_content_binding() -> bool:
    return _session != null and _registry != null

func _close_local_modals() -> void:
    _inventory.close()
    _journal.close()

func _resolve_observation_text(id: StringName) -> String:
    if _registry == null:
        return "The observation cannot be recovered."
    var definition := _registry.get_observation(id) as ObservationDefinition
    if definition == null:
        push_error("Missing observation: %s" % id)
        return "The observation cannot be recovered."
    return definition.text

func _advance_observation_queue() -> void:
    if not _observation_queue.is_empty():
        _observation.show_text(_observation_queue.pop_front())
        return
    observation_dismissed.emit()

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
