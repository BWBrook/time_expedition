extends RefCounted

const EffectScript := preload("res://game/effects/temporal_effect.gd")
const AudioScript := preload("res://game/audio/act_00_audio.gd")
const AUDIO := {
    "ambient_workshop.wav": {"hash": "0768482b205ed189e927bfe5b659eabc7796d93e2e63ad9a0d5419ae00a44285", "samples": 352800},
    "paper.wav": {"hash": "03e2b4a62b10d531123914db5f6227b1f04cc241092f6673534bcb6fe5afbc6f", "samples": 14994},
    "ivory_click.wav": {"hash": "96bf52b5bd957ef947618c96f04692e2f5d808e706e728a1fa1e621ce7897310", "samples": 5292},
    "glass_chime.wav": {"hash": "97340b2c9874a6e946365bdba45d3694a5a52efdce1f4470cf20731f295e0e89", "samples": 21168},
    "metal_click.wav": {"hash": "cb7574fea6754540618f975205cbeb2f71de73b0e0e5b32b18ae3cce7a024492", "samples": 7497},
    "misfire.wav": {"hash": "8d183ee04657d48b43b9a1bf36576134c4a5721fb84ff12cdbec9e363badb8a5", "samples": 39690},
    "departure.wav": {"hash": "b115d28905fc45fb006e0c07c65ea3f93fbff9f6f1baac99812ad3aec866c09d", "samples": 79380},
    "return.wav": {"hash": "a094bc4dc6ebb9e53b2a5e78af91afbb8bc33fd236b4e5d4cadeca522389745b", "samples": 52920},
    "clock_strike.wav": {"hash": "a102b8a8406bc9fbb40541203c38073c26a2dc4ce13820f88cbe5ecdaa1799a4", "samples": 97020},
    "door_bell.wav": {"hash": "d4b3b330b1badda3964497dd8731559b33c9fb00c40bf3ee074b032ad765847c", "samples": 79380},
}


func run(suite: TestSuite, tree: SceneTree) -> void:
    for name: String in AUDIO:
        var path := "res://assets/audio/act_00/%s" % name
        var exists := FileAccess.file_exists(path)
        suite.expect_true(exists, "%s exists" % path)
        if not exists:
            continue
        var stream := load(path)
        var metadata := _wav_metadata(path)
        suite.expect_true(
            FileAccess.file_exists(path + ".import"),
            "%s has committed import metadata" % path
        )
        suite.expect_true(stream is AudioStreamWAV, "%s imports as WAV" % path)
        if stream is AudioStreamWAV:
            suite.expect_true(
                absf(stream.get_length() - float(AUDIO[name]["samples"]) / 44100.0) < 0.001,
                "%s has authored duration" % name
            )
        suite.expect_equal(metadata["channels"], 1, "%s is mono" % name)
        suite.expect_equal(metadata["sample_rate"], 44100, "%s has 44.1 kHz sample rate" % name)
        suite.expect_equal(metadata["bits_per_sample"], 16, "%s is 16-bit" % name)
        suite.expect_equal(_sha256(path), AUDIO[name]["hash"], "%s has deterministic bytes" % name)

    var host := Control.new()
    var target := ColorRect.new()
    var overlay := ColorRect.new()
    var material := ShaderMaterial.new()
    material.shader = load("res://game/effects/temporal_effect.gdshader")
    overlay.material = material
    var effect := EffectScript.new()
    host.add_child(target)
    host.add_child(overlay)
    host.add_child(effect)
    tree.root.add_child(host)
    await tree.process_frame

    await effect.play(target, overlay, true, 0.01)
    suite.expect_equal(effect.last_mode, "reduced", "reduced-motion branch selected")
    suite.expect_true(target.visible, "target restored after reduced excursion")
    suite.expect_equal(target.modulate, Color.WHITE, "reduced excursion restores target modulate")
    suite.expect_true(not overlay.visible, "shader overlay unused in reduced motion")

    await effect.play(target, overlay, false, 0.01)
    suite.expect_equal(effect.last_mode, "full", "full-motion branch selected")
    suite.expect_true(target.visible, "target restored after full excursion")
    suite.expect_equal(target.modulate, Color.WHITE, "full excursion restores target modulate")
    suite.expect_true(not overlay.visible, "shader overlay cleared after excursion")
    suite.expect_equal(
        material.get_shader_parameter("intensity"),
        0.0,
        "full excursion resets shader intensity"
    )
    suite.expect_equal(overlay.material, null, "full excursion releases the screen-texture overlay")

    var absence_count: Array[int] = [0]
    var completion_count: Array[int] = [0]
    var full_stages: Array[String] = []
    var return_count: Array[int] = [0]
    var absence_listener: Callable = func() -> void: absence_count[0] += 1
    var completion_listener: Callable = func() -> void: completion_count[0] += 1
    effect.absence_started.connect(absence_listener)
    effect.excursion_finished.connect(completion_listener)
    suite.expect_true(effect.has_signal("stage_changed"), "temporal effect exposes semantic stages")
    suite.expect_true(effect.has_signal("return_started"), "temporal effect exposes return start")
    if effect.has_signal("stage_changed"):
        effect.connect("stage_changed", func(stage: StringName) -> void: full_stages.append(String(stage)))
    if effect.has_signal("return_started"):
        effect.connect("return_started", func() -> void: return_count[0] += 1)
    effect.call_deferred("play", target, overlay, false, 0.08)
    await tree.process_frame
    await tree.create_timer(0.16, true).timeout
    var departure_alpha := target.modulate.a
    tree.paused = true
    await tree.create_timer(0.55, true).timeout
    suite.expect_true(
        absf(target.modulate.a - departure_alpha) < 0.001,
        "process-always timer cannot advance paused departure"
    )
    suite.expect_equal(absence_count[0], 0, "paused departure cannot enter absence")
    suite.expect_equal(completion_count[0], 0, "paused departure cannot complete")
    tree.paused = false
    var resumed_absence := await _wait_until(
        tree,
        func() -> bool: return absence_count[0] > 0,
        1000
    )
    suite.expect_true(resumed_absence, "resumed departure enters short absence before timeout")
    if resumed_absence:
        suite.expect_true(target.visible, "absence preserves the target's layout allocation")
        suite.expect_equal(target.modulate.a, 0.0, "absence makes the target fully transparent")
        suite.expect_true(not overlay.visible, "full shader overlay is hidden during clear absence")
        suite.expect_equal(
            material.get_shader_parameter("intensity"),
            0.0,
            "full shader intensity is reset during clear absence"
        )
        tree.paused = true
        await tree.create_timer(0.24, true).timeout
        suite.expect_true(
            target.visible and is_zero_approx(target.modulate.a),
            "process-always timer cannot advance paused absence"
        )
        suite.expect_equal(completion_count[0], 0, "paused absence cannot complete")
        tree.paused = false
    var resumed_completion := await _wait_until(
        tree,
        func() -> bool: return completion_count[0] > 0,
        1000
    )
    suite.expect_true(resumed_completion, "resumed short excursion completes before timeout")
    if resumed_completion:
        suite.expect_true(target.visible, "resumed short excursion restores target")
    suite.expect_equal(return_count[0], 1, "full excursion emits return start once")
    suite.expect_equal(
        full_stages,
        ["departure", "absence", "return", "returned"],
        "full excursion stage order"
    )

    var reduced_completion: Array[int] = [0]
    var reduced_stages: Array[String] = []
    var reduced_listener: Callable = func() -> void: reduced_completion[0] += 1
    effect.excursion_finished.connect(reduced_listener)
    if effect.has_signal("stage_changed"):
        effect.connect("stage_changed", func(stage: StringName) -> void: reduced_stages.append(String(stage)))
    effect.call_deferred("play", target, overlay, true, 0.08)
    await tree.process_frame
    await tree.create_timer(0.10, true).timeout
    var reduced_alpha := target.modulate.a
    suite.expect_true(target.modulate.r < 1.0, "reduced departure applies restrained light tint")
    suite.expect_equal(target.modulate.b, 1.0, "reduced tint preserves cool light channel")
    suite.expect_true(not overlay.visible, "reduced departure does not enable shader overlay")
    tree.paused = true
    await tree.create_timer(0.30, true).timeout
    suite.expect_true(
        absf(target.modulate.a - reduced_alpha) < 0.001,
        "process-always timer cannot advance paused reduced departure"
    )
    tree.paused = false
    var reduced_finished := await _wait_until(
        tree,
        func() -> bool: return reduced_completion[0] == 1,
        1000
    )
    suite.expect_true(reduced_finished, "reduced excursion completes before timeout")
    if reduced_finished:
        suite.expect_equal(target.modulate, Color.WHITE, "reduced excursion clears light tint")
        suite.expect_true(target.visible, "reduced excursion restores target after pause")
    suite.expect_equal(
        reduced_stages,
        ["departure", "absence", "return", "returned"],
        "reduced excursion stage order"
    )
    effect.excursion_finished.disconnect(reduced_listener)

    effect.absence_started.disconnect(absence_listener)
    effect.excursion_finished.disconnect(completion_listener)
    tree.root.remove_child(host)
    host.free()
    await _settle_after_free(tree)

    var audio := AudioScript.new()
    for event_id: StringName in [&"ambient", &"paper", &"ivory_click", &"glass_chime", &"metal_click", &"misfire", &"departure", &"return", &"clock_strike", &"door_bell"]:
        var event_path := "res://assets/audio/act_00/%s.wav" % ("ambient_workshop" if event_id == &"ambient" else event_id)
        if not FileAccess.file_exists(event_path):
            continue
        var player := AudioStreamPlayer.new()
        player.name = String(event_id)
        player.stream = load(event_path)
        audio.add_child(player)
    tree.root.add_child(audio)
    await tree.process_frame
    for event_id: StringName in [&"paper", &"ivory_click", &"glass_chime", &"metal_click", &"misfire", &"departure", &"return", &"clock_strike", &"door_bell"]:
        suite.expect_true(audio.play_event(event_id), "%s event maps to a player" % event_id)
    suite.expect_true(not audio.ambient_running(), "audio controller does not start ambient on ready")
    audio.start_ambient()
    suite.expect_true(audio.ambient_running(), "workshop can start ambient explicitly")
    suite.expect_true(audio.play_event(&"departure"), "departure event maps to a player")
    suite.expect_true(audio.event_active(&"departure"), "departure remains active before absence")
    audio.stop_all()
    suite.expect_true(not audio.ambient_running(), "stop_all leaves ambient stopped")
    suite.expect_equal(audio.active_event_count(), 0, "stop_all clears active events")
    await tree.process_frame
    tree.root.remove_child(audio)
    audio.free()
    await _settle_after_free(tree)


func _sha256(path: String) -> String:
    var context := HashingContext.new()
    context.start(HashingContext.HASH_SHA256)
    context.update(FileAccess.get_file_as_bytes(path))
    return context.finish().hex_encode()


func _wav_metadata(path: String) -> Dictionary:
    var bytes := FileAccess.get_file_as_bytes(path)
    return {
        "channels": bytes.decode_u16(22),
        "sample_rate": bytes.decode_u32(24),
        "bits_per_sample": bytes.decode_u16(34),
    }


func _settle_after_free(tree: SceneTree) -> void:
    for _frame in 3:
        await tree.process_frame


func _wait_until(tree: SceneTree, condition: Callable, timeout_ms: int) -> bool:
    var deadline := Time.get_ticks_msec() + timeout_ms
    while not condition.call() and Time.get_ticks_msec() < deadline:
        await tree.process_frame
    return condition.call()
