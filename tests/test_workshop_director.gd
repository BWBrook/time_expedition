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
    var phase_changes: Array[int] = []
    director.observation_requested.connect(
        func(id: StringName) -> void: observations.append(String(id))
    )
    director.workbench_requested.connect(func() -> void: workbench_requests[0] += 1)
    director.excursion_requested.connect(func() -> void: excursion_requests[0] += 1)
    director.chapter_completed.connect(func() -> void: completion_requests[0] += 1)
    director.phase_changed.connect(func(next_phase: int) -> void: phase_changes.append(next_phase))
    director.initialize(session)

    suite.expect_equal(director.phase, DirectorScript.Phase.DISCOVERY, "initial phase")
    director.handle_action(&"act00.action.collect_guides")
    suite.expect_equal(director.phase, DirectorScript.Phase.DISCOVERY, "collection remains in discovery")
    suite.expect_equal(session.item_ids().size(), 1, "components can be collected before bench")
    suite.expect_true(
        not director.request_place_component(
            &"act00.item.ivory_guides",
            &"act00.slot.ivory_guides"
        ),
        "discovery placement rejected"
    )
    suite.expect_equal(director.placed_slots().size(), 0, "discovery placement leaves slots empty")
    suite.expect_true(
        not session.get_flag(&"act00.flag.placed.ivory_guides"),
        "discovery placement leaves flags unchanged"
    )
    suite.expect_equal(observations[-1], "act00.observation.wrong_slot", "discovery placement feedback")
    director.update_calibration(2, -2)
    suite.expect_equal(director.spatial_alignment, 0, "discovery calibration ignored")
    suite.expect_equal(director.temporal_bias, 0, "discovery calibration leaves bias unchanged")
    suite.expect_true(not director.pull_lever(), "discovery lever rejected")
    suite.expect_equal(director.phase, DirectorScript.Phase.DISCOVERY, "discovery lever leaves phase unchanged")
    suite.expect_equal(observations[-1], "act00.observation.bench_missing", "discovery lever feedback")

    director.handle_action(&"act00.action.bench")
    suite.expect_equal(director.phase, DirectorScript.Phase.ASSEMBLY, "bench opens assembly phase")
    suite.expect_equal(workbench_requests[0], 1, "workbench requested")
    suite.expect_equal(observations[-1], "act00.observation.bench_missing", "missing-parts feedback")
    director.update_calibration(2, -2)
    suite.expect_equal(director.spatial_alignment, 0, "assembly calibration ignored")
    suite.expect_equal(director.temporal_bias, 0, "assembly bias unchanged")
    suite.expect_true(not director.pull_lever(), "assembly lever rejected")
    suite.expect_equal(excursion_requests[0], 0, "assembly lever does not request excursion")
    suite.expect_equal(director.phase, DirectorScript.Phase.ASSEMBLY, "assembly lever leaves phase unchanged")
    suite.expect_equal(phase_changes.size(), 1, "assembly lever emits no phase change")
    suite.expect_equal(observations[-1], "act00.observation.bench_missing", "assembly lever feedback")

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
    var calibrated_slots := director.placed_slots()
    var calibration_phase_change_count := phase_changes.size()
    var calibration_observation_count := observations.size()
    suite.expect_true(
        director.request_place_component(
            &"act00.item.ivory_guides",
            &"act00.slot.ivory_guides"
        ),
        "calibration placement repeat is idempotent"
    )
    suite.expect_equal(director.placed_slots(), calibrated_slots, "calibration repeat leaves slots unchanged")
    suite.expect_equal(
        phase_changes.size(),
        calibration_phase_change_count,
        "calibration repeat emits no phase change"
    )
    suite.expect_equal(
        observations.size(),
        calibration_observation_count,
        "calibration repeat emits no observation"
    )
    suite.expect_true(
        not director.request_place_component(
            &"act00.item.crystal_prism",
            &"act00.slot.ivory_guides"
        ),
        "calibration different pair rejected"
    )
    suite.expect_equal(director.placed_slots(), calibrated_slots, "calibration rejection leaves slots unchanged")
    suite.expect_equal(director.phase, DirectorScript.Phase.CALIBRATION, "calibration rejection leaves phase unchanged")
    suite.expect_equal(
        phase_changes.size(),
        calibration_phase_change_count,
        "calibration rejection emits no phase change"
    )
    suite.expect_equal(observations[-1], "act00.observation.wrong_slot", "calibration rejection feedback")

    director.update_calibration(1, 0)
    suite.expect_true(not director.pull_lever(), "incorrect calibration misfires")
    suite.expect_true(session.has_journal_entry(&"act00.journal.misfire"), "misfire recorded")
    suite.expect_equal(excursion_requests[0], 0, "misfire does not start excursion")

    director.update_calibration(0, 1)
    suite.expect_true(director.pull_lever(), "correct calibration starts excursion")
    suite.expect_equal(director.phase, DirectorScript.Phase.EXCURSION, "excursion phase")
    suite.expect_equal(excursion_requests[0], 1, "excursion requested once")
    suite.expect_true(not director.pull_lever(), "lever ignored during excursion")
    director.handle_action(&"act00.action.bench")
    suite.expect_equal(workbench_requests[0], 1, "bench ignored during excursion")
    var excursion_observation_count := observations.size()
    director.handle_action(&"act00.action.notebook")
    suite.expect_equal(observations.size(), excursion_observation_count, "excursion actions do not mutate story feedback")
    director.update_calibration(2, -2)
    suite.expect_equal(director.spatial_alignment, 0, "excursion calibration ignored")
    suite.expect_equal(director.temporal_bias, 1, "excursion bias unchanged")

    suite.expect_true(director.complete_excursion(), "excursion completes")
    suite.expect_equal(director.phase, DirectorScript.Phase.COMPLETE, "complete phase")
    suite.expect_true(session.has_journal_entry(&"act00.journal.success"), "success journal recorded")
    suite.expect_equal(observations[-1], "act00.observation.return", "return observation")
    suite.expect_equal(completion_requests[0], 0, "chapter handoff waits for return acknowledgement")
    suite.expect_true(not director.complete_excursion(), "completion is idempotent")
    suite.expect_true(director.has_method("acknowledge_return"), "director exposes return acknowledgement")
    if director.has_method("acknowledge_return"):
        suite.expect_true(director.acknowledge_return(), "return acknowledgement releases chapter handoff")
        suite.expect_equal(completion_requests[0], 1, "acknowledgement emits chapter completion once")
        suite.expect_true(not director.acknowledge_return(), "return acknowledgement is idempotent")
        suite.expect_equal(completion_requests[0], 1, "repeated acknowledgement emits no duplicate handoff")
    director.handle_action(&"act00.action.bench")
    suite.expect_equal(workbench_requests[0], 1, "bench ignored after completion")
    director.update_calibration(-2, 2)
    suite.expect_equal(director.spatial_alignment, 0, "completion calibration ignored")
    suite.expect_equal(director.temporal_bias, 1, "completion bias unchanged")
    suite.expect_equal(
        phase_changes,
        [
            DirectorScript.Phase.ASSEMBLY,
            DirectorScript.Phase.CALIBRATION,
            DirectorScript.Phase.EXCURSION,
            DirectorScript.Phase.COMPLETE,
        ],
        "phase changes emit each forward transition exactly once"
    )
    director.free()
    session.free()
