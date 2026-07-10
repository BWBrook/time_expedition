class_name ClosingCard
extends Control

signal restart_requested
signal quit_requested


func _ready() -> void:
    $Panel/Margin/Rows/Commands/Restart.pressed.connect(
        func() -> void: restart_requested.emit()
    )
    $Panel/Margin/Rows/Commands/Quit.pressed.connect(func() -> void: quit_requested.emit())


func open() -> void:
    visible = true
    $Panel/Margin/Rows/Commands/Restart.grab_focus()
