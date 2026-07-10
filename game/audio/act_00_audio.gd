class_name Act00Audio
extends Node

signal event_started(id: StringName)
signal event_finished(id: StringName)

var _players := {}
var _ambient_running := false
var _active_events := {}


func _ready() -> void:
    for child in get_children():
        var player := child as AudioStreamPlayer
        if player != null:
            var event_id := StringName(String(player.name).to_snake_case())
            _players[event_id] = player
            player.finished.connect(_on_player_finished.bind(event_id))


func play_event(id: StringName) -> bool:
    var player := _players.get(id) as AudioStreamPlayer
    if player == null or player.stream == null:
        return false
    player.stop()
    _active_events[id] = true
    player.play()
    event_started.emit(id)
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
    _active_events.clear()
    for player in _players.values():
        player.stop()


func ambient_running() -> bool:
    return _ambient_running


func event_active(id: StringName) -> bool:
    return _active_events.has(id)


func active_event_count() -> int:
    return _active_events.size()


func event_duration(id: StringName) -> float:
    var player := _players.get(id) as AudioStreamPlayer
    if player == null or player.stream == null:
        return 0.0
    return player.stream.get_length()


func _exit_tree() -> void:
    stop_all()


func _on_player_finished(id: StringName) -> void:
    if id == &"ambient":
        if _ambient_running:
            var ambient := _players.get(&"ambient") as AudioStreamPlayer
            if ambient != null:
                ambient.play()
        return
    _active_events.erase(id)
    event_finished.emit(id)
