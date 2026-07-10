extends RefCounted

const HudScene := preload("res://game/ui/game_hud.tscn")
const RegistryScript := preload("res://game/content/content_registry.gd")
const SessionScript := preload("res://game/state/game_session.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    var registry := RegistryScript.new()
    registry.load_manifest(load("res://game/content/act_00/act_00_manifest.tres"))
    var session := SessionScript.new()
    var hud := HudScene.instantiate()
    tree.root.add_child(hud)
    await tree.process_frame
    suite.expect_equal(hud.process_mode, Node.PROCESS_MODE_ALWAYS, "HUD processes while paused")

    hud.open_inventory()
    hud.open_journal()
    suite.expect_true(not hud.inventory_visible(), "unbound inventory is safely ignored")
    suite.expect_true(not hud.journal_visible(), "unbound journal is safely ignored")

    hud.bind(session, registry)

    hud.show_observation(&"act00.observation.notebook")
    suite.expect_true(hud.observation_visible(), "observation band opens")
    suite.expect_true(hud.observation_text().contains("ink is scarcely dry"), "observation text resolves")

    var observation_dismissals: Array[int] = [0]
    hud.observation_dismissed.connect(func() -> void: observation_dismissals[0] += 1)
    hud.show_observation(&"act00.observation.clock")
    suite.expect_true(
        hud.observation_text().contains("ink is scarcely dry"),
        "visible observation is not overwritten"
    )
    hud.open_inventory()
    hud.open_journal()
    hud.get_node("Toolbar/Buttons/Inventory").pressed.emit()
    hud.get_node("Toolbar/Buttons/Journal").pressed.emit()
    suite.expect_true(hud.observation_visible(), "toolbar and direct opens preserve observation")
    suite.expect_true(
        hud.observation_text().contains("ink is scarcely dry"),
        "toolbar and direct opens preserve queued narrative"
    )
    suite.expect_true(not hud.inventory_visible(), "observation suppresses inventory opens")
    suite.expect_true(not hud.journal_visible(), "observation suppresses journal opens")
    hud._observation.dismiss()
    suite.expect_true(hud.observation_visible(), "dismissal advances queued observation")
    suite.expect_true(
        hud.observation_text().contains("house clock"),
        "queued observation resolves in FIFO order"
    )
    suite.expect_equal(observation_dismissals[0], 0, "queued dismissal is not final")
    hud._observation.dismiss()
    suite.expect_true(not hud.observation_visible(), "final observation dismissal hides band")
    suite.expect_equal(observation_dismissals[0], 1, "final observation dismissal is emitted")

    session.acquire_item(&"act00.item.crystal_prism")
    hud.open_inventory()
    suite.expect_true(hud.inventory_visible(), "inventory opens")
    suite.expect_equal(hud.displayed_item_count(), 1, "one acquired item displayed")

    session.add_journal_entry(&"act00.journal.experiment")
    hud.open_journal()
    suite.expect_true(hud.journal_visible(), "journal opens")
    suite.expect_true(not hud.inventory_visible(), "journal excludes inventory")
    suite.expect_equal(hud.displayed_journal_count(), 1, "one journal entry displayed")

    hud.set_focus_prompt("Inspect notebook", true)
    suite.expect_equal(hud.focus_prompt_text(), "Inspect notebook", "focus prompt text")
    hud.set_reduced_motion(true)
    suite.expect_true(hud.reduced_motion_enabled(), "reduced motion state")

    var pause_events: Array[bool] = []
    var reduced_motion_events: Array[bool] = []
    var restart_events: Array[int] = [0]
    var quit_events: Array[int] = [0]
    var external_close_events: Array[int] = [0]
    hud.pause_changed.connect(func(is_paused: bool) -> void: pause_events.append(is_paused))
    hud.reduced_motion_changed.connect(
        func(enabled: bool) -> void: reduced_motion_events.append(enabled)
    )
    hud.restart_requested.connect(func() -> void: restart_events[0] += 1)
    hud.quit_requested.connect(func() -> void: quit_events[0] += 1)
    hud.external_modal_close_requested.connect(func() -> void: external_close_events[0] += 1)

    hud.toggle_pause()
    suite.expect_true(tree.paused, "pause pauses scene tree")
    suite.expect_equal(pause_events, [true], "pause signal emitted")
    hud.resume()
    suite.expect_true(not tree.paused, "resume unpauses scene tree")
    suite.expect_equal(pause_events, [true, false], "resume signal emitted")

    hud.open_inventory()
    suite.expect_true(hud.inventory_visible(), "inventory opens before external modal")
    hud.set_external_modal_open(true)
    suite.expect_true(not hud.inventory_visible(), "external modal closes inventory")
    hud.set_external_modal_open(false)
    hud.open_journal()
    suite.expect_true(hud.journal_visible(), "journal opens before external modal")
    hud.set_external_modal_open(true)
    suite.expect_true(not hud.journal_visible(), "external modal closes journal")
    hud.open_inventory()
    hud.open_journal()
    hud._unhandled_input(_key_event(KEY_I))
    hud._unhandled_input(_key_event(KEY_J))
    suite.expect_true(not hud.inventory_visible(), "external modal suppresses inventory")
    suite.expect_true(not hud.journal_visible(), "external modal suppresses journal")
    hud._unhandled_input(_key_event(KEY_ESCAPE))
    suite.expect_equal(external_close_events[0], 1, "escape requests external modal close")
    suite.expect_true(not tree.paused, "external modal takes escape priority over pause")
    hud.set_external_modal_open(false)

    hud._pause.restart_requested.emit()
    hud._pause.quit_requested.emit()
    hud._pause.reduced_motion_changed.emit(false)
    suite.expect_equal(restart_events[0], 1, "restart signal is forwarded")
    suite.expect_equal(quit_events[0], 1, "quit signal is forwarded")
    suite.expect_equal(reduced_motion_events, [false], "reduced motion change is emitted")
    suite.expect_true(not hud.reduced_motion_enabled(), "reduced motion signal updates state")

    tree.root.remove_child(hud)
    hud.free()
    registry.free()
    session.free()

func _key_event(keycode: Key) -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = keycode
    event.pressed = true
    return event
