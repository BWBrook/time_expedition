extends RefCounted

const WorkbenchScene := preload("res://game/workbench/model_workbench.tscn")

const GUIDES := &"act00.item.ivory_guides"
const PRISM := &"act00.item.crystal_prism"
const LEVERS := &"act00.item.control_levers"
const GUIDES_SLOT := &"act00.slot.ivory_guides"
const PRISM_SLOT := &"act00.slot.crystal_prism"
const LEVERS_SLOT := &"act00.slot.control_levers"


func run(suite: TestSuite, tree: SceneTree) -> void:
    var workbench := WorkbenchScene.instantiate()
    tree.root.add_child(workbench)
    await tree.process_frame

    var placements: Array[String] = []
    var calibrations: Array[Vector2i] = []
    var lever_count: Array[int] = [0]
    var close_count: Array[int] = [0]
    workbench.placement_requested.connect(
        func(item_id: StringName, slot_id: StringName) -> void:
            placements.append("%s>%s" % [item_id, slot_id])
    )
    workbench.calibration_changed.connect(
        func(spatial: int, temporal: int) -> void:
            calibrations.append(Vector2i(spatial, temporal))
    )
    workbench.lever_pulled.connect(func() -> void: lever_count[0] += 1)
    workbench.closed.connect(func() -> void: close_count[0] += 1)

    workbench.open_with_items(PackedStringArray([GUIDES, PRISM, LEVERS]), {}, 0, 0)
    suite.expect_true(workbench.visible, "workbench opens")
    suite.expect_equal(workbench.available_token_count(), 3, "three tokens available")
    suite.expect_true(not workbench.lever_enabled(), "lever locked before assembly")

    var prism_slot: ComponentSlot = workbench.get_node("Frame/Margin/Rows/Machine/Slots/PrismSlot")
    var levers_slot: ComponentSlot = workbench.get_node("Frame/Margin/Rows/Machine/Slots/LeversSlot")
    for mapping in [
        [prism_slot, "res://assets/art/act_00/crystal_prism.png"],
        [levers_slot, "res://assets/art/act_00/control_levers.png"],
    ]:
        var mapped_icon := (mapping[0] as ComponentSlot).get("filled_icon") as Texture2D
        suite.expect_not_null(mapped_icon, "%s stores an installed icon" % (mapping[0] as ComponentSlot).name)
        if mapped_icon != null:
            suite.expect_equal(
                mapped_icon.resource_path,
                mapping[1],
                "%s maps its exact component icon" % (mapping[0] as ComponentSlot).name
            )
    workbench.select_item(PRISM)
    suite.expect_equal(
        workbench.get_viewport().gui_get_focus_owner(),
        prism_slot,
        "selecting prism focuses its matching empty slot"
    )
    prism_slot.pressed.emit()
    var keyboard_request := placements[-1]
    suite.expect_equal(keyboard_request, "%s>%s" % [PRISM, PRISM_SLOT], "slot button emits prism request")
    workbench.request_slot(GUIDES_SLOT)
    suite.expect_equal(
        placements[-1],
        "%s>%s" % [PRISM, GUIDES_SLOT],
        "keyboard navigation can still request a deliberately wrong slot"
    )
    prism_slot._drop_data(Vector2.ZERO, {"item_id": PRISM})
    suite.expect_equal(placements[-1], keyboard_request, "mouse drop and keyboard use identical request semantics")

    var guides_slot: ComponentSlot = workbench.get_node("Frame/Margin/Rows/Machine/Slots/GuidesSlot")
    suite.expect_not_null(guides_slot.get("filled_icon"), "component slot stores its matching installed icon")
    suite.expect_equal(guides_slot.icon, null, "empty component slot does not show an installed icon")
    var original_slot_text: String = guides_slot.text
    suite.expect_true(
        not guides_slot._can_drop_data(Vector2.ZERO, {"item_id": PRISM}),
        "typed slot rejects mismatched drag data before the drop"
    )
    suite.expect_equal(guides_slot.text, original_slot_text, "rejected drag leaves slot UI unchanged")
    suite.expect_equal(placements.size(), 3, "rejected drag does not emit misleading placement acceptance")

    workbench.apply_placement_result(PRISM, PRISM_SLOT, false)
    suite.expect_equal(workbench.placed_count(), 0, "rejected Director result does not mutate UI")
    suite.expect_equal(workbench.available_token_count(), 3, "rejected Director result keeps token available")

    workbench.apply_placement_result(GUIDES, GUIDES_SLOT, true)
    suite.expect_equal(workbench.placed_count(), 1, "accepted placement updates UI once")
    suite.expect_equal(workbench.available_token_count(), 2, "accepted placement consumes matching token")
    suite.expect_not_null(guides_slot.icon, "accepted placement reveals the installed component icon")
    if guides_slot.icon != null:
        suite.expect_equal(
            guides_slot.icon.resource_path,
            "res://assets/art/act_00/ivory_guides.png",
            "installed guide slot uses the exact guide icon"
        )
    guides_slot.reset_slot()
    suite.expect_equal(guides_slot.icon, null, "reset slot clears its installed component icon")
    workbench.dismiss()
    workbench.open_with_items(PackedStringArray([GUIDES, PRISM, LEVERS]), {GUIDES_SLOT: GUIDES}, 0, 0)
    suite.expect_equal(workbench.placed_count(), 1, "reopening preserves partial placed state")
    suite.expect_equal(workbench.available_token_count(), 2, "reopening preserves partial token state")
    suite.expect_not_null(guides_slot.icon, "reopening restores the installed component icon")

    workbench.apply_placement_result(GUIDES, GUIDES_SLOT, true)
    suite.expect_equal(workbench.placed_count(), 1, "duplicate accepted placement is idempotent")
    workbench.apply_placement_result(PRISM, PRISM_SLOT, true)
    workbench.apply_placement_result(LEVERS, LEVERS_SLOT, true)
    suite.expect_equal(workbench.placed_count(), 3, "three accepted placements displayed")
    suite.expect_true(workbench.calibration_visible(), "calibration appears after assembly")
    suite.expect_true(workbench.lever_enabled(), "lever enabled after assembly")
    workbench.dismiss()
    workbench.open_with_items(
        PackedStringArray([GUIDES, PRISM, LEVERS]),
        {GUIDES_SLOT: GUIDES, PRISM_SLOT: PRISM, LEVERS_SLOT: LEVERS},
        0,
        1
    )
    suite.expect_equal(workbench.placed_count(), 3, "reopening preserves full placed state")
    suite.expect_true(workbench.lever_enabled(), "reopening preserves lever unlock")
    for mapping in [
        [guides_slot, "res://assets/art/act_00/ivory_guides.png"],
        [prism_slot, "res://assets/art/act_00/crystal_prism.png"],
        [levers_slot, "res://assets/art/act_00/control_levers.png"],
    ]:
        var restored_icon := (mapping[0] as ComponentSlot).icon
        suite.expect_not_null(restored_icon, "%s restores its installed icon" % (mapping[0] as ComponentSlot).name)
        if restored_icon != null:
            suite.expect_equal(
                restored_icon.resource_path,
                mapping[1],
                "%s restores the exact component icon" % (mapping[0] as ComponentSlot).name
            )

    workbench.set_calibration(9, -9)
    suite.expect_equal(workbench.calibration_values(), Vector2i(2, -2), "calibration values clamp to control range")
    suite.expect_equal(calibrations[-1], Vector2i(2, -2), "clamped calibration event is emitted")
    var calibration_count := calibrations.size()
    workbench.set_calibration(2, -2)
    suite.expect_equal(calibrations.size(), calibration_count, "unchanged calibration emits no duplicate signal")
    workbench.set_calibration(0, 1)
    suite.expect_equal(workbench.calibration_values(), Vector2i(0, 1), "target calibration shown")
    workbench.request_lever()
    suite.expect_equal(lever_count[0], 1, "lever request emitted after assembly")

    var placements_before_bad_api := placements.size()
    workbench.select_item(&"act00.item.unknown")
    workbench.request_slot(&"act00.slot.unknown")
    workbench.apply_placement_result(&"act00.item.unknown", &"act00.slot.unknown", true)
    suite.expect_equal(placements.size(), placements_before_bad_api, "unknown API inputs fail without a placement request")
    suite.expect_equal(workbench.placed_count(), 3, "unknown accepted result does not corrupt placed state")

    workbench._unhandled_input(_key_event(KEY_ESCAPE))
    workbench._unhandled_input(_key_event(KEY_ESCAPE))
    suite.expect_equal(close_count[0], 3, "escape emits closed once for its visible session")
    suite.expect_true(not workbench.visible, "escape hides workbench")

    workbench.open_with_items(
        PackedStringArray([GUIDES, PRISM, LEVERS]),
        {GUIDES_SLOT: GUIDES, PRISM_SLOT: PRISM, LEVERS_SLOT: LEVERS},
        0,
        1
    )
    suite.expect_true(workbench.has_method("cover_model"), "workbench exposes the cloth-cover handoff")
    suite.expect_true(workbench.has_method("model_covered"), "workbench exposes covered-model test state")
    if workbench.has_method("cover_model") and workbench.has_method("model_covered"):
        await workbench.cover_model(0.01)
        suite.expect_true(workbench.model_covered(), "cover_model reaches a stable covered state")
        var cloth := workbench.get_node_or_null("Frame/Margin/Rows/Machine/ClothCover") as TextureRect
        suite.expect_not_null(cloth, "workbench contains a ClothCover layer")
        if cloth != null:
            suite.expect_true(cloth.visible, "covered-model state reveals the cloth layer")
            suite.expect_true(cloth.modulate.a > 0.99, "cloth cover finishes fully opaque")
            suite.expect_equal(
                cloth.stretch_mode,
                TextureRect.STRETCH_KEEP_ASPECT_COVERED,
                "cloth cover fills the whole machine area without exposing side components"
            )

    tree.root.remove_child(workbench)
    workbench.free()
    for _frame in 3:
        await tree.process_frame


func _key_event(keycode: Key) -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = keycode
    event.pressed = true
    return event
