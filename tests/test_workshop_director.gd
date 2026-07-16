extends RefCounted

const SessionScript := preload("res://game/state/game_session.gd")
const DirectorScript := preload("res://game/act_00/workshop_director.gd")

const CANDIDATES: Array[StringName] = [
    &"act00.item.ivory_guides",
    &"act00.item.brass_rails",
    &"act00.item.crystal_prism",
    &"act00.item.smoked_lens",
    &"act00.item.control_levers",
    &"act00.item.clockwork_escapement",
]
const SLOTS: Array[StringName] = [
    &"act00.slot.ivory_guides",
    &"act00.slot.crystal_prism",
    &"act00.slot.control_levers",
]
const REQUIRED_SLOTS := {
    &"act00.slot.ivory_guides": &"act00.item.ivory_guides",
    &"act00.slot.crystal_prism": &"act00.item.crystal_prism",
    &"act00.slot.control_levers": &"act00.item.control_levers",
}
const PAIRED_ACTIONS := {
    &"act00.action.collect_guides_and_rails": [
        &"act00.item.ivory_guides",
        &"act00.item.brass_rails",
        &"act00.observation.take_guides",
        &"act00.observation.guides_taken",
    ],
    &"act00.action.collect_prism_and_lens": [
        &"act00.item.crystal_prism",
        &"act00.item.smoked_lens",
        &"act00.observation.take_prism",
        &"act00.observation.prism_taken",
    ],
    &"act00.action.collect_levers_and_escapement": [
        &"act00.item.control_levers",
        &"act00.item.clockwork_escapement",
        &"act00.observation.take_levers",
        &"act00.observation.levers_taken",
    ],
}
const OPTIONAL_ACTIONS := {
    &"act00.action.diagrams": [&"act00.observation.diagrams", &"act00.observation.diagrams_repeat"],
    &"act00.action.glassware": [&"act00.observation.glassware", &"act00.observation.glassware_repeat"],
    &"act00.action.window": [&"act00.observation.window", &"act00.observation.window_repeat"],
    &"act00.action.gas_lamp": [&"act00.observation.gas_lamp", &"act00.observation.gas_lamp_repeat"],
    &"act00.action.drafting_stool": [&"act00.observation.drafting_stool", &"act00.observation.drafting_stool_repeat"],
    &"act00.action.specimen_cabinet": [&"act00.observation.specimen_cabinet", &"act00.observation.specimen_cabinet_repeat"],
}
const DIAGNOSTICS := {
    Vector2i(-1, -1): &"act00.observation.misfire.left_slow",
    Vector2i(-1, 0): &"act00.observation.misfire.left_correct",
    Vector2i(-1, 1): &"act00.observation.misfire.left_fast",
    Vector2i(0, -1): &"act00.observation.misfire.centred_slow",
    Vector2i(0, 1): &"act00.observation.misfire.centred_fast",
    Vector2i(1, -1): &"act00.observation.misfire.right_slow",
    Vector2i(1, 0): &"act00.observation.misfire.right_correct",
    Vector2i(1, 1): &"act00.observation.misfire.right_fast",
}
const INSTRUMENT_TEXT := {
    Vector2i(-1, -1): "FIELD: LEFT | RATE: SLOW",
    Vector2i(-1, 0): "FIELD: LEFT | RATE: CORRECT",
    Vector2i(-1, 1): "FIELD: LEFT | RATE: FAST",
    Vector2i(0, -1): "FIELD: CENTRED | RATE: SLOW",
    Vector2i(0, 1): "FIELD: CENTRED | RATE: FAST",
    Vector2i(1, -1): "FIELD: RIGHT | RATE: SLOW",
    Vector2i(1, 0): "FIELD: RIGHT | RATE: CORRECT",
    Vector2i(1, 1): "FIELD: RIGHT | RATE: FAST",
}

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    _test_paired_collection_and_clues(suite)
    _test_independent_clue_order(suite)
    _test_stateful_observations(suite)
    _test_all_slot_attempts(suite)
    _test_calibration_diagnostics(suite)
    _test_excursion_and_completion_guards(suite)


func _test_paired_collection_and_clues(suite: TestSuite) -> void:
    var session := SessionScript.new()
    var director := DirectorScript.new()
    var observations: Array[StringName] = []
    director.observation_requested.connect(func(id: StringName) -> void: observations.append(id))
    director.initialize(session)

    director.handle_action(&"act00.action.collect_guides_and_rails")
    suite.expect_equal(session.item_ids().size(), 2, "guide pair acquires two candidates")
    suite.expect_true(session.has_item(&"act00.item.ivory_guides"), "ivory guides acquired")
    suite.expect_true(session.has_item(&"act00.item.brass_rails"), "brass rails acquired")
    suite.expect_true(
        session.has_journal_entry(&"act00.journal.materials"),
        "first paired collection records the candidate materials"
    )
    _expect_last_observation(suite, observations, &"act00.observation.take_guides", "guide pair first observation")
    director.handle_action(&"act00.action.collect_guides_and_rails")
    suite.expect_equal(session.item_ids().size(), 2, "repeated guide pair is idempotent")
    _expect_last_observation(suite, observations, &"act00.observation.guides_taken", "guide pair repeat observation")

    director.handle_action(&"act00.action.collect_prism_and_lens")
    suite.expect_true(session.has_item(&"act00.item.crystal_prism"), "crystal prism acquired")
    suite.expect_true(session.has_item(&"act00.item.smoked_lens"), "smoked lens acquired")
    director.handle_action(&"act00.action.collect_levers_and_escapement")
    suite.expect_true(session.has_item(&"act00.item.control_levers"), "control levers acquired")
    suite.expect_true(
        session.has_item(&"act00.item.clockwork_escapement"),
        "clockwork escapement acquired"
    )
    suite.expect_equal(session.item_ids().size(), 6, "three paired actions acquire six unique candidates")
    suite.expect_true(director.all_items_acquired(), "all six candidates define readiness")
    suite.expect_true(session.has_journal_entry(&"act00.journal.components"), "components journal is recorded")
    var item_count := session.item_ids().size()
    director.handle_action(&"act00.action.collect_prism_and_lens")
    director.handle_action(&"act00.action.collect_levers_and_escapement")
    suite.expect_equal(session.item_ids().size(), item_count, "repeated pairs add no inventory")
    _expect_last_observation(suite, observations, &"act00.observation.levers_taken", "last repeated pair uses repeat observation")

    director.handle_action(&"act00.action.notebook")
    suite.expect_true(session.has_journal_entry(&"act00.journal.experiment"), "notebook journal is idempotently added")
    _expect_last_observation(suite, observations, &"act00.observation.notebook", "notebook base observation")
    director.free()
    session.free()


func _test_independent_clue_order(suite: TestSuite) -> void:
    for action_order in [
        [&"act00.action.clock", &"act00.action.spirit_level"],
        [&"act00.action.spirit_level", &"act00.action.clock"],
    ]:
        var session := SessionScript.new()
        var director := DirectorScript.new()
        director.initialize(session)
        var expected_ids := PackedStringArray()
        for action_id in action_order:
            director.handle_action(action_id)
            expected_ids.append(
                "act00.journal.temporal_datum"
                if action_id == &"act00.action.clock"
                else "act00.journal.spatial_datum"
            )
            expected_ids.sort()
            suite.expect_equal(
                session.journal_entry_ids(),
                expected_ids,
                "%s adds only its own datum" % action_id
            )
        director.free()
        session.free()


func _test_stateful_observations(suite: TestSuite) -> void:
    var session := SessionScript.new()
    var director := DirectorScript.new()
    var observations: Array[StringName] = []
    director.observation_requested.connect(func(id: StringName) -> void: observations.append(id))
    director.initialize(session)

    director.handle_action(&"act00.action.notebook")
    _expect_last_observation(suite, observations, &"act00.observation.notebook", "notebook starts with base observation")
    director.handle_action(&"act00.action.clock")
    suite.expect_true(session.has_journal_entry(&"act00.journal.temporal_datum"), "clock adds temporal datum")
    _expect_last_observation(suite, observations, &"act00.observation.clock", "clock first observation")
    director.handle_action(&"act00.action.clock")
    _expect_last_observation(suite, observations, &"act00.observation.clock_repeat", "clock repeat observation")
    director.handle_action(&"act00.action.notebook")
    _expect_last_observation(suite, observations, &"act00.observation.notebook_after_datum", "notebook reflects temporal datum")
    director.handle_action(&"act00.action.spirit_level")
    suite.expect_true(session.has_journal_entry(&"act00.journal.spatial_datum"), "spirit level adds spatial datum")
    _expect_last_observation(suite, observations, &"act00.observation.spirit_level", "spirit level first observation")
    director.handle_action(&"act00.action.spirit_level")
    _expect_last_observation(suite, observations, &"act00.observation.spirit_level_repeat", "spirit level repeat observation")

    for action_id in PAIRED_ACTIONS:
        director.handle_action(action_id)
    director.handle_action(&"act00.action.bench")
    _expect_last_observation(suite, observations, &"act00.observation.bench_ready", "bench recognizes all six candidates")
    suite.expect_equal(director.phase, DirectorScript.Phase.ASSEMBLY, "bench enters assembly")
    director.handle_action(&"act00.action.displacement_rig")
    _expect_last_observation(suite, observations, &"act00.observation.displacement_rig", "rig uses discovery observation")
    for slot_id in SLOTS:
        director.request_place_component(REQUIRED_SLOTS[slot_id], slot_id)
    suite.expect_equal(director.phase, DirectorScript.Phase.CALIBRATION, "all required placements enter calibration")
    director.handle_action(&"act00.action.notebook")
    _expect_last_observation(suite, observations, &"act00.observation.notebook_calibration", "notebook uses calibration observation")
    director.handle_action(&"act00.action.bench")
    _expect_last_observation(suite, observations, &"act00.observation.bench_calibration", "bench uses calibration observation")
    director.handle_action(&"act00.action.displacement_rig")
    _expect_last_observation(suite, observations, &"act00.observation.displacement_rig_calibration", "rig uses calibration observation")

    for action_id in OPTIONAL_ACTIONS:
        director.initialize(session)
        observations.clear()
        director.handle_action(action_id)
        _expect_last_observation(suite, observations, OPTIONAL_ACTIONS[action_id][0], "%s base observation" % action_id)
        director.handle_action(action_id)
        _expect_last_observation(suite, observations, OPTIONAL_ACTIONS[action_id][1], "%s repeat observation" % action_id)
    director.free()
    session.free()


func _test_all_slot_attempts(suite: TestSuite) -> void:
    for item_id in CANDIDATES:
        for slot_id in SLOTS:
            var session := SessionScript.new()
            var director := DirectorScript.new()
            var observations: Array[StringName] = []
            director.observation_requested.connect(func(id: StringName) -> void: observations.append(id))
            director.initialize(session)
            for candidate_id in CANDIDATES:
                session.acquire_item(candidate_id)
            director.handle_action(&"act00.action.bench")
            var before_items := session.item_ids()
            var before_slots := director.placed_slots()
            var accepted: bool = REQUIRED_SLOTS[slot_id] == item_id
            suite.expect_equal(
                director.request_place_component(item_id, slot_id),
                accepted,
                "%s in %s acceptance" % [item_id, slot_id]
            )
            if accepted:
                _expect_last_observation(suite, observations, &"act00.observation.component_fitted", "accepted placement observation")
            else:
                var item_slug := String(item_id).get_slice(".", 2)
                var slot_slug := String(slot_id).get_slice(".", 2)
                suite.expect_equal(
                    _last_or_empty(observations),
                    StringName("act00.observation.reject.%s.%s" % [item_slug, slot_slug]),
                    "exact rejection observation"
                )
                suite.expect_equal(session.item_ids(), before_items, "rejection preserves inventory")
                suite.expect_equal(director.placed_slots(), before_slots, "rejection preserves placements")
            director.free()
            session.free()

    var session := SessionScript.new()
    var director := DirectorScript.new()
    director.initialize(session)
    for candidate_id in CANDIDATES:
        session.acquire_item(candidate_id)
    director.handle_action(&"act00.action.bench")
    director.request_place_component(&"act00.item.ivory_guides", &"act00.slot.ivory_guides")
    var placed := director.placed_slots()
    suite.expect_true(
        director.request_place_component(&"act00.item.ivory_guides", &"act00.slot.ivory_guides"),
        "correctly placed pair remains idempotent"
    )
    suite.expect_equal(director.placed_slots(), placed, "idempotent placement preserves slots")
    director.free()
    session.free()


func _test_calibration_diagnostics(suite: TestSuite) -> void:
    var session := SessionScript.new()
    var director := DirectorScript.new()
    var observations: Array[StringName] = []
    var feedback: Array[Array] = []
    director.observation_requested.connect(func(id: StringName) -> void: observations.append(id))
    suite.expect_true(director.has_signal("calibration_feedback_requested"), "calibration feedback signal exists")
    if director.has_signal("calibration_feedback_requested"):
        director.calibration_feedback_requested.connect(
            func(id: StringName, instrument_text: String) -> void: feedback.append([id, instrument_text])
        )
    director.initialize(session)
    for candidate_id in CANDIDATES:
        session.acquire_item(candidate_id)
    director.handle_action(&"act00.action.bench")
    for slot_id in SLOTS:
        director.request_place_component(REQUIRED_SLOTS[slot_id], slot_id)
    suite.expect_equal(director.phase, DirectorScript.Phase.CALIBRATION, "diagnostic fixture enters calibration")
    suite.expect_true(_has_property(director, "last_calibration_feedback_id"), "feedback ID property exists")
    suite.expect_equal(_property_or_empty(director, "last_calibration_feedback_id"), StringName(), "feedback ID initializes empty")

    var wrong_count := 0
    var initial_observation_count := observations.size()
    for spatial in range(-2, 3):
        for temporal in range(-2, 3):
            if spatial == 0 and temporal == 1:
                continue
            wrong_count += 1
            director.update_calibration(spatial, temporal)
            var expected := Vector2i(signi(spatial), signi(temporal - 1))
            suite.expect_true(director.has_method("calibration_relation"), "calibration relation method exists")
            if director.has_method("calibration_relation"):
                suite.expect_equal(director.calibration_relation(), expected, "signed relation")
            suite.expect_true(not director.pull_lever(), "wrong pair remains recoverable")
            suite.expect_equal(director.phase, DirectorScript.Phase.CALIBRATION, "wrong pair remains in calibration")
            suite.expect_equal(_property_or_empty(director, "last_calibration_feedback_id"), DIAGNOSTICS[expected], "exact diagnosis")
            _expect_last_observation(suite, observations, DIAGNOSTICS[expected], "diagnostic observation emitted")
            suite.expect_equal(
                observations.size(),
                initial_observation_count + wrong_count,
                "each wrong setting emits one diagnostic observation"
            )
            suite.expect_equal(
                feedback.size(),
                wrong_count,
                "each wrong setting emits one instrument update"
            )
            suite.expect_true(not feedback.is_empty(), "calibration feedback emitted")
            if not feedback.is_empty():
                suite.expect_equal(feedback[-1], [DIAGNOSTICS[expected], INSTRUMENT_TEXT[expected]], "exact instrument feedback")
    suite.expect_equal(wrong_count, 24, "all twenty-four wrong settings exercised")
    suite.expect_true(session.has_journal_entry(&"act00.journal.misfire"), "misfire journal is added")
    var journal_count := session.journal_entry_ids().size()
    director.update_calibration(0, 1)
    suite.expect_true(director.pull_lever(), "sole correct calibration succeeds")
    suite.expect_equal(director.phase, DirectorScript.Phase.EXCURSION, "correct calibration starts excursion")
    suite.expect_equal(_property_or_empty(director, "last_calibration_feedback_id"), StringName(), "success resets feedback ID")
    director.complete_excursion()
    director.acknowledge_return()
    suite.expect_equal(session.journal_entry_ids().size(), journal_count + 1, "success adds one journal")
    director.free()
    session.free()


func _expect_last_observation(
    suite: TestSuite,
    observations: Array[StringName],
    expected: StringName,
    message: String
) -> void:
    suite.expect_true(not observations.is_empty(), "%s emitted" % message)
    if not observations.is_empty():
        suite.expect_equal(observations[-1], expected, message)


func _last_or_empty(observations: Array[StringName]) -> StringName:
    if observations.is_empty():
        return StringName()
    return observations[-1]


func _has_property(object: Object, property_name: String) -> bool:
    for property in object.get_property_list():
        if property.name == property_name:
            return true
    return false


func _property_or_empty(object: Object, property_name: String) -> Variant:
    if not _has_property(object, property_name):
        return StringName()
    return object.get(property_name)


func _test_excursion_and_completion_guards(suite: TestSuite) -> void:
    var session := SessionScript.new()
    var director := DirectorScript.new()
    var observations: Array[StringName] = []
    director.observation_requested.connect(func(id: StringName) -> void: observations.append(id))
    director.initialize(session)
    for candidate_id in CANDIDATES:
        session.acquire_item(candidate_id)
    director.handle_action(&"act00.action.bench")
    for slot_id in SLOTS:
        director.request_place_component(REQUIRED_SLOTS[slot_id], slot_id)
    director.update_calibration(0, 1)
    suite.expect_true(director.pull_lever(), "guard fixture reaches excursion")
    var before_items := session.item_ids()
    var before_journals := session.journal_entry_ids()
    var before_observations := observations.size()
    var before_slots := director.placed_slots()
    suite.expect_true(
        not director.request_place_component(
            &"act00.item.brass_rails",
            &"act00.slot.ivory_guides"
        ),
        "excursion ignores direct placement requests"
    )
    director.handle_action(&"act00.action.collect_guides_and_rails")
    director.handle_action(&"act00.action.notebook")
    director.handle_action(&"act00.action.bench")
    director.update_calibration(2, -2)
    suite.expect_equal(session.item_ids(), before_items, "excursion ignores collection")
    suite.expect_equal(session.journal_entry_ids(), before_journals, "excursion ignores clue journal")
    suite.expect_equal(observations.size(), before_observations, "excursion ignores observations")
    suite.expect_equal(director.placed_slots(), before_slots, "excursion preserves placements")
    suite.expect_equal(director.spatial_alignment, 0, "excursion ignores calibration updates")
    suite.expect_true(director.complete_excursion(), "excursion completion is preserved")
    before_observations = observations.size()
    suite.expect_true(
        not director.request_place_component(
            &"act00.item.ivory_guides",
            &"act00.slot.ivory_guides"
        ),
        "complete ignores direct placement requests"
    )
    director.handle_action(&"act00.action.displacement_rig")
    director.handle_action(&"act00.action.clock")
    director.update_calibration(-2, 2)
    suite.expect_equal(observations.size(), before_observations, "complete ignores interactions")
    suite.expect_equal(director.spatial_alignment, 0, "complete ignores calibration updates")
    suite.expect_equal(director.temporal_bias, 1, "complete preserves successful calibration")
    suite.expect_true(director.acknowledge_return(), "return acknowledgement remains available")
    suite.expect_true(not director.acknowledge_return(), "return acknowledgement remains idempotent")
    director.free()
    session.free()
