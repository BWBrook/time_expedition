extends RefCounted

const SessionScript := preload("res://game/state/game_session.gd")
const DirectorScript := preload("res://game/act_00/workshop_director.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var session := SessionScript.new()
    var director := DirectorScript.new()
    var observations: Array[String] = []
    var workbench_requests: Array[int] = [0]
    var excursion_requests: Array[int] = [0]
    var completion_requests: Array[int] = [0]
    director.observation_requested.connect(
        func(id: StringName) -> void: observations.append(String(id))
    )
    director.workbench_requested.connect(func() -> void: workbench_requests[0] += 1)
    director.excursion_requested.connect(func() -> void: excursion_requests[0] += 1)
    director.chapter_completed.connect(func() -> void: completion_requests[0] += 1)
    director.initialize(session)

    suite.expect_equal(director.phase, DirectorScript.Phase.DISCOVERY, "initial phase")
    director.handle_action(&"act00.action.bench")
    suite.expect_equal(director.phase, DirectorScript.Phase.ASSEMBLY, "bench opens assembly phase")
    suite.expect_equal(workbench_requests[0], 1, "workbench requested")
    suite.expect_equal(observations[-1], "act00.observation.bench_missing", "missing-parts feedback")

    director.handle_action(&"act00.action.notebook")
    suite.expect_true(session.has_journal_entry(&"act00.journal.experiment"), "notebook adds experiment journal")
    director.handle_action(&"act00.action.collect_guides")
    director.handle_action(&"act00.action.collect_guides")
    director.handle_action(&"act00.action.collect_prism")
    director.handle_action(&"act00.action.collect_levers")
    suite.expect_equal(session.item_ids().size(), 3, "all components acquired once")
    suite.expect_true(session.has_journal_entry(&"act00.journal.components"), "components journal added")
    suite.expect_equal(observations[-1], "act00.observation.take_levers", "latest collection feedback")

    suite.expect_true(
        not director.request_place_component(
            &"act00.item.crystal_prism",
            &"act00.slot.ivory_guides"
        ),
        "wrong slot rejected"
    )
    suite.expect_equal(observations[-1], "act00.observation.wrong_slot", "wrong-slot observation")
    suite.expect_true(
        director.request_place_component(
            &"act00.item.ivory_guides",
            &"act00.slot.ivory_guides"
        ),
        "ivory guides placed"
    )
    suite.expect_true(
        director.request_place_component(
            &"act00.item.ivory_guides",
            &"act00.slot.ivory_guides"
        ),
        "same placement is idempotent"
    )
    suite.expect_true(
        director.request_place_component(
            &"act00.item.crystal_prism",
            &"act00.slot.crystal_prism"
        ),
        "prism placed"
    )
    suite.expect_true(
        director.request_place_component(
            &"act00.item.control_levers",
            &"act00.slot.control_levers"
        ),
        "levers placed"
    )
    suite.expect_equal(director.phase, DirectorScript.Phase.CALIBRATION, "assembly unlocks calibration")
    suite.expect_true(session.has_journal_entry(&"act00.journal.calibration"), "calibration clue recorded")

    director.update_calibration(1, 0)
    suite.expect_true(not director.pull_lever(), "incorrect calibration misfires")
    suite.expect_true(session.has_journal_entry(&"act00.journal.misfire"), "misfire recorded")
    suite.expect_equal(excursion_requests[0], 0, "misfire does not start excursion")

    director.update_calibration(0, 1)
    suite.expect_true(director.pull_lever(), "correct calibration starts excursion")
    suite.expect_equal(director.phase, DirectorScript.Phase.EXCURSION, "excursion phase")
    suite.expect_equal(excursion_requests[0], 1, "excursion requested once")
    suite.expect_true(not director.pull_lever(), "lever ignored during excursion")

    suite.expect_true(director.complete_excursion(), "excursion completes")
    suite.expect_equal(director.phase, DirectorScript.Phase.COMPLETE, "complete phase")
    suite.expect_true(session.has_journal_entry(&"act00.journal.success"), "success journal recorded")
    suite.expect_equal(observations[-1], "act00.observation.return", "return observation")
    suite.expect_equal(completion_requests[0], 1, "chapter completion emitted once")
    suite.expect_true(not director.complete_excursion(), "completion is idempotent")
    director.free()
    session.free()
