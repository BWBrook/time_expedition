class_name Act00Audio
extends Node

var _players := {}
var _ambient_running := false


func _ready() -> void:
    for child in get_children():
        var player := child as AudioStreamPlayer
        if player != null:
            _players[StringName(String(player.name).to_snake_case())] = player
    var ambient := _players.get(&"ambient") as AudioStreamPlayer
    if ambient != null:
        ambient.finished.connect(_on_ambient_finished)
        start_ambient()


func play_event(id: StringName) -> bool:
    var player := _players.get(id) as AudioStreamPlayer
    if player == null or player.stream == null:
        return false
    player.stop()
    player.play()
    return true


func start_ambient() -> void:
    var ambient := _players.get(&"ambient") as AudioStreamPlayer
    if ambient == null or ambient.stream == null:
        return
    _ambient_running = true
    if not ambient.playing:
        ambient.play()


func stop_all() -> void:
    _ambient_running = false
    for player in _players.values():
        player.stop()


func ambient_running() -> bool:
    return _ambient_running


func _on_ambient_finished() -> void:
    if _ambient_running:
        var ambient := _players.get(&"ambient") as AudioStreamPlayer
        if ambient != null:
            ambient.play()
