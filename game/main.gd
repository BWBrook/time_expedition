extends Node

@onready var _cold_open: ColdOpen = $ColdOpen
@onready var _workshop: Act00Workshop = $Workshop
@onready var _closing_card: ClosingCard = $ClosingCard


func _ready() -> void:
    get_tree().paused = false
    get_node("/root/GameSession").reset()
    _cold_open.start_requested.connect(_start_chapter)
    _workshop.chapter_completed.connect(_finish_chapter)
    _workshop.restart_requested.connect(_restart)
    _workshop.quit_requested.connect(_quit)
    _closing_card.restart_requested.connect(_restart)
    _closing_card.quit_requested.connect(_quit)
    _workshop.set_active(false)
    _closing_card.visible = false
    _cold_open.open()


func _start_chapter() -> void:
    _workshop.set_active(true)


func _finish_chapter() -> void:
    _workshop.set_active(false)
    _closing_card.open()


func _restart() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()


func _quit() -> void:
    get_tree().quit()
