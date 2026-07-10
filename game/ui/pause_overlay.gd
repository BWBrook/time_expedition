class_name PauseOverlay
extends ColorRect

signal resume_requested
signal restart_requested
signal quit_requested
signal reduced_motion_changed(enabled: bool)

@onready var _reduced_motion: CheckButton = $Frame/Margin/Rows/ReducedMotion

func _ready() -> void:
    $Frame/Margin/Rows/Resume.pressed.connect(func() -> void: resume_requested.emit())
    $Frame/Margin/Rows/Restart.pressed.connect(func() -> void: restart_requested.emit())
    $Frame/Margin/Rows/Quit.pressed.connect(func() -> void: quit_requested.emit())
    _reduced_motion.toggled.connect(
        func(enabled: bool) -> void: reduced_motion_changed.emit(enabled)
    )

func open(reduced_motion: bool) -> void:
    _reduced_motion.set_pressed_no_signal(reduced_motion)
    visible = true
    $Frame/Margin/Rows/Resume.grab_focus()

func close() -> void:
    visible = false

func set_reduced_motion(enabled: bool) -> void:
    _reduced_motion.set_pressed_no_signal(enabled)
