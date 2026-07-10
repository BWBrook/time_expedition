extends RefCounted

const MainScene := preload("res://game/main.tscn")

const GUIDES := &"act00.item.ivory_guides"
const PRISM := &"act00.item.crystal_prism"
const LEVERS := &"act00.item.control_levers"
const GUIDES_SLOT := &"act00.slot.ivory_guides"
const PRISM_SLOT := &"act00.slot.crystal_prism"
const LEVERS_SLOT := &"act00.slot.control_levers"

var _host: Node


func run(suite: TestSuite, tree: SceneTree) -> void:
    _host = Node.new()
    tree.root.add_child(_host)
    suite.expect_true(
        FileAccess.file_exists("res://tools/capture_qa.gd"),
        "repository QA capture harness is present"
    )
    suite.expect_true(
        FileAccess.file_exists("res://scripts/capture-qa.sh"),
        "repository QA capture launcher is present"
    )
    await _canonical_misfire_then_success(suite, tree)
    await _out_of_order_bench_reopen_path(suite, tree)
    await _resistance_path(suite, tree)
    await _overlay_pause_resume_restart_path(suite, tree)
    await _reduced_motion_completion_path(suite, tree)
    tree.root.remove_child(_host)
    _host.free()
    _host = null


func _canonical_misfire_then_success(suite: TestSuite, tree: SceneTree) -> void:
    var main := await _start_main(tree)
    var workshop := main.get_node("Workshop") as Act00Workshop
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var workbench := workshop.get_node("WorkbenchLayer/ModelWorkbench") as ModelWorkbench
    var hud := workshop.get_node("GameHUD") as GameHUD

    await _discover_all(tree, workshop, true)
    await _open_bench_and_dismiss(tree, workshop)
    await _place_all(tree, workbench)
    workbench.request_lever()
    suite.expect_equal(
        director.phase,
        WorkshopDirector.Phase.CALIBRATION,
        "canonical path retains calibration after the authored misfire"
    )
    suite.expect_true(hud.observation_text().contains("displacement"), "misfire gives corrective feedback")
    await _dismiss_all_observations(tree, hud)
    await _complete_to_closing(suite, tree, main, workshop, false, "canonical corrected path")
    await _free_main(tree, main)


func _out_of_order_bench_reopen_path(suite: TestSuite, tree: SceneTree) -> void:
    var main := await _start_main(tree)
    var workshop := main.get_node("Workshop") as Act00Workshop
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var workbench := workshop.get_node("WorkbenchLayer/ModelWorkbench") as ModelWorkbench
    var hud := workshop.get_node("GameHUD") as GameHUD

    director.handle_action(&"act00.action.collect_guides")
    await _dismiss_all_observations(tree, hud)
    director.handle_action(&"act00.action.bench")
    suite.expect_true(workbench.visible, "bench opens before notebook and all components")
    suite.expect_equal(workbench.available_token_count(), 1, "early bench exposes only collected components")
    workbench.dismiss()
    suite.expect_true(not workbench.visible, "early bench can close without changing sequence state")

    director.handle_action(&"act00.action.notebook")
    await _dismiss_all_observations(tree, hud)
    director.handle_action(&"act00.action.collect_prism")
    await _dismiss_all_observations(tree, hud)
    director.handle_action(&"act00.action.collect_levers")
    await _dismiss_all_observations(tree, hud)
    director.handle_action(&"act00.action.bench")
    await _dismiss_all_observations(tree, hud)
    workbench.select_item(GUIDES)
    workbench.request_slot(GUIDES_SLOT)
    await _dismiss_all_observations(tree, hud)
    workbench.dismiss()
    director.handle_action(&"act00.action.bench")
    await _dismiss_all_observations(tree, hud)
    suite.expect_equal(workbench.placed_count(), 1, "bench reopening retains the first fitted component")
    workbench.select_item(PRISM)
    workbench.request_slot(PRISM_SLOT)
    await _dismiss_all_observations(tree, hud)
    workbench.dismiss()
    director.handle_action(&"act00.action.bench")
    await _dismiss_all_observations(tree, hud)
    workbench.select_item(LEVERS)
    workbench.request_slot(LEVERS_SLOT)
    await _dismiss_all_observations(tree, hud)
    suite.expect_equal(director.phase, WorkshopDirector.Phase.CALIBRATION, "out-of-order path still unlocks calibration")
    suite.expect_equal(workbench.placed_count(), 3, "all placements persist through repeated bench reopening")
    await _complete_to_closing(suite, tree, main, workshop, false, "out-of-order path")
    await _free_main(tree, main)


func _resistance_path(suite: TestSuite, tree: SceneTree) -> void:
    var main := await _start_main(tree)
    var workshop := main.get_node("Workshop") as Act00Workshop
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var workbench := workshop.get_node("WorkbenchLayer/ModelWorkbench") as ModelWorkbench
    var hud := workshop.get_node("GameHUD") as GameHUD
    var session := tree.root.get_node("GameSession")

    director.handle_action(&"act00.action.collect_guides")
    director.handle_action(&"act00.action.collect_guides")
    director.handle_action(&"act00.action.collect_prism")
    director.handle_action(&"act00.action.collect_prism")
    director.handle_action(&"act00.action.collect_levers")
    director.handle_action(&"act00.action.collect_levers")
    await _dismiss_all_observations(tree, hud)
    suite.expect_equal(session.item_ids().size(), 3, "repeated collection never duplicates inventory items")
    director.handle_action(&"act00.action.bench")
    await _dismiss_all_observations(tree, hud)
    for pair in [[GUIDES, PRISM_SLOT], [PRISM, LEVERS_SLOT], [LEVERS, GUIDES_SLOT]]:
        workbench.select_item(pair[0])
        workbench.request_slot(pair[1])
        await _dismiss_all_observations(tree, hud)
    suite.expect_equal(workbench.placed_count(), 0, "wrong-slot attempts leave every component available")
    await _place_all(tree, workbench)
    workbench.set_calibration(0, 1)
    workbench.request_lever()
    await _dismiss_all_observations(tree, hud)
    var phase_before_repeat := director.phase
    workbench.request_lever()
    suite.expect_equal(director.phase, phase_before_repeat, "repeated lever input cannot restart an excursion")
    suite.expect_true(workbench.excursion_active(), "repeated lever input leaves the active excursion single-flight")
    await _complete_to_closing(suite, tree, main, workshop, false, "resistance path")
    await _free_main(tree, main)


func _overlay_pause_resume_restart_path(suite: TestSuite, tree: SceneTree) -> void:
    var main := await _start_main(tree)
    var workshop := main.get_node("Workshop") as Act00Workshop
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var hud := workshop.get_node("GameHUD") as GameHUD
    var workbench := workshop.get_node("WorkbenchLayer/ModelWorkbench") as ModelWorkbench
    var restart_count: Array[int] = [0]
    workshop.restart_requested.connect(func() -> void: restart_count[0] += 1)

    director.handle_action(&"act00.action.collect_guides")
    await _dismiss_all_observations(tree, hud)
    hud.open_inventory()
    suite.expect_true(hud.inventory_visible(), "inventory opens during discovery")
    hud._unhandled_input(_key_event(KEY_ESCAPE, true))
    director.handle_action(&"act00.action.notebook")
    await _dismiss_all_observations(tree, hud)
    hud.open_journal()
    suite.expect_true(hud.journal_visible(), "journal opens during discovery")
    hud._unhandled_input(_key_event(KEY_ESCAPE, true))
    hud.toggle_pause()
    suite.expect_true(tree.paused, "pause opens in the workshop")
    hud.resume()
    suite.expect_true(not tree.paused, "pause resumes the workshop")

    director.handle_action(&"act00.action.collect_prism")
    await _dismiss_all_observations(tree, hud)
    director.handle_action(&"act00.action.collect_levers")
    await _dismiss_all_observations(tree, hud)
    director.handle_action(&"act00.action.bench")
    await _dismiss_all_observations(tree, hud)
    await _send_key(tree, KEY_ESCAPE)
    suite.expect_true(not workbench.visible, "escape closes workbench before opening pause")
    hud.open_inventory()
    suite.expect_true(hud.inventory_visible(), "inventory opens during assembly after closing the bench")
    hud._unhandled_input(_key_event(KEY_ESCAPE, true))
    hud.open_journal()
    suite.expect_true(hud.journal_visible(), "journal opens during assembly after closing the bench")
    hud._unhandled_input(_key_event(KEY_ESCAPE, true))
    director.handle_action(&"act00.action.bench")
    await _dismiss_all_observations(tree, hud)
    hud.set_external_modal_pause_allowed(true)
    hud.toggle_pause()
    suite.expect_true(tree.paused, "pause opens while the workbench modal is active")
    hud.resume()
    suite.expect_true(not tree.paused, "pause resumes while the workbench modal is active")
    workbench.dismiss()
    hud.toggle_pause()
    # SceneTree scripts have no reloadable path, so keep the test runner alive
    # while still exercising the real pause-menu signal route into the workshop.
    var main_restart := Callable(main, "_restart")
    workshop.restart_requested.disconnect(main_restart)
    hud.get_node("PauseOverlay/Frame/Margin/Rows/Restart").pressed.emit()
    await tree.process_frame
    suite.expect_equal(restart_count[0], 1, "pause restart emits the real workshop restart request")
    workshop.restart_requested.connect(main_restart)
    await _free_main(tree, main)
    var restarted_main := await _start_main(tree)
    var restarted_workshop := restarted_main.get_node("Workshop") as Act00Workshop
    var restarted_session := tree.root.get_node("GameSession")
    suite.expect_equal(restarted_session.item_ids().size(), 0, "restart begins with an empty inventory")
    await _discover_all(tree, restarted_workshop, true)
    await _open_bench_and_dismiss(tree, restarted_workshop)
    await _place_all(tree, restarted_workshop.get_node("WorkbenchLayer/ModelWorkbench") as ModelWorkbench)
    await _complete_to_closing(suite, tree, restarted_main, restarted_workshop, false, "restarted overlay path")
    await _free_main(tree, restarted_main)


func _reduced_motion_completion_path(suite: TestSuite, tree: SceneTree) -> void:
    var main := await _start_main(tree)
    var workshop := main.get_node("Workshop") as Act00Workshop
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var workbench := workshop.get_node("WorkbenchLayer/ModelWorkbench") as ModelWorkbench
    var hud := workshop.get_node("GameHUD") as GameHUD

    await _discover_all(tree, workshop, false)
    await _open_bench_and_dismiss(tree, workshop)
    await _place_all(tree, workbench)
    hud.set_reduced_motion(true)
    await _complete_to_closing(suite, tree, main, workshop, true, "reduced-motion path")
    await _free_main(tree, main)


func _start_main(tree: SceneTree) -> Node:
    var main := MainScene.instantiate()
    _host.add_child(main)
    await tree.process_frame
    await _send_key(tree, KEY_ENTER)
    return main


func _discover_all(tree: SceneTree, workshop: Act00Workshop, notebook_first: bool) -> void:
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var hud := workshop.get_node("GameHUD") as GameHUD
    var actions: Array[StringName] = [
        &"act00.action.collect_guides",
        &"act00.action.collect_prism",
        &"act00.action.collect_levers",
    ]
    if notebook_first:
        actions.push_front(&"act00.action.notebook")
    for action_id in actions:
        director.handle_action(action_id)
        await _dismiss_all_observations(tree, hud)


func _open_bench_and_dismiss(tree: SceneTree, workshop: Act00Workshop) -> void:
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var hud := workshop.get_node("GameHUD") as GameHUD
    director.handle_action(&"act00.action.bench")
    await _dismiss_all_observations(tree, hud)


func _place_all(tree: SceneTree, workbench: ModelWorkbench) -> void:
    var hud := workbench.get_parent().get_parent().get_node("GameHUD") as GameHUD
    for pair in [[GUIDES, GUIDES_SLOT], [PRISM, PRISM_SLOT], [LEVERS, LEVERS_SLOT]]:
        workbench.select_item(pair[0])
        workbench.request_slot(pair[1])
        await _dismiss_all_observations(tree, hud)


func _complete_to_closing(
    suite: TestSuite,
    tree: SceneTree,
    main: Node,
    workshop: Act00Workshop,
    reduced_motion: bool,
    path_name: String
) -> void:
    var director := workshop.get_node("WorkshopDirector") as WorkshopDirector
    var workbench := workshop.get_node("WorkbenchLayer/ModelWorkbench") as ModelWorkbench
    var hud := workshop.get_node("GameHUD") as GameHUD
    var absence_started_at: Array[int] = [-1]
    var return_started_at: Array[int] = [-1]
    workbench.absence_started.connect(func() -> void: absence_started_at[0] = Time.get_ticks_msec(), CONNECT_ONE_SHOT)
    suite.expect_true(workbench.has_signal("return_started"), "%s exposes return timing" % path_name)
    if workbench.has_signal("return_started"):
        workbench.connect(
            "return_started",
            func() -> void: return_started_at[0] = Time.get_ticks_msec(),
            CONNECT_ONE_SHOT
        )
    if director.phase == WorkshopDirector.Phase.CALIBRATION:
        workbench.set_calibration(0, 1)
        workbench.request_lever()
        suite.expect_equal(
            director.phase,
            WorkshopDirector.Phase.EXCURSION,
            "%s starts the corrected excursion" % path_name
        )
    suite.expect_equal(
        workbench.authored_absence_seconds(),
        4.0,
        "%s retains the authored four-second absence" % path_name
    )
    await _dismiss_all_observations(tree, hud)
    suite.expect_true(
        await _wait_until(tree, func() -> bool: return not workbench.excursion_target_visible(), 2000),
        "%s visibly communicates the model absence" % path_name
    )
    suite.expect_true(
        (workbench.get_node("Frame/Margin/Rows/Status") as Label).text.contains("four seconds"),
        "%s labels the four-second workshop absence" % path_name
    )
    suite.expect_equal(
        workbench.get_node("TemporalEffect").last_mode,
        "reduced" if reduced_motion else "full",
        "%s selects its requested temporal presentation" % path_name
    )
    suite.expect_true(
        await _wait_until(tree, func() -> bool: return director.phase == WorkshopDirector.Phase.COMPLETE, 7000),
        "%s completes the authored excursion" % path_name
    )
    if reduced_motion:
        var reduced_absence_ms := return_started_at[0] - absence_started_at[0]
        suite.expect_true(
            absence_started_at[0] >= 0 and reduced_absence_ms >= 4000,
            "%s measures a four-second reduced-mode absence (got %d ms)"
            % [path_name, reduced_absence_ms]
        )
        suite.expect_true(
            reduced_absence_ms < 4300,
            "%s starts reduced-mode return immediately after absence" % path_name
        )
    suite.expect_true(
        hud.observation_text().contains("fifteen") and hud.observation_text().contains("four"),
        "%s communicates the onboard fifteen-versus-four-second discrepancy" % path_name
    )
    await _dismiss_all_observations(tree, hud)
    suite.expect_true(
        await _wait_until(tree, func() -> bool: return main.get_node("ClosingLayer/ClosingCard").visible, 7000),
        "%s reaches the closing card" % path_name
    )


func _dismiss_all_observations(tree: SceneTree, hud: GameHUD) -> void:
    while hud.observation_visible():
        await _send_key(tree, KEY_SPACE)


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


func _wait_until(tree: SceneTree, condition: Callable, timeout_ms: int) -> bool:
    var deadline := Time.get_ticks_msec() + timeout_ms
    while not condition.call() and Time.get_ticks_msec() < deadline:
        await tree.process_frame
    return condition.call()


func _free_main(tree: SceneTree, main: Node) -> void:
    tree.paused = false
    if is_instance_valid(main):
        main.get_parent().remove_child(main)
        main.free()
    for _frame in 3:
        await tree.process_frame
