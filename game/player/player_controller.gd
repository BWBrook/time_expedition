class_name PlayerController
extends CharacterBody2D

signal interaction_requested(action_id: StringName)
signal focus_prompt_changed(text: String, visible: bool)

@export var speed := 240.0
var facing := 1
var _input_enabled := true
var _focused: Interactable
@onready var _interaction_range: Area2D = $InteractionRange
@onready var _visual: Node2D = $Visual

func _physics_process(_delta: float) -> void:
    if not _input_enabled:
        velocity = Vector2.ZERO
        return

    var direction := Input.get_axis("ui_left", "ui_right")
    if Input.is_key_pressed(KEY_A):
        direction -= 1.0
    if Input.is_key_pressed(KEY_D):
        direction += 1.0
    direction = clampf(direction, -1.0, 1.0)
    if not is_zero_approx(direction):
        facing = 1 if direction > 0.0 else -1
        _visual.scale.x = absf(_visual.scale.x) * facing
    velocity = Vector2(direction * speed, 0.0)
    move_and_slide()
    _refresh_focus()

func _unhandled_input(event: InputEvent) -> void:
    if not _input_enabled or _focused == null:
        return
    var key_event := event as InputEventKey
    var e_pressed := (
        key_event != null
        and key_event.pressed
        and not key_event.echo
        and key_event.keycode == KEY_E
    )
    if e_pressed or event.is_action_pressed("ui_accept"):
        _focused.trigger()
        interaction_requested.emit(_focused.action_id)
        get_viewport().set_input_as_handled()

func choose_focus(candidates: Array) -> Interactable:
    var best: Interactable
    var best_score := INF
    for candidate_value in candidates:
        var candidate := candidate_value as Interactable
        if candidate == null:
            continue
        var offset := candidate.global_position - global_position
        var behind := not is_zero_approx(offset.x) and signf(offset.x) != float(facing)
        var score := absf(offset.x) + absf(offset.y) * 2.0
        if behind:
            score += 500.0
        score -= float(candidate.focus_priority) * 20.0
        var scores_tie := best != null and is_equal_approx(score, best_score)
        if (
            best == null
            or (not scores_tie and score < best_score)
            or (scores_tie and String(candidate.action_id) < String(best.action_id))
        ):
            best = candidate
            best_score = score
    return best

func set_input_enabled(enabled: bool) -> void:
    _input_enabled = enabled
    if not enabled:
        velocity = Vector2.ZERO
        _set_focus(null)

func input_enabled() -> bool:
    return _input_enabled

func _refresh_focus() -> void:
    _set_focus(choose_focus(_interaction_range.get_overlapping_areas()))

func _set_focus(next_focus: Interactable) -> void:
    if _focused == next_focus:
        return
    if _focused != null:
        _focused.set_focused(false)
    _focused = next_focus
    if _focused == null:
        focus_prompt_changed.emit("", false)
        return
    _focused.set_focused(true)
    focus_prompt_changed.emit(_focused.prompt_text(), true)
