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

    var local_modal_events: Array[bool] = []
    suite.expect_true(hud.has_signal("local_modal_changed"), "HUD exposes local modal state changes")
    if hud.has_signal("local_modal_changed"):
        hud.connect("local_modal_changed", func(open: bool) -> void: local_modal_events.append(open))
    suite.expect_true(hud.has_method("local_modal_open"), "HUD exposes current local modal state")

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
    if hud.has_method("local_modal_open"):
        suite.expect_true(hud.local_modal_open(), "inventory reports a local modal blocker")
    hud.get_node("InventoryTray/Margin/Rows/Header/Close").pressed.emit()
    suite.expect_true(not hud.inventory_visible(), "inventory close button hides the overlay")
    if hud.has_method("local_modal_open"):
        suite.expect_true(not hud.local_modal_open(), "inventory close button clears local modal state")

    var inventory_session := SessionScript.new()
    var inventory_hud := HudScene.instantiate()
    tree.root.add_child(inventory_hud)
    await tree.process_frame
    inventory_hud.bind(inventory_session, registry)
    for item_id in [
        &"act00.item.ivory_guides",
        &"act00.item.brass_rails",
        &"act00.item.crystal_prism",
        &"act00.item.smoked_lens",
        &"act00.item.control_levers",
        &"act00.item.clockwork_escapement",
    ]:
        inventory_session.acquire_item(item_id)
    inventory_hud.open_inventory()
    await tree.process_frame
    suite.expect_equal(inventory_hud.displayed_item_count(), 6, "all six acquired candidates display")
    var items := inventory_hud.get_node("InventoryTray/Margin/Rows/Items") as GridContainer
    suite.expect_not_null(items, "inventory uses a grid container")
    if items != null:
        suite.expect_equal(items.columns, 3, "inventory grid has three columns")
        suite.expect_equal(items.get_theme_constant("h_separation"), 18, "inventory horizontal separation")
        suite.expect_equal(items.get_theme_constant("v_separation"), 12, "inventory vertical separation")
        for cell in items.get_children():
            suite.expect_true(cell is HBoxContainer, "inventory cells are horizontal containers")
            suite.expect_equal(
                cell.custom_minimum_size,
                Vector2(300, 118),
                "inventory cells have bounded minimum geometry"
            )
            var icon := cell.get_node_or_null("Icon") as TextureRect
            suite.expect_not_null(icon, "inventory cell has an icon")
            if icon != null:
                suite.expect_equal(icon.custom_minimum_size, Vector2(56, 56), "inventory icon geometry")
            var description := cell.get_node_or_null("Text/Description") as Label
            suite.expect_not_null(description, "inventory description is in the text column")
            if description != null:
                suite.expect_equal(
                    description.autowrap_mode,
                    TextServer.AUTOWRAP_WORD_SMART,
                    "inventory descriptions wrap"
                )
    var inventory_tray := inventory_hud.get_node("InventoryTray")
    suite.expect_true(inventory_tray.has_method("column_count"), "inventory exposes column count")
    suite.expect_true(
        inventory_tray.has_method("maximum_cell_width"),
        "inventory exposes bounded cell width"
    )
    if inventory_tray.has_method("column_count"):
        suite.expect_equal(inventory_tray.column_count(), 3, "inventory exposes column count")
    if inventory_tray.has_method("maximum_cell_width"):
        suite.expect_true(
            inventory_tray.maximum_cell_width() <= 310.0,
            "inventory cells remain within the bounded width"
        )
    tree.root.remove_child(inventory_hud)
    inventory_hud.free()
    inventory_session.free()

    session.add_journal_entry(&"act00.journal.experiment")
    hud.open_journal()
    suite.expect_true(hud.journal_visible(), "journal opens")
    suite.expect_true(not hud.inventory_visible(), "journal excludes inventory")
    suite.expect_equal(hud.displayed_journal_count(), 1, "one journal entry displayed")
    suite.expect_true(hud.has_method("journal_sketch_text"), "HUD exposes the journal sketch")
    if hud.has_method("journal_sketch_text"):
        suite.expect_true(
            hud.journal_sketch_text().contains("Spatial datum: not yet verified"),
            "undiscovered spatial datum remains hidden"
        )
        suite.expect_true(
            hud.journal_sketch_text().contains("Temporal datum: not yet verified"),
            "undiscovered temporal datum remains hidden"
        )
        suite.expect_true(
            not hud.journal_sketch_text().contains("Spatial datum: 0"),
            "spatial datum value is not leaked"
        )
        suite.expect_true(
            not hud.journal_sketch_text().contains("Temporal datum: +1"),
            "temporal datum value is not leaked"
        )
    if hud.has_method("local_modal_open"):
        suite.expect_true(hud.local_modal_open(), "journal reports a local modal blocker")
    session.add_journal_entry(&"act00.journal.spatial_datum")
    hud.open_journal()
    if hud.has_method("journal_sketch_text"):
        suite.expect_true(
            hud.journal_sketch_text().contains("Spatial datum: 0"),
            "discovered spatial datum is revealed"
        )
        suite.expect_true(
            not hud.journal_sketch_text().contains("Temporal datum: +1"),
            "undiscovered temporal datum remains secret"
        )
    session.add_journal_entry(&"act00.journal.temporal_datum")
    hud.open_journal()
    if hud.has_method("journal_sketch_text"):
        suite.expect_true(
            hud.journal_sketch_text().contains("Temporal datum: +1"),
            "discovered temporal datum is revealed"
        )
    hud._unhandled_input(_key_event(KEY_ESCAPE))
    suite.expect_true(not hud.journal_visible(), "escape hides the journal overlay")
    if hud.has_method("local_modal_open"):
        suite.expect_true(not hud.local_modal_open(), "journal escape clears local modal state")
    suite.expect_equal(
        local_modal_events,
        [true, false, true, false],
        "local modal state emits once for each open and close"
    )

    var transition_observation_visibility: Array[bool] = []
    if hud.has_signal("local_modal_changed"):
        hud.connect(
            "local_modal_changed",
            func(open: bool) -> void:
                if not open:
                    transition_observation_visibility.append(hud.observation_visible())
        )
    hud.open_inventory()
    hud.show_observation(&"act00.observation.clock")
    suite.expect_true(not hud.inventory_visible(), "observation closes an open local modal")
    suite.expect_true(hud.observation_visible(), "observation replaces a local modal atomically")
    suite.expect_equal(
        transition_observation_visibility,
        [true],
        "local modal close is reported only after observation blocking is active"
    )
    hud._observation.dismiss()

    hud.set_focus_prompt("Inspect notebook", true)
    suite.expect_equal(hud.focus_prompt_text(), "Inspect notebook", "focus prompt text")
    var focus_actions: Array[int] = [0]
    suite.expect_true(hud.has_signal("focus_action_requested"), "HUD exposes focus-command activation")
    if hud.has_signal("focus_action_requested"):
        hud.connect("focus_action_requested", func() -> void: focus_actions[0] += 1)
    var focus_button := hud.get_node("FocusPrompt") as Button
    suite.expect_not_null(focus_button, "focus prompt is an actionable button")
    if focus_button != null:
        focus_button.pressed.emit()
    suite.expect_equal(focus_actions[0], 1, "focus button emits one command activation")
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
    suite.expect_true(not hud.get_node("Toolbar").visible, "external modal hides inert toolbar controls")
    hud.set_external_modal_open(false)
    suite.expect_true(hud.get_node("Toolbar").visible, "closing external modal restores toolbar controls")
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

    var observation_hud := HudScene.instantiate()
    tree.root.add_child(observation_hud)
    await tree.process_frame
    observation_hud.bind(session, registry)
    var observation_events: Array[String] = []
    var observation_pause_events: Array[bool] = []
    observation_hud.observation_dismissed.connect(
        func() -> void: observation_events.append("observation")
    )
    observation_hud.external_modal_close_requested.connect(
        func() -> void: observation_events.append("external")
    )
    observation_hud.pause_changed.connect(
        func(is_paused: bool) -> void: observation_pause_events.append(is_paused)
    )
    observation_hud.show_observation(&"act00.observation.notebook")
    observation_hud.show_observation(&"act00.observation.clock")
    observation_hud.toggle_pause()
    suite.expect_true(not tree.paused, "observation blocks direct pause")
    suite.expect_true(observation_hud.observation_visible(), "pause preserves observation")
    suite.expect_true(
        observation_hud.observation_text().contains("ink is scarcely dry"),
        "pause preserves current observation"
    )
    suite.expect_equal(observation_pause_events, [], "observation pause attempt emits no pause signal")
    suite.expect_equal(observation_events, [], "observation pause attempt emits no completion")
    observation_hud.set_external_modal_open(true)
    suite.expect_true(not tree.paused, "external modal preserves unpaused tree with observation")
    suite.expect_true(observation_hud.observation_visible(), "external modal preserves observation")
    suite.expect_true(
        observation_hud.observation_text().contains("ink is scarcely dry"),
        "external modal preserves queued observation order"
    )
    suite.expect_equal(observation_events, [], "external modal emits no observation completion")
    observation_hud._unhandled_input(_key_event(KEY_ESCAPE))
    suite.expect_true(observation_hud.observation_visible(), "escape advances observation before external close")
    suite.expect_true(
        observation_hud.observation_text().contains("house clock"),
        "escape retains FIFO observation order over external modal"
    )
    suite.expect_equal(observation_events, [], "queued escape emits no completion or external close")
    observation_hud._unhandled_input(_key_event(KEY_ESCAPE))
    suite.expect_true(not observation_hud.observation_visible(), "second escape dismisses final observation")
    suite.expect_equal(observation_events, ["observation"], "final observation emits first")
    observation_hud._unhandled_input(_key_event(KEY_ESCAPE))
    suite.expect_equal(
        observation_events,
        ["observation", "external"],
        "external close follows final observation dismissal"
    )
    suite.expect_true(not tree.paused, "observation and external escape sequence stays unpaused")
    observation_hud.set_external_modal_open(false)
    tree.root.remove_child(observation_hud)
    observation_hud.free()

    var external_handoff_hud := HudScene.instantiate()
    tree.root.add_child(external_handoff_hud)
    await tree.process_frame
    external_handoff_hud.bind(session, registry)
    var external_handoff_pause_events: Array[bool] = []
    var external_handoff_events: Array[String] = []
    external_handoff_hud.pause_changed.connect(
        func(is_paused: bool) -> void: external_handoff_pause_events.append(is_paused)
    )
    external_handoff_hud.external_modal_close_requested.connect(
        func() -> void: external_handoff_events.append("external")
    )
    external_handoff_hud.toggle_pause()
    suite.expect_true(tree.paused, "pause opens before external handoff")
    external_handoff_hud.set_external_modal_open(true)
    suite.expect_true(not tree.paused, "external modal resumes pause before opening")
    suite.expect_equal(
        external_handoff_pause_events,
        [true, false],
        "external handoff emits pause then resume"
    )
    suite.expect_equal(external_handoff_events, [], "external handoff emits no close request")
    external_handoff_hud.open_inventory()
    external_handoff_hud.open_journal()
    suite.expect_true(not external_handoff_hud.inventory_visible(), "external handoff suppresses inventory")
    suite.expect_true(not external_handoff_hud.journal_visible(), "external handoff suppresses journal")
    external_handoff_hud.set_external_modal_open(false)
    tree.root.remove_child(external_handoff_hud)
    external_handoff_hud.free()

    var observation_handoff_hud := HudScene.instantiate()
    tree.root.add_child(observation_handoff_hud)
    await tree.process_frame
    observation_handoff_hud.bind(session, registry)
    var observation_handoff_pause_events: Array[bool] = []
    var observation_handoff_events: Array[String] = []
    observation_handoff_hud.pause_changed.connect(
        func(is_paused: bool) -> void: observation_handoff_pause_events.append(is_paused)
    )
    observation_handoff_hud.observation_dismissed.connect(
        func() -> void: observation_handoff_events.append("observation")
    )
    observation_handoff_hud.toggle_pause()
    suite.expect_true(tree.paused, "pause opens before observation handoff")
    observation_handoff_hud.show_observation(&"act00.observation.notebook")
    observation_handoff_hud.show_observation(&"act00.observation.clock")
    suite.expect_true(not tree.paused, "observation resumes pause before showing")
    suite.expect_true(observation_handoff_hud.observation_visible(), "observation opens after pause handoff")
    suite.expect_true(
        observation_handoff_hud.observation_text().contains("ink is scarcely dry"),
        "pause handoff keeps first observation visible"
    )
    suite.expect_equal(
        observation_handoff_pause_events,
        [true, false],
        "observation handoff emits pause then resume"
    )
    observation_handoff_hud._observation.dismiss()
    suite.expect_true(
        observation_handoff_hud.observation_text().contains("house clock"),
        "observation handoff retains queued observation"
    )
    suite.expect_equal(observation_handoff_events, [], "queued handoff dismissal emits no completion")
    observation_handoff_hud._observation.dismiss()
    suite.expect_equal(
        observation_handoff_events,
        ["observation"],
        "final handoff dismissal emits one completion"
    )
    tree.root.remove_child(observation_handoff_hud)
    observation_handoff_hud.free()

    tree.root.remove_child(hud)
    hud.free()
    registry.free()
    session.free()

func _key_event(keycode: Key) -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = keycode
    event.pressed = true
    return event
