extends RefCounted

const MainScene := preload("res://game/main.tscn")
const PlayerScene := preload("res://game/player/player.tscn")
const HudScene := preload("res://game/ui/game_hud.tscn")
const WorkbenchScene := preload("res://game/workbench/model_workbench.tscn")
const WorkshopScene := preload("res://game/act_00/workshop.tscn")
const ColdOpenScene := preload("res://game/ui/cold_open.tscn")
const ClosingCardScene := preload("res://game/ui/closing_card.tscn")

const SCENES := {
    "res://game/main.tscn": "Main",
    "res://game/player/player.tscn": "Player",
    "res://game/ui/game_hud.tscn": "GameHUD",
    "res://game/ui/inventory_tray.tscn": "InventoryTray",
    "res://game/ui/journal_overlay.tscn": "JournalOverlay",
    "res://game/ui/observation_band.tscn": "ObservationBand",
    "res://game/ui/pause_overlay.tscn": "PauseOverlay",
    "res://game/workbench/model_workbench.tscn": "ModelWorkbench",
    "res://game/act_00/workshop.tscn": "Workshop",
    "res://game/ui/cold_open.tscn": "ColdOpen",
    "res://game/ui/closing_card.tscn": "ClosingCard",
}

const GUIDES := &"act00.item.ivory_guides"
const PRISM := &"act00.item.crystal_prism"
const LEVERS := &"act00.item.control_levers"
const GUIDES_SLOT := &"act00.slot.ivory_guides"
const PRISM_SLOT := &"act00.slot.crystal_prism"
const LEVERS_SLOT := &"act00.slot.control_levers"


func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    for path in SCENES:
        var packed := load(path) as PackedScene
        suite.expect_not_null(packed, "%s loads" % path)
        if packed != null:
            var instance := packed.instantiate()
            suite.expect_equal(instance.name, SCENES[path], "%s root name" % path)
            tree.root.add_child(instance)
            await tree.process_frame
            var preview_audio := instance.get_node_or_null("Act00Audio") as Act00Audio
            if preview_audio != null:
                preview_audio.stop_all()
                await tree.process_frame
            tree.root.remove_child(instance)
            instance.free()
            await _settle_after_free(tree)

    var main := MainScene.instantiate()
    tree.root.add_child(main)
    await tree.process_frame

    var cold_open: Control = main.get_node("ColdOpen")
    var workshop: Act00Workshop = main.get_node("Workshop")
    var closing_card: Control = main.get_node("ClosingLayer/ClosingCard")
    var player: PlayerController = workshop.get_node("Player")
    var director: WorkshopDirector = workshop.get_node("WorkshopDirector")
    var hud: GameHUD = workshop.get_node("GameHUD")
    var workbench: ModelWorkbench = workshop.get_node("WorkbenchLayer/ModelWorkbench")
    var audio: Act00Audio = workshop.get_node("Act00Audio")
    var session: Node = tree.root.get_node("GameSession")
    var camera: Camera2D = player.get_node("Camera2D")

    var start_count: Array[int] = [0]
    var chapter_count: Array[int] = [0]
    var excursion_count: Array[int] = [0]
    var workbench_finish_count: Array[int] = [0]
    var observation_dismissal_count: Array[int] = [0]
    var placement_count: Array[int] = [0]
    var lever_count: Array[int] = [0]
    var observation_ids: Array[String] = []
    var phases: Array[int] = []
    var items: Array[String] = []
    var flags: Array[String] = []
    var journals: Array[String] = []
    var interaction_actions: Array[String] = []
    var audio_silent_at_absence: Array[bool] = []
    var item_listener: Callable = func(id: StringName) -> void: items.append(String(id))
    var flag_listener: Callable = func(id: StringName, enabled: bool) -> void:
        if enabled:
            flags.append(String(id))
    var journal_listener: Callable = func(id: StringName) -> void: journals.append(String(id))
    cold_open.start_requested.connect(func() -> void: start_count[0] += 1)
    workshop.chapter_completed.connect(func() -> void: chapter_count[0] += 1)
    director.excursion_requested.connect(func() -> void: excursion_count[0] += 1)
    director.observation_requested.connect(func(id: StringName) -> void: observation_ids.append(String(id)))
    director.phase_changed.connect(func(phase: WorkshopDirector.Phase) -> void: phases.append(phase))
    hud.observation_dismissed.connect(func() -> void: observation_dismissal_count[0] += 1)
    workbench.placement_requested.connect(
        func(_item: StringName, _slot: StringName) -> void: placement_count[0] += 1
    )
    workbench.lever_pulled.connect(func() -> void: lever_count[0] += 1)
    workbench.excursion_finished.connect(func() -> void: workbench_finish_count[0] += 1)
    workbench.absence_started.connect(
        func() -> void: audio_silent_at_absence.append(audio.active_event_count() == 0)
    )
    player.interaction_requested.connect(
        func(action_id: StringName) -> void: interaction_actions.append(String(action_id))
    )
    session.item_acquired.connect(item_listener)
    session.flag_changed.connect(flag_listener)
    session.journal_added.connect(journal_listener)

    suite.expect_true(cold_open.visible, "cold open starts visible")
    suite.expect_true(not workshop.visible, "workshop starts inactive")
    suite.expect_equal(workshop.process_mode, Node.PROCESS_MODE_DISABLED, "inactive workshop disables processing")
    suite.expect_true(not player.input_enabled(), "inactive workshop disables player input")
    suite.expect_true(not player.has_method("focus_interactable"), "player exposes no test-only focus seam")
    suite.expect_true(not closing_card.visible, "closing card starts hidden")
    suite.expect_equal(workbench.authored_absence_seconds(), 4.0, "workbench exposes authored absence")
    suite.expect_true(closing_card.get_node("Panel/Margin/Rows/Title").text == "TIME EXPEDITION", "closing card title")
    suite.expect_true(
        closing_card.get_node("Panel/Margin/Rows/Subtitle").text == "The demonstration awaits.",
        "closing card subtitle"
    )
    suite.expect_equal(cold_open.get_signal_connection_list("start_requested").size(), 2, "cold open start is wired once to main and once to test")
    suite.expect_equal(closing_card.get_signal_connection_list("restart_requested").size(), 1, "closing restart is wired")
    suite.expect_equal(closing_card.get_signal_connection_list("quit_requested").size(), 1, "closing quit is wired")

    await _send_key(tree, KEY_ENTER)
    await _send_key(tree, KEY_ENTER)
    suite.expect_equal(start_count[0], 1, "cold open begin is idempotent")
    suite.expect_true(not cold_open.visible, "keyboard begin hides cold open")
    suite.expect_true(workshop.visible, "keyboard begin reveals workshop")
    suite.expect_equal(workshop.process_mode, Node.PROCESS_MODE_INHERIT, "active workshop restores processing")
    suite.expect_true(player.input_enabled(), "active workshop enables player input")
    suite.expect_true(audio.ambient_running(), "active workshop starts ambient after cold open")

    var player_x_before := player.global_position.x
    var camera_center_before := camera.get_screen_center_position().x
    await _hold_key(tree, KEY_RIGHT, 150)
    suite.expect_true(player.global_position.x > player_x_before, "ui_right moves the player")
    suite.expect_true(
        camera.get_screen_center_position().x > camera_center_before,
        "camera screen center follows rightward movement"
    )

    await _interact(tree, suite, player, hud, workshop.get_node("Props/Notebook"), interaction_actions)
    suite.expect_true(hud.observation_visible(), "notebook opens observation")
    await _dismiss(tree)
    await _interact(tree, suite, player, hud, workshop.get_node("Props/Drawer"), interaction_actions)
    await _dismiss(tree)
    await _interact(tree, suite, player, hud, workshop.get_node("Props/Prism"), interaction_actions)
    await _dismiss(tree)
    await _interact(tree, suite, player, hud, workshop.get_node("Props/Levers"), interaction_actions)
    await _dismiss(tree)
    suite.expect_equal(items, [String(GUIDES), String(PRISM), String(LEVERS)], "item acquisition order")
    suite.expect_equal(journals, ["act00.journal.experiment", "act00.journal.components"], "early journal order")

    await _interact(tree, suite, player, hud, workshop.get_node("Props/Bench"), interaction_actions)
    suite.expect_true(workbench.visible, "bench interaction opens workbench")
    suite.expect_true(not player.input_enabled(), "workbench modal disables player input")
    suite.expect_true(hud.observation_visible(), "bench readiness remains visible before workbench use")
    suite.expect_true(workbench.available_token_count() == 3, "workbench receives collected items")
    await _dismiss(tree)

    var guides_slot: ComponentSlot = workbench.get_node("Frame/Margin/Rows/Machine/Slots/GuidesSlot")
    var guides_slot_text := guides_slot.text
    workbench.select_item(PRISM)
    workbench.request_slot(GUIDES_SLOT)
    suite.expect_true(hud.observation_visible(), "wrong typed placement opens feedback")
    suite.expect_equal(workbench.placed_count(), 0, "rejected placement leaves workbench empty")
    suite.expect_equal(director.placed_slots(), {}, "rejected placement leaves director empty")
    suite.expect_equal(guides_slot.text, guides_slot_text, "rejected placement leaves slot UI unchanged")
    suite.expect_equal(workbench.available_token_count(), 3, "rejected placement keeps all tokens")
    suite.expect_true(workbench.visible and not player.input_enabled(), "rejection preserves workbench modal state")
    await _dismiss(tree)

    _place(workbench, GUIDES, GUIDES_SLOT)
    await _dismiss(tree)
    _place(workbench, PRISM, PRISM_SLOT)
    await _dismiss(tree)
    _place(workbench, LEVERS, LEVERS_SLOT)
    suite.expect_true(hud.observation_visible(), "third placement keeps component feedback visible")
    suite.expect_equal(workbench.placed_count(), 3, "third placement fills every workbench slot")
    suite.expect_true(workbench.calibration_visible(), "assembly unlocks calibration UI")
    await _dismiss(tree)
    suite.expect_true(hud.observation_visible(), "assembly complete follows fitted feedback through HUD FIFO")
    await _dismiss(tree)
    suite.expect_true(not hud.observation_visible(), "assembly FIFO drains after final dismissal")
    suite.expect_true(workbench.lever_enabled(), "assembly unlocks departure lever")
    suite.expect_equal(
        flags,
        [
            "act00.flag.placed.ivory_guides",
            "act00.flag.placed.crystal_prism",
            "act00.flag.placed.control_levers",
        ],
        "placed-component flag order"
    )
    suite.expect_equal(
        journals,
        [
            "act00.journal.experiment",
            "act00.journal.components",
            "act00.journal.calibration",
        ],
        "assembly journal order"
    )

    workbench.request_lever()
    suite.expect_true(hud.observation_visible(), "misfire opens observation")
    suite.expect_equal(director.phase, WorkshopDirector.Phase.CALIBRATION, "misfire keeps calibration phase")
    await _dismiss(tree)
    workbench.set_calibration(0, 1)
    suite.expect_equal(workbench.calibration_values(), Vector2i(0, 1), "workbench emits final calibration")
    workbench.request_lever()
    suite.expect_true(hud.observation_visible(), "successful lever opens excursion observation")
    suite.expect_equal(director.phase, WorkshopDirector.Phase.EXCURSION, "lever begins excursion phase")
    await _dismiss(tree)
    var excursion_started_at := Time.get_ticks_msec()
    suite.expect_true(workbench.excursion_active(), "workbench enters single-flight excursion")
    suite.expect_true(workbench.controls_locked(), "excursion locks workbench controls")
    suite.expect_true(not workbench.lever_enabled(), "excursion disables lever")
    suite.expect_true(not audio.ambient_running(), "departure silences workshop ambient")
    suite.expect_true(audio.event_active(&"departure"), "departure remains active before model absence")
    var locked_lever_count := lever_count[0]
    workbench.request_lever()
    workbench.dismiss()
    workbench.set_calibration(2, -2)
    suite.expect_equal(lever_count[0], locked_lever_count, "active excursion rejects repeated lever input")
    suite.expect_true(workbench.visible, "active excursion rejects workbench close")
    suite.expect_equal(director.spatial_alignment, 0, "active excursion rejects calibration changes")

    await _send_key(tree, KEY_ESCAPE)
    suite.expect_true(tree.paused, "escape pauses an active external-modal excursion")
    suite.expect_true(workbench.visible, "pause leaves active workbench open")
    suite.expect_true(workbench.excursion_active(), "departure remains active while paused")
    for _frame in 4:
        await tree.process_frame
    suite.expect_equal(director.phase, WorkshopDirector.Phase.EXCURSION, "pause freezes departure")
    await _send_key(tree, KEY_ESCAPE)
    suite.expect_true(not tree.paused, "second escape resumes active excursion")

    var absence_reached := await _wait_for_absence(tree, workbench)
    suite.expect_true(absence_reached, "model becomes absent before helper deadline")
    suite.expect_true(not workbench.excursion_target_visible(), "model becomes absent before authored wait")
    suite.expect_equal(audio_silent_at_absence, [true], "absence signal stops every active audio event")
    suite.expect_equal(audio.active_event_count(), 0, "absence holds complete audio silence")
    await _send_key(tree, KEY_ESCAPE)
    suite.expect_true(tree.paused, "escape pauses model absence")
    for _frame in 4:
        await tree.process_frame
    suite.expect_equal(director.phase, WorkshopDirector.Phase.EXCURSION, "pause freezes authored absence")
    await _send_key(tree, KEY_ESCAPE)
    suite.expect_true(not tree.paused, "second escape resumes authored absence")
    var excursion_completed := await _wait_for_excursion(tree, director)
    suite.expect_true(excursion_completed, "authored excursion completes before helper deadline")
    suite.expect_equal(director.phase, WorkshopDirector.Phase.COMPLETE, "authored excursion completes after four-second absence")
    suite.expect_true(
        Time.get_ticks_msec() - excursion_started_at >= 4750,
        "real-input excursion retains authored four-second absence plus transitions"
    )
    suite.expect_true(audio.ambient_running(), "return resumes workshop ambient")
    suite.expect_true(hud.observation_visible(), "return observation waits for dismissal")
    suite.expect_true(not closing_card.visible, "closing card waits for return dismissal")
    suite.expect_true(not player.input_enabled(), "complete chapter keeps player input disabled")
    await _dismiss(tree)
    await tree.create_timer(0.4, true).timeout
    suite.expect_true(not closing_card.visible, "closing card waits through door-bell delay")
    var closing_card_opened := await _wait_for_closing_card(tree, closing_card)
    suite.expect_true(closing_card_opened, "closing card appears before helper deadline")

    suite.expect_equal(
        observation_ids,
        [
            "act00.observation.notebook",
            "act00.observation.take_guides",
            "act00.observation.take_prism",
            "act00.observation.take_levers",
            "act00.observation.bench_ready",
            "act00.observation.wrong_slot",
            "act00.observation.component_fitted",
            "act00.observation.component_fitted",
            "act00.observation.component_fitted",
            "act00.observation.assembly_complete",
            "act00.observation.misfire",
            "act00.observation.excursion",
            "act00.observation.return",
        ],
        "complete authored observation ID order"
    )
    suite.expect_equal(
        phases,
        [
            WorkshopDirector.Phase.ASSEMBLY,
            WorkshopDirector.Phase.CALIBRATION,
            WorkshopDirector.Phase.EXCURSION,
            WorkshopDirector.Phase.COMPLETE,
        ],
        "authored phase order"
    )
    suite.expect_equal(
        journals,
        [
            "act00.journal.experiment",
            "act00.journal.components",
            "act00.journal.calibration",
            "act00.journal.misfire",
            "act00.journal.success",
        ],
        "complete journal order"
    )
    suite.expect_equal(placement_count[0], 4, "one rejected and three accepted placement signals")
    suite.expect_equal(lever_count[0], 2, "workbench emits both lever attempts")
    suite.expect_equal(excursion_count[0], 1, "director emits one excursion request")
    suite.expect_equal(workbench_finish_count[0], 1, "single-flight excursion finishes exactly once")
    suite.expect_equal(chapter_count[0], 1, "workshop emits one chapter completion")
    suite.expect_equal(observation_dismissal_count[0], 12, "HUD emits only final FIFO dismissals")
    suite.expect_equal(
        interaction_actions,
        [
            "act00.action.notebook",
            "act00.action.collect_guides",
            "act00.action.collect_prism",
            "act00.action.collect_levers",
            "act00.action.bench",
        ],
        "player emits the exact interaction action sequence"
    )
    suite.expect_true(closing_card.visible, "closing card appears after return dismissal")
    suite.expect_true(not workshop.visible, "completed workshop becomes inactive")
    suite.expect_equal(workshop.process_mode, Node.PROCESS_MODE_DISABLED, "completed workshop disables processing")

    session.item_acquired.disconnect(item_listener)
    session.flag_changed.disconnect(flag_listener)
    session.journal_added.disconnect(journal_listener)
    suite.expect_true(not session.item_acquired.is_connected(item_listener), "item listener disconnects")
    suite.expect_true(not session.flag_changed.is_connected(flag_listener), "flag listener disconnects")
    suite.expect_true(not session.journal_added.is_connected(journal_listener), "journal listener disconnects")

    audio.stop_all()
    await tree.process_frame
    tree.root.remove_child(main)
    main.free()
    await _settle_after_free(tree)
    tree.paused = false


func _interact(
    tree: SceneTree,
    suite: TestSuite,
    player: PlayerController,
    hud: GameHUD,
    target: Interactable,
    interaction_actions: Array[String]
) -> void:
    player.global_position = target.global_position + Vector2(0, 90)
    await tree.physics_frame
    await tree.physics_frame
    await tree.physics_frame
    suite.expect_true(hud.get_node("FocusPrompt").visible, "%s focus prompt is visible" % target.name)
    suite.expect_equal(hud.focus_prompt_text(), target.prompt_text(), "%s focus prompt text" % target.name)
    var action_count := interaction_actions.size()
    await _send_key(tree, KEY_E)
    suite.expect_equal(interaction_actions.size(), action_count + 1, "%s emits one interaction" % target.name)
    suite.expect_equal(interaction_actions[-1], String(target.action_id), "%s emits its action ID" % target.name)


func _place(workbench: ModelWorkbench, item_id: StringName, slot_id: StringName) -> void:
    workbench.select_item(item_id)
    workbench.request_slot(slot_id)


func _dismiss(tree: SceneTree) -> void:
    await _send_key(tree, KEY_SPACE)


func _wait_for_excursion(tree: SceneTree, director: WorkshopDirector) -> bool:
    var deadline := Time.get_ticks_msec() + 7000
    while director.phase == WorkshopDirector.Phase.EXCURSION and Time.get_ticks_msec() < deadline:
        await tree.process_frame
    return director.phase != WorkshopDirector.Phase.EXCURSION


func _wait_for_absence(tree: SceneTree, workbench: ModelWorkbench) -> bool:
    var deadline := Time.get_ticks_msec() + 2000
    while workbench.excursion_target_visible() and Time.get_ticks_msec() < deadline:
        await tree.process_frame
    return not workbench.excursion_target_visible()


func _wait_for_closing_card(tree: SceneTree, closing_card: Control) -> bool:
    var deadline := Time.get_ticks_msec() + 3000
    while not closing_card.visible and Time.get_ticks_msec() < deadline:
        await tree.process_frame
    return closing_card.visible


func _hold_key(tree: SceneTree, keycode: Key, physics_frames: int) -> void:
    Input.parse_input_event(_key_event(keycode, true))
    for _frame in physics_frames:
        await tree.physics_frame
    Input.parse_input_event(_key_event(keycode, false))
    await tree.process_frame


func _send_key(tree: SceneTree, keycode: Key) -> void:
    Input.parse_input_event(_key_event(keycode, true))
    await tree.process_frame
    Input.parse_input_event(_key_event(keycode, false))
    await tree.process_frame


func _key_event(keycode: Key, pressed: bool) -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = keycode
    event.pressed = pressed
    return event


func _settle_after_free(tree: SceneTree) -> void:
    for _frame in 3:
        await tree.process_frame
