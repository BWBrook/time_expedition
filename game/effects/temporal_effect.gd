class_name TemporalEffect
extends Node

signal departure_finished
signal departure_started
signal absence_started
signal return_started
signal stable_returned
signal excursion_finished
signal stage_changed(stage: StringName)

var last_mode := ""
var stage: StringName = &"idle"
var _screen_materials := {}

const REDUCED_TINT := Color(0.86, 0.93, 1.0, 1.0)


func play(
    target: CanvasItem,
    overlay: ColorRect,
    reduced_motion: bool,
    absence_seconds := 4.0
) -> void:
    last_mode = "reduced" if reduced_motion else "full"
    target.visible = true
    target.modulate = Color.WHITE
    overlay.visible = false
    var material: ShaderMaterial
    _set_stage(&"departure")

    if reduced_motion:
        target.modulate = REDUCED_TINT
        var fade_out := create_tween()
        fade_out.tween_property(target, "modulate:a", 0.0, 0.22)
        await fade_out.finished
    else:
        material = _screen_material(overlay)
        material.set_shader_parameter("intensity", 0.0)
        overlay.visible = true
        var depart := create_tween().set_parallel(true)
        depart.tween_method(
            func(value: float) -> void: material.set_shader_parameter("intensity", value),
            0.0,
            1.0,
            0.42
        )
        depart.tween_property(target, "modulate:a", 0.0, 0.42)
        await depart.finished

    overlay.visible = false
    if material != null:
        material.set_shader_parameter("intensity", 0.0)
    departure_finished.emit()
    target.modulate.a = 0.0
    _set_stage(&"absence")
    await get_tree().create_timer(absence_seconds, false).timeout

    if reduced_motion:
        target.modulate = Color(REDUCED_TINT.r, REDUCED_TINT.g, REDUCED_TINT.b, 0.0)
        target.visible = true
        _set_stage(&"return")
        var fade_in := create_tween()
        fade_in.tween_property(target, "modulate:a", 1.0, 0.22)
        await fade_in.finished
    else:
        material = _screen_material(overlay)
        material.set_shader_parameter("intensity", 1.0)
        overlay.visible = true
        target.modulate.a = 0.0
        target.visible = true
        _set_stage(&"return")
        var arrive := create_tween().set_parallel(true)
        arrive.tween_method(
            func(value: float) -> void: material.set_shader_parameter("intensity", value),
            1.0,
            0.0,
            0.48
        )
        arrive.tween_property(target, "modulate:a", 1.0, 0.48)
        await arrive.finished

    overlay.visible = false
    if not reduced_motion:
        _screen_materials[overlay.get_instance_id()] = material
        overlay.material = null
    target.modulate = Color.WHITE
    await get_tree().process_frame
    _set_stage(&"returned")
    excursion_finished.emit()


func _screen_material(overlay: ColorRect) -> ShaderMaterial:
    var material := overlay.material as ShaderMaterial
    if material == null:
        material = _screen_materials.get(overlay.get_instance_id()) as ShaderMaterial
        overlay.material = material
    return material


func _set_stage(next_stage: StringName) -> void:
    stage = next_stage
    stage_changed.emit(stage)
    match stage:
        &"departure":
            departure_started.emit()
        &"absence":
            absence_started.emit()
        &"return":
            return_started.emit()
        &"returned":
            stable_returned.emit()
