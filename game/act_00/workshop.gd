class_name Act00Workshop
extends Node2D

signal chapter_completed
signal restart_requested
signal quit_requested

@onready var _director: WorkshopDirector = $WorkshopDirector
@onready var _player: PlayerController = $Player
@onready var _hud: GameHUD = $GameHUD
@onready var _workbench: ModelWorkbench = $WorkbenchLayer/ModelWorkbench


func _ready() -> void:
    _director.initialize(_session())
    _hud.bind(_session(), _registry())
    _player.interaction_requested.connect(_director.handle_action)
    _player.focus_prompt_changed.connect(_hud.set_focus_prompt)
    _director.observation_requested.connect(_show_observation)
    _director.workbench_requested.connect(_open_workbench)
    _director.excursion_requested.connect(_play_accelerated_excursion)
    _director.chapter_completed.connect(_finish_chapter_after_observation)
    _workbench.placement_requested.connect(_place_component)
    _workbench.calibration_changed.connect(_director.update_calibration)
    _workbench.lever_pulled.connect(_pull_lever)
    _workbench.closed.connect(_close_workbench)
    _hud.pause_changed.connect(_on_pause_changed)
    _hud.observation_dismissed.connect(_on_observation_dismissed)
    _hud.external_modal_close_requested.connect(_workbench.dismiss)
    _hud.restart_requested.connect(func() -> void: restart_requested.emit())
    _hud.quit_requested.connect(func() -> void: quit_requested.emit())


func set_active(active: bool) -> void:
    visible = active
    process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
    _hud.visible = active
    _hud.process_mode = Node.PROCESS_MODE_ALWAYS if active else Node.PROCESS_MODE_DISABLED
    if not active:
        _workbench.visible = false
        _hud.set_external_modal_open(false)
    _player.set_input_enabled(active)


func _show_observation(id: StringName) -> void:
    _player.set_input_enabled(false)
    _hud.show_observation(id)


func _on_observation_dismissed() -> void:
    if not _workbench.visible and _director.phase != WorkshopDirector.Phase.COMPLETE and not get_tree().paused:
        _player.set_input_enabled(true)


func _open_workbench() -> void:
    _player.set_input_enabled(false)
    _hud.set_external_modal_open(true)
    _workbench.open_with_items(
        _session().item_ids(),
        _director.placed_slots(),
        _director.spatial_alignment,
        _director.temporal_bias
    )


func _close_workbench() -> void:
    _hud.set_external_modal_open(false)
    if _director.phase != WorkshopDirector.Phase.COMPLETE:
        _player.set_input_enabled(true)


func _place_component(item_id: StringName, slot_id: StringName) -> void:
    var accepted := _director.request_place_component(item_id, slot_id)
    _workbench.apply_placement_result(item_id, slot_id, accepted)


func _pull_lever() -> void:
    if not _director.pull_lever():
        _workbench.show_status("The model shudders, but the displacement collapses.")


func _play_accelerated_excursion() -> void:
    if _hud.observation_visible():
        await _hud.observation_dismissed
    _workbench.show_status("The model leaves the present.")
    await get_tree().create_timer(0.25).timeout
    if is_inside_tree():
        _director.complete_excursion()


func _finish_chapter_after_observation() -> void:
    _workbench.visible = false
    _hud.set_external_modal_open(false)
    _player.set_input_enabled(false)
    if _hud.observation_visible():
        await _hud.observation_dismissed
    chapter_completed.emit()


func _on_pause_changed(paused: bool) -> void:
    if paused:
        _player.set_input_enabled(false)
    elif not _workbench.visible and _director.phase != WorkshopDirector.Phase.COMPLETE:
        _player.set_input_enabled(true)


func _session() -> Node:
    return get_node("/root/GameSession")


func _registry() -> Node:
    return get_node("/root/ContentRegistry")
