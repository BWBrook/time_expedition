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
            tree.root.remove_child(instance)
            instance.free()

    var main := MainScene.instantiate()
    tree.root.add_child(main)
    await tree.process_frame

    var cold_open: Control = main.get_node("ColdOpen")
    var workshop: Act00Workshop = main.get_node("Workshop")
    var closing_card: Control = main.get_node("ClosingCard")
    var player: PlayerController = workshop.get_node("Player")
    var director: WorkshopDirector = workshop.get_node("WorkshopDirector")
    var hud: GameHUD = workshop.get_node("GameHUD")
    var workbench: ModelWorkbench = workshop.get_node("WorkbenchLayer/ModelWorkbench")
    var session: Node = tree.root.get_node("GameSession")

    var start_count: Array[int] = [0]
    var chapter_count: Array[int] = [0]
    var excursion_count: Array[int] = [0]
    var observation_dismissal_count: Array[int] = [0]
    var placement_count: Array[int] = [0]
    var lever_count: Array[int] = [0]
    var observation_ids: Array[String] = []
    var phases: Array[int] = []
    var items: Array[String] = []
    var flags: Array[String] = []
    var journals: Array[String] = []
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
    session.item_acquired.connect(func(id: StringName) -> void: items.append(String(id)))
    session.flag_changed.connect(
        func(id: StringName, enabled: bool) -> void:
            if enabled:
                flags.append(String(id))
    )
    session.journal_added.connect(func(id: StringName) -> void: journals.append(String(id)))

    suite.expect_true(cold_open.visible, "cold open starts visible")
    suite.expect_true(not workshop.visible, "workshop starts inactive")
    suite.expect_equal(workshop.process_mode, Node.PROCESS_MODE_DISABLED, "inactive workshop disables processing")
    suite.expect_true(not player.input_enabled(), "inactive workshop disables player input")
    suite.expect_true(not closing_card.visible, "closing card starts hidden")
    suite.expect_true(closing_card.get_node("Panel/Margin/Rows/Title").text == "TIME EXPEDITION", "closing card title")
    suite.expect_true(
        closing_card.get_node("Panel/Margin/Rows/Subtitle").text == "The demonstration awaits.",
        "closing card subtitle"
    )
    suite.expect_equal(cold_open.get_signal_connection_list("start_requested").size(), 2, "cold open start is wired once to main and once to test")
    suite.expect_equal(closing_card.get_signal_connection_list("restart_requested").size(), 1, "closing restart is wired")
    suite.expect_equal(closing_card.get_signal_connection_list("quit_requested").size(), 1, "closing quit is wired")

    cold_open._unhandled_input(_key_event(KEY_ENTER))
    cold_open.begin()
    await tree.process_frame
    suite.expect_equal(start_count[0], 1, "cold open begin is idempotent")
    suite.expect_true(not cold_open.visible, "keyboard begin hides cold open")
    suite.expect_true(workshop.visible, "keyboard begin reveals workshop")
    suite.expect_equal(workshop.process_mode, Node.PROCESS_MODE_INHERIT, "active workshop restores processing")
    suite.expect_true(player.input_enabled(), "active workshop enables player input")

    _interact(player, workshop.get_node("Props/Notebook"))
    suite.expect_true(hud.observation_visible(), "notebook opens observation")
    _dismiss(hud)
    _interact(player, workshop.get_node("Props/Drawer"))
    _dismiss(hud)
    _interact(player, workshop.get_node("Props/Prism"))
    _dismiss(hud)
    _interact(player, workshop.get_node("Props/Levers"))
    _dismiss(hud)
    suite.expect_equal(items, [String(GUIDES), String(PRISM), String(LEVERS)], "item acquisition order")
    suite.expect_equal(journals, ["act00.journal.experiment", "act00.journal.components"], "early journal order")

    _interact(player, workshop.get_node("Props/Bench"))
    suite.expect_true(workbench.visible, "bench interaction opens workbench")
    suite.expect_true(not player.input_enabled(), "workbench modal disables player input")
    suite.expect_true(hud.observation_visible(), "bench readiness remains visible before workbench use")
    suite.expect_true(workbench.available_token_count() == 3, "workbench receives collected items")
    _dismiss(hud)

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
    _dismiss(hud)

    _place(workbench, GUIDES, GUIDES_SLOT)
    _dismiss(hud)
    _place(workbench, PRISM, PRISM_SLOT)
    _dismiss(hud)
    _place(workbench, LEVERS, LEVERS_SLOT)
    suite.expect_true(hud.observation_visible(), "third placement keeps component feedback visible")
    suite.expect_equal(workbench.placed_count(), 3, "third placement fills every workbench slot")
    suite.expect_true(workbench.calibration_visible(), "assembly unlocks calibration UI")
    _dismiss(hud)
    suite.expect_true(hud.observation_visible(), "assembly complete follows fitted feedback through HUD FIFO")
    _dismiss(hud)
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
    _dismiss(hud)
    workbench.set_calibration(0, 1)
    suite.expect_equal(workbench.calibration_values(), Vector2i(0, 1), "workbench emits final calibration")
    workbench.request_lever()
    suite.expect_true(hud.observation_visible(), "successful lever opens excursion observation")
    suite.expect_equal(director.phase, WorkshopDirector.Phase.EXCURSION, "lever begins excursion phase")
    _dismiss(hud)
    await _wait_for_excursion(tree, director)
    suite.expect_equal(director.phase, WorkshopDirector.Phase.COMPLETE, "accelerated excursion completes within bounded wait")
    suite.expect_true(hud.observation_visible(), "return observation waits for dismissal")
    suite.expect_true(not closing_card.visible, "closing card waits for return dismissal")
    suite.expect_true(not player.input_enabled(), "complete chapter keeps player input disabled")
    _dismiss(hud)
    await tree.process_frame

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
    suite.expect_equal(chapter_count[0], 1, "workshop emits one chapter completion")
    suite.expect_equal(observation_dismissal_count[0], 12, "HUD emits only final FIFO dismissals")
    suite.expect_true(closing_card.visible, "closing card appears after return dismissal")
    suite.expect_true(not workshop.visible, "completed workshop becomes inactive")
    suite.expect_equal(workshop.process_mode, Node.PROCESS_MODE_DISABLED, "completed workshop disables processing")

    tree.root.remove_child(main)
    main.free()
    tree.paused = false


func _interact(player: PlayerController, target: Interactable) -> void:
    player.focus_interactable(target)
    player._unhandled_input(_key_event(KEY_E))


func _place(workbench: ModelWorkbench, item_id: StringName, slot_id: StringName) -> void:
    workbench.select_item(item_id)
    workbench.request_slot(slot_id)


func _dismiss(hud: GameHUD) -> void:
    hud._unhandled_input(_key_event(KEY_ESCAPE))


func _wait_for_excursion(tree: SceneTree, director: WorkshopDirector) -> void:
    var deadline := Time.get_ticks_msec() + 1000
    while director.phase == WorkshopDirector.Phase.EXCURSION and Time.get_ticks_msec() < deadline:
        await tree.process_frame


func _key_event(keycode: Key) -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = keycode
    event.pressed = true
    return event
