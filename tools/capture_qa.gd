extends SceneTree

const MainScene := preload("res://game/main.tscn")
const GUIDES := &"act00.item.ivory_guides"
const PRISM := &"act00.item.crystal_prism"
const LEVERS := &"act00.item.control_levers"
const GUIDES_SLOT := &"act00.slot.ivory_guides"
const PRISM_SLOT := &"act00.slot.crystal_prism"
const LEVERS_SLOT := &"act00.slot.control_levers"
const CANONICALIZE_PATHS_PYTHON := """
import json
import pathlib
import sys

repository = pathlib.Path(sys.argv[1]).resolve()
output = pathlib.Path(sys.argv[2]).resolve()
print(json.dumps([str(repository), str(output)]))
"""

var _output_dir := ""
var _capture_index := 0
var _requested_size := Vector2i.ZERO


func _initialize() -> void:
    var config := _parse_args(OS.get_cmdline_user_args())
    if config.is_empty():
        quit(1)
        return
    _output_dir = config["output"]
    _requested_size = config["viewport"]
    root.size = _requested_size
    root.min_size = _requested_size

    if not _prepare_output_dir():
        quit(1)
        return
    print(
        "QA framebuffer %s expects fitted 16:9 content %s"
        % [_requested_size, expected_fitted_content_size(_requested_size)]
    )

    var main := await _instantiate_main()
    main.get_node("ColdOpen").open()
    await _settle(3)
    await _capture("cold_open")
    await _begin_main(main)
    await _capture_workshop_states(main)
    await _capture_interface_states(main)
    await _capture_temporal_and_closing(main, false, "temporal_normal")
    await _teardown_main(main)

    var reduced_main := await _instantiate_main()
    await _begin_main(reduced_main)
    await _prepare_assembled_workbench(reduced_main)
    var reduced_workshop := reduced_main.get_node("Workshop") as Act00Workshop
    var reduced_hud := reduced_workshop.get_node("GameHUD") as GameHUD
    reduced_hud.set_reduced_motion(true)
    await _capture_temporal_and_closing(reduced_main, true, "temporal_reduced")
    await _teardown_main(reduced_main)
    print("CAPTURED %d QA frames in %s" % [_capture_index, _output_dir])
    quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
    var viewport_text := ""
    var output := ""
    for arg in args:
        if arg.begins_with("--viewport="):
            viewport_text = arg.trim_prefix("--viewport=")
        elif arg.begins_with("--output="):
            output = arg.trim_prefix("--output=")
    var parts := viewport_text.split("x", false)
    if parts.size() != 2 or not output.is_absolute_path():
        push_error("Usage: --viewport=WIDTHxHEIGHT --output=/absolute/path/outside/repository")
        return {}
    var viewport := Vector2i(parts[0].to_int(), parts[1].to_int())
    if viewport.x <= 0 or viewport.y <= 0:
        push_error("Viewport dimensions must be positive")
        return {}
    return {"viewport": viewport, "output": output.simplify_path()}


static func expected_fitted_content_size(requested: Vector2i) -> Vector2i:
    if requested.x * 9 <= requested.y * 16:
        return Vector2i(requested.x, roundi(float(requested.x) * 9.0 / 16.0))
    return Vector2i(roundi(float(requested.y) * 16.0 / 9.0), requested.y)


static func compose_requested_frame(content: Image, requested: Vector2i) -> Image:
    var framebuffer := Image.create_empty(requested.x, requested.y, false, Image.FORMAT_RGBA8)
    framebuffer.fill(Color.BLACK)
    var remaining := requested - content.get_size()
    var offset := Vector2i(floori(float(remaining.x) * 0.5), floori(float(remaining.y) * 0.5))
    framebuffer.blit_rect(content, Rect2i(Vector2i.ZERO, content.get_size()), offset)
    return framebuffer


static func canonical_capture_output(repository: String, output: String) -> String:
    var command_output: Array = []
    var exit_code := OS.execute(
        "python3",
        PackedStringArray(["-c", CANONICALIZE_PATHS_PYTHON, repository, output]),
        command_output,
        true
    )
    if exit_code != 0 or command_output.size() != 1:
        return ""

    var parsed: Variant = JSON.parse_string(String(command_output[0]).strip_edges())
    if typeof(parsed) != TYPE_ARRAY:
        return ""
    var paths: Array = parsed
    if paths.size() != 2 or typeof(paths[0]) != TYPE_STRING or typeof(paths[1]) != TYPE_STRING:
        return ""

    var canonical_repository := String(paths[0])
    var canonical_output := String(paths[1])
    if not canonical_repository.is_absolute_path() or not canonical_output.is_absolute_path():
        return ""
    var repository_prefix := canonical_repository.trim_suffix("/") + "/"
    if canonical_output == canonical_repository or canonical_output.begins_with(repository_prefix):
        return ""
    return canonical_output


func _prepare_output_dir() -> bool:
    var repository := ProjectSettings.globalize_path("res://")
    var canonical_output := canonical_capture_output(repository, _output_dir)
    if canonical_output.is_empty():
        push_error("QA output must resolve outside the repository: %s" % _output_dir)
        return false
    _output_dir = canonical_output
    var error := DirAccess.make_dir_recursive_absolute(_output_dir)
    if error != OK:
        push_error("Unable to create QA output directory: %s" % error_string(error))
        return false
    return true


func _instantiate_main() -> Node:
    var main := MainScene.instantiate()
    root.add_child(main)
    await process_frame
    return main


func _begin_main(main: Node) -> void:
    main.get_node("ColdOpen").begin()
    await process_frame


func _capture_workshop_states(main: Node) -> void:
    var workshop := main.get_node("Workshop") as Act00Workshop
    var player := workshop.get_node("Player") as PlayerController
    var camera := player.get_node("Camera2D") as Camera2D
    camera.position_smoothing_enabled = false
    var room_states := {
        "room_left": 320.0,
        "room_centre": 1600.0,
        "room_right": 2900.0,
    }
    for room_state in room_states:
        player.global_position.x = room_states[room_state]
        await _snap_camera(camera)
        await _capture(room_state)

    var focus_states := {
        "focus_left": "Props/Notebook",
        "focus_centre": "Props/Bench",
        "focus_right": "Props/Apparatus",
    }
    for focus_state in focus_states:
        var target := workshop.get_node(focus_states[focus_state]) as Interactable
        player.global_position = target.global_position + Vector2(0, 90)
        await _snap_camera(camera)
        _assert_in_viewport(camera, player.global_position, "%s player" % focus_state)
        _assert_in_viewport(camera, target.global_position, "%s target" % focus_state)
        await _capture(focus_state)


func _capture_interface_states(main: Node) -> void:
    var workshop := main.get_node("Workshop") as Act00Workshop
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var hud := workshop.get_node("GameHUD") as GameHUD
    director.handle_action(&"act00.action.notebook")
    await _settle(2)
    await _capture("observation")
    await _dismiss_observations(hud)
    director.handle_action(&"act00.action.collect_guides")
    await _dismiss_observations(hud)
    hud.open_inventory()
    await _settle(2)
    await _capture("inventory")
    hud._unhandled_input(_key_event(KEY_ESCAPE))
    hud.open_journal()
    await _settle(2)
    await _capture("journal")
    hud._unhandled_input(_key_event(KEY_ESCAPE))
    director.handle_action(&"act00.action.collect_prism")
    await _dismiss_observations(hud)
    director.handle_action(&"act00.action.collect_levers")
    await _dismiss_observations(hud)
    director.handle_action(&"act00.action.bench")
    await _dismiss_observations(hud)
    await _settle(2)
    await _capture("workbench")
    hud.set_external_modal_pause_allowed(true)
    hud.toggle_pause()
    await _settle(2)
    await _capture("pause")
    hud.resume()


func _prepare_assembled_workbench(main: Node) -> void:
    var workshop := main.get_node("Workshop") as Act00Workshop
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var hud := workshop.get_node("GameHUD") as GameHUD
    director.handle_action(&"act00.action.notebook")
    await _dismiss_observations(hud)
    for action_id in [&"act00.action.collect_guides", &"act00.action.collect_prism", &"act00.action.collect_levers"]:
        director.handle_action(action_id)
        await _dismiss_observations(hud)
    director.handle_action(&"act00.action.bench")
    await _dismiss_observations(hud)
    var workbench := workshop.get_node("WorkbenchLayer/ModelWorkbench") as ModelWorkbench
    for pair in [[GUIDES, GUIDES_SLOT], [PRISM, PRISM_SLOT], [LEVERS, LEVERS_SLOT]]:
        workbench.select_item(pair[0])
        workbench.request_slot(pair[1])
        await _dismiss_observations(hud)


func _capture_temporal_and_closing(main: Node, reduced_motion: bool, label: String) -> void:
    var workshop := main.get_node("Workshop") as Act00Workshop
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var hud := workshop.get_node("GameHUD") as GameHUD
    var workbench := workshop.get_node("WorkbenchLayer/ModelWorkbench") as ModelWorkbench
    if director.phase != WorkshopDirector.Phase.CALIBRATION:
        await _prepare_assembled_workbench(main)
    workbench.set_calibration(0, 1)
    workbench.request_lever()
    await _dismiss_observations(hud)
    await _wait_until(func() -> bool: return not workbench.excursion_target_visible(), 2000)
    await _settle(2)
    await _capture(label)
    await _wait_until(func() -> bool: return director.phase == WorkshopDirector.Phase.COMPLETE, 7000)
    await _dismiss_observations(hud)
    await _wait_until(func() -> bool: return main.get_node("ClosingLayer/ClosingCard").visible, 3000)
    if not reduced_motion:
        await _settle(2)
        await _capture("closing_card")


func _capture(label: String) -> void:
    await RenderingServer.frame_post_draw
    await RenderingServer.frame_post_draw
    _capture_index += 1
    var path := _output_dir.path_join("%02d_%s.png" % [_capture_index, label])
    var content := root.get_texture().get_image()
    var expected_content_size := expected_fitted_content_size(_requested_size)
    if content.get_size() != expected_content_size:
        push_error(
            "Unexpected QA content texture for %s: got %s, expected %s for %s"
            % [label, content.get_size(), expected_content_size, _requested_size]
        )
        quit(1)
        return
    if not _has_visible_capture_content(content, label):
        quit(1)
        return
    var image := compose_requested_frame(content, _requested_size)
    if image.get_size() != _requested_size:
        push_error(
            "QA framebuffer size mismatch for %s: got %s, expected %s"
            % [label, image.get_size(), _requested_size]
        )
        quit(1)
        return
    var error := image.save_png(path)
    if error != OK:
        push_error("Unable to save QA capture %s: %s" % [label, error_string(error)])
        quit(1)
        return
    var saved := Image.new()
    error = saved.load(path)
    if error != OK or saved.get_size() != _requested_size:
        push_error(
            "Saved QA capture size mismatch for %s: got %s, expected %s (%s)"
            % [label, saved.get_size(), _requested_size, error_string(error)]
        )
        quit(1)
        return
    print(path)


func _has_visible_capture_content(image: Image, label: String) -> bool:
    var sample_step := Vector2i(maxi(1, image.get_width() / 64), maxi(1, image.get_height() / 36))
    var darkest := 1.0
    var brightest := 0.0
    for y in range(0, image.get_height(), sample_step.y):
        for x in range(0, image.get_width(), sample_step.x):
            var luminance := image.get_pixel(x, y).get_luminance()
            darkest = minf(darkest, luminance)
            brightest = maxf(brightest, luminance)
    if brightest - darkest < 0.08:
        push_error("QA capture is visually flat: %s" % label)
        return false
    if label == "closing_card" and image.get_pixel(0, 0).get_luminance() > 0.1:
        push_error("Closing-card capture is missing its dark background")
        return false
    return true


func _dismiss_observations(hud: GameHUD) -> void:
    while hud.observation_visible():
        hud._unhandled_input(_key_event(KEY_ESCAPE))
        await process_frame


func _wait_until(condition: Callable, timeout_ms: int) -> bool:
    var deadline := Time.get_ticks_msec() + timeout_ms
    while not condition.call() and Time.get_ticks_msec() < deadline:
        await process_frame
    if not condition.call():
        push_error("Timed out while preparing QA capture")
        quit(1)
        return false
    return true


func _settle(frames: int) -> void:
    for _frame in frames:
        await process_frame


func _snap_camera(camera: Camera2D) -> void:
    camera.reset_smoothing()
    camera.force_update_scroll()
    await physics_frame
    await process_frame
    camera.force_update_scroll()
    await process_frame


func _assert_in_viewport(camera: Camera2D, world_position: Vector2, label: String) -> void:
    var viewport_rect := Rect2(
        camera.get_screen_center_position() - Vector2(root.size) * 0.5,
        Vector2(root.size)
    ).grow(32.0)
    if not viewport_rect.has_point(world_position):
        push_error("QA capture target is off-screen: %s at %s" % [label, world_position])
        quit(1)


func _teardown_main(main: Node) -> void:
    var audio := main.get_node_or_null("Workshop/Act00Audio") as Act00Audio
    if audio != null:
        audio.stop_all()
    paused = false
    root.remove_child(main)
    main.free()
    await _settle(10)
    await RenderingServer.frame_post_draw


func _key_event(keycode: Key) -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = keycode
    event.pressed = true
    return event
