extends RefCounted

const SessionScript := preload("res://game/state/game_session.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var session := SessionScript.new()
    var acquired: Array[String] = []
    var journal_added: Array[String] = []
    var flag_events: Array[String] = []
    var reset_count: Array[int] = [0]
    session.item_acquired.connect(func(id: StringName) -> void: acquired.append(String(id)))
    session.journal_added.connect(func(id: StringName) -> void: journal_added.append(String(id)))
    session.flag_changed.connect(
        func(id: StringName, enabled: bool) -> void:
            flag_events.append("%s=%s" % [id, enabled])
    )
    session.reset_completed.connect(func() -> void: reset_count[0] += 1)

    suite.expect_true(session.acquire_item(&"act00.item.ivory_guides"), "first item acquisition")
    suite.expect_true(not session.acquire_item(&"act00.item.ivory_guides"), "duplicate item ignored")
    suite.expect_true(session.acquire_item(&"act00.item.crystal_prism"), "second item acquisition")
    suite.expect_true(session.has_item(&"act00.item.ivory_guides"), "item membership")
    suite.expect_equal(acquired.size(), 2, "item signal emitted for each acquisition")

    suite.expect_true(session.add_journal_entry(&"act00.journal.experiment"), "first journal entry")
    suite.expect_true(not session.add_journal_entry(&"act00.journal.experiment"), "duplicate journal ignored")
    suite.expect_true(session.add_journal_entry(&"act00.journal.components"), "second journal entry")
    suite.expect_true(session.has_journal_entry(&"act00.journal.experiment"), "journal membership")
    suite.expect_equal(journal_added.size(), 2, "journal signal emitted for each addition")

    suite.expect_true(session.set_flag(&"act00.flag.test", true), "flag changes")
    suite.expect_true(not session.set_flag(&"act00.flag.test", true), "same flag value ignored")
    suite.expect_true(session.get_flag(&"act00.flag.test"), "flag lookup")
    suite.expect_equal(flag_events.size(), 1, "flag signal emitted once")
    suite.expect_true(session.set_flag(&"act00.flag.test", false), "flag clears")
    suite.expect_true(not session.get_flag(&"act00.flag.test"), "cleared flag lookup")
    suite.expect_equal(flag_events.size(), 2, "flag signal emitted for clear")
    suite.expect_equal(flag_events[1], "act00.flag.test=false", "flag clear signal payload")
    suite.expect_true(not session.set_flag(&"act00.flag.test", false), "same cleared value ignored")
    suite.expect_equal(flag_events.size(), 2, "unchanged clear emits no signal")
    suite.expect_equal(
        session.item_ids(),
        PackedStringArray(["act00.item.crystal_prism", "act00.item.ivory_guides"]),
        "stable sorted item snapshot"
    )
    suite.expect_equal(
        session.journal_entry_ids(),
        PackedStringArray(["act00.journal.components", "act00.journal.experiment"]),
        "stable sorted journal snapshot"
    )

    session.reset()
    suite.expect_true(not session.has_item(&"act00.item.ivory_guides"), "reset clears items")
    suite.expect_true(not session.has_journal_entry(&"act00.journal.experiment"), "reset clears journal")
    suite.expect_true(not session.get_flag(&"act00.flag.test"), "reset clears flags")
    suite.expect_equal(reset_count[0], 1, "reset signal emitted")
    session.free()
