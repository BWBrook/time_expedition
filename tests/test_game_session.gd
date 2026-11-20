extends RefCounted

const SessionScript := preload("res://game/state/game_session.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var session := SessionScript.new()
    var acquired: Array[String] = []
    var journal_added: Array[String] = []
    session.item_acquired.connect(func(id: StringName) -> void: acquired.append(String(id)))
    session.journal_added.connect(func(id: StringName) -> void: journal_added.append(String(id)))

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
    session.free()
