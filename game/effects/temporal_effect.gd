class_name TemporalEffect
extends Node

signal departure_finished
signal absence_started
signal excursion_finished

var last_mode := ""
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
    overlay.visible = not reduced_motion
    var material: ShaderMaterial

    if reduced_motion:
        target.modulate = REDUCED_TINT
        var fade_out := create_tween()
        fade_out.tween_property(target, "modulate:a", 0.0, 0.22)
        await fade_out.finished
    else:
        material = _screen_material(overlay)
        material.set_shader_parameter("intensity", 0.0)
        var depart := create_tween().set_parallel(true)
        depart.tween_method(
            func(value: float) -> void: material.set_shader_parameter("intensity", value),
            0.0,
            1.0,
            0.42
        )
        depart.tween_property(target, "modulate:a", 0.0, 0.42)
        await depart.finished

    departure_finished.emit()
    target.visible = false
    absence_started.emit()
    await get_tree().create_timer(absence_seconds, false).timeout
    target.visible = true

    if reduced_motion:
        target.modulate = Color(REDUCED_TINT.r, REDUCED_TINT.g, REDUCED_TINT.b, 0.0)
        var fade_in := create_tween()
        fade_in.tween_property(target, "modulate:a", 1.0, 0.22)
        await fade_in.finished
    else:
        material = _screen_material(overlay)
        material.set_shader_parameter("intensity", 1.0)
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
    excursion_finished.emit()


func _screen_material(overlay: ColorRect) -> ShaderMaterial:
    var material := overlay.material as ShaderMaterial
    if material == null:
        material = _screen_materials.get(overlay.get_instance_id()) as ShaderMaterial
        overlay.material = material
    return material
