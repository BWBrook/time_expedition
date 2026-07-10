class_name TemporalEffect
extends Node

signal departure_finished
signal absence_started
signal excursion_finished

var last_mode := ""


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

    if reduced_motion:
        var fade_out := create_tween()
        fade_out.tween_property(target, "modulate:a", 0.0, 0.22)
        await fade_out.finished
    else:
        var material := overlay.material as ShaderMaterial
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
        var fade_in := create_tween()
        fade_in.tween_property(target, "modulate:a", 1.0, 0.22)
        await fade_in.finished
    else:
        var material := overlay.material as ShaderMaterial
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
    target.modulate = Color.WHITE
    excursion_finished.emit()
