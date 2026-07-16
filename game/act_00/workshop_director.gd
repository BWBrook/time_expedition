class_name WorkshopDirector
extends Node

signal observation_requested(id: StringName)
signal phase_changed(next_phase: Phase)
signal workbench_requested
signal excursion_requested
signal chapter_completed
signal return_acknowledged
signal calibration_feedback_requested(id: StringName, instrument_text: String)

enum Phase {
    DISCOVERY,
    ASSEMBLY,
    CALIBRATION,
    EXCURSION,
    COMPLETE,
}

const ALL_CANDIDATES: Array[StringName] = [
    &"act00.item.ivory_guides",
    &"act00.item.brass_rails",
    &"act00.item.crystal_prism",
    &"act00.item.smoked_lens",
    &"act00.item.control_levers",
    &"act00.item.clockwork_escapement",
]

const REQUIRED_SLOTS := {
    &"act00.slot.ivory_guides": &"act00.item.ivory_guides",
    &"act00.slot.crystal_prism": &"act00.item.crystal_prism",
    &"act00.slot.control_levers": &"act00.item.control_levers",
}

const COLLECTIONS := {
    &"act00.action.collect_guides_and_rails": [
        [&"act00.item.ivory_guides", &"act00.item.brass_rails"],
        &"act00.observation.take_guides",
        &"act00.observation.guides_taken",
    ],
    &"act00.action.collect_prism_and_lens": [
        [&"act00.item.crystal_prism", &"act00.item.smoked_lens"],
        &"act00.observation.take_prism",
        &"act00.observation.prism_taken",
    ],
    &"act00.action.collect_levers_and_escapement": [
        [&"act00.item.control_levers", &"act00.item.clockwork_escapement"],
        &"act00.observation.take_levers",
        &"act00.observation.levers_taken",
    ],
}

const OPTIONAL_OBSERVATIONS := {
    &"act00.action.diagrams": [&"act00.observation.diagrams", &"act00.observation.diagrams_repeat"],
    &"act00.action.glassware": [&"act00.observation.glassware", &"act00.observation.glassware_repeat"],
    &"act00.action.window": [&"act00.observation.window", &"act00.observation.window_repeat"],
    &"act00.action.gas_lamp": [&"act00.observation.gas_lamp", &"act00.observation.gas_lamp_repeat"],
    &"act00.action.drafting_stool": [&"act00.observation.drafting_stool", &"act00.observation.drafting_stool_repeat"],
    &"act00.action.specimen_cabinet": [&"act00.observation.specimen_cabinet", &"act00.observation.specimen_cabinet_repeat"],
}

const REJECTION_OBSERVATIONS := {
    &"act00.item.ivory_guides": {
        &"act00.slot.crystal_prism": &"act00.observation.reject.ivory_guides.crystal_prism",
        &"act00.slot.control_levers": &"act00.observation.reject.ivory_guides.control_levers",
    },
    &"act00.item.brass_rails": {
        &"act00.slot.ivory_guides": &"act00.observation.reject.brass_rails.ivory_guides",
        &"act00.slot.crystal_prism": &"act00.observation.reject.brass_rails.crystal_prism",
        &"act00.slot.control_levers": &"act00.observation.reject.brass_rails.control_levers",
    },
    &"act00.item.crystal_prism": {
        &"act00.slot.ivory_guides": &"act00.observation.reject.crystal_prism.ivory_guides",
        &"act00.slot.control_levers": &"act00.observation.reject.crystal_prism.control_levers",
    },
    &"act00.item.smoked_lens": {
        &"act00.slot.ivory_guides": &"act00.observation.reject.smoked_lens.ivory_guides",
        &"act00.slot.crystal_prism": &"act00.observation.reject.smoked_lens.crystal_prism",
        &"act00.slot.control_levers": &"act00.observation.reject.smoked_lens.control_levers",
    },
    &"act00.item.control_levers": {
        &"act00.slot.ivory_guides": &"act00.observation.reject.control_levers.ivory_guides",
        &"act00.slot.crystal_prism": &"act00.observation.reject.control_levers.crystal_prism",
    },
    &"act00.item.clockwork_escapement": {
        &"act00.slot.ivory_guides": &"act00.observation.reject.clockwork_escapement.ivory_guides",
        &"act00.slot.crystal_prism": &"act00.observation.reject.clockwork_escapement.crystal_prism",
        &"act00.slot.control_levers": &"act00.observation.reject.clockwork_escapement.control_levers",
    },
}

const CALIBRATION_DIAGNOSTICS := {
    Vector2i(-1, -1): &"act00.observation.misfire.left_slow",
    Vector2i(-1, 0): &"act00.observation.misfire.left_correct",
    Vector2i(-1, 1): &"act00.observation.misfire.left_fast",
    Vector2i(0, -1): &"act00.observation.misfire.centred_slow",
    Vector2i(0, 1): &"act00.observation.misfire.centred_fast",
    Vector2i(1, -1): &"act00.observation.misfire.right_slow",
    Vector2i(1, 0): &"act00.observation.misfire.right_correct",
    Vector2i(1, 1): &"act00.observation.misfire.right_fast",
}

const CALIBRATION_INSTRUMENT_TEXT := {
    Vector2i(-1, -1): "FIELD: LEFT | RATE: SLOW",
    Vector2i(-1, 0): "FIELD: LEFT | RATE: CORRECT",
    Vector2i(-1, 1): "FIELD: LEFT | RATE: FAST",
    Vector2i(0, -1): "FIELD: CENTRED | RATE: SLOW",
    Vector2i(0, 1): "FIELD: CENTRED | RATE: FAST",
    Vector2i(1, -1): "FIELD: RIGHT | RATE: SLOW",
    Vector2i(1, 0): "FIELD: RIGHT | RATE: CORRECT",
    Vector2i(1, 1): "FIELD: RIGHT | RATE: FAST",
}

var phase := Phase.DISCOVERY
var spatial_alignment := 0
var temporal_bias := 0
var last_calibration_feedback_id := StringName()
var _session: Node
var _placed_slots := {}
var _observed_actions := {}
var _return_acknowledgement_pending := false

func initialize(session: Node) -> void:
    _session = session
    phase = Phase.DISCOVERY
    spatial_alignment = 0
    temporal_bias = 0
    last_calibration_feedback_id = StringName()
    _placed_slots.clear()
    _observed_actions.clear()
    _return_acknowledgement_pending = false


func handle_action(action_id: StringName) -> void:
    if phase == Phase.EXCURSION or phase == Phase.COMPLETE:
        return

    if COLLECTIONS.has(action_id):
        var values: Array = COLLECTIONS[action_id]
        _collect_pair(values[0], values[1], values[2])
        return

    if OPTIONAL_OBSERVATIONS.has(action_id):
        var optional_values: Array = OPTIONAL_OBSERVATIONS[action_id]
        _emit_first_or_repeat(action_id, optional_values[0], optional_values[1])
        return

    match action_id:
        &"act00.action.notebook":
            _session.add_journal_entry(&"act00.journal.experiment")
            if phase == Phase.CALIBRATION:
                observation_requested.emit(&"act00.observation.notebook_calibration")
            elif _has_calibration_datum():
                observation_requested.emit(&"act00.observation.notebook_after_datum")
            else:
                observation_requested.emit(&"act00.observation.notebook")
        &"act00.action.bench":
            if phase == Phase.DISCOVERY:
                _set_phase(Phase.ASSEMBLY)
            if phase == Phase.CALIBRATION:
                observation_requested.emit(&"act00.observation.bench_calibration")
            else:
                observation_requested.emit(
                    &"act00.observation.bench_ready"
                    if _all_items_acquired()
                    else &"act00.observation.bench_missing"
                )
            workbench_requested.emit()
        &"act00.action.clock":
            _emit_first_or_repeat(
                action_id,
                &"act00.observation.clock",
                &"act00.observation.clock_repeat"
            )
            _session.add_journal_entry(&"act00.journal.temporal_datum")
        &"act00.action.spirit_level":
            _emit_first_or_repeat(
                action_id,
                &"act00.observation.spirit_level",
                &"act00.observation.spirit_level_repeat"
            )
            _session.add_journal_entry(&"act00.journal.spatial_datum")
        &"act00.action.displacement_rig":
            observation_requested.emit(
                &"act00.observation.displacement_rig_calibration"
                if phase == Phase.CALIBRATION
                else &"act00.observation.displacement_rig"
            )


func request_place_component(item_id: StringName, slot_id: StringName) -> bool:
    if phase == Phase.EXCURSION or phase == Phase.COMPLETE:
        return false
    if phase == Phase.CALIBRATION:
        if _placed_slots.get(slot_id) == item_id:
            return true
        _emit_slot_rejection(item_id, slot_id)
        return false
    if phase != Phase.ASSEMBLY:
        observation_requested.emit(&"act00.observation.wrong_slot")
        return false
    if _placed_slots.get(slot_id) == item_id:
        return true

    if REQUIRED_SLOTS.get(slot_id) != item_id or not _session.has_item(item_id):
        _emit_slot_rejection(item_id, slot_id)
        return false
    if _placed_slots.values().has(item_id):
        _emit_slot_rejection(item_id, slot_id)
        return false

    _placed_slots[slot_id] = item_id
    _session.set_flag(StringName("act00.flag.placed.%s" % String(slot_id).get_slice(".", 2)), true)
    observation_requested.emit(&"act00.observation.component_fitted")
    if _placed_slots.size() == REQUIRED_SLOTS.size():
        _session.add_journal_entry(&"act00.journal.calibration")
        observation_requested.emit(&"act00.observation.assembly_complete")
        _set_phase(Phase.CALIBRATION)
    return true


func update_calibration(next_spatial_alignment: int, next_temporal_bias: int) -> void:
    if phase != Phase.CALIBRATION:
        return
    spatial_alignment = clampi(next_spatial_alignment, -2, 2)
    temporal_bias = clampi(next_temporal_bias, -2, 2)


func calibration_relation() -> Vector2i:
    return Vector2i(signi(spatial_alignment), signi(temporal_bias - 1))


func pull_lever() -> bool:
    if phase != Phase.CALIBRATION:
        if phase == Phase.DISCOVERY or phase == Phase.ASSEMBLY:
            observation_requested.emit(&"act00.observation.bench_missing")
        return false
    if _placed_slots.size() != REQUIRED_SLOTS.size():
        observation_requested.emit(&"act00.observation.bench_missing")
        return false
    if spatial_alignment != 0 or temporal_bias != 1:
        var relation := calibration_relation()
        last_calibration_feedback_id = CALIBRATION_DIAGNOSTICS[relation]
        _session.add_journal_entry(&"act00.journal.misfire")
        observation_requested.emit(last_calibration_feedback_id)
        calibration_feedback_requested.emit(
            last_calibration_feedback_id,
            CALIBRATION_INSTRUMENT_TEXT[relation]
        )
        return false

    last_calibration_feedback_id = StringName()
    observation_requested.emit(&"act00.observation.excursion")
    _set_phase(Phase.EXCURSION)
    excursion_requested.emit()
    return true


func complete_excursion() -> bool:
    if phase != Phase.EXCURSION:
        return false
    _session.add_journal_entry(&"act00.journal.success")
    _set_phase(Phase.COMPLETE)
    _return_acknowledgement_pending = true
    observation_requested.emit(&"act00.observation.return")
    return true


func acknowledge_return() -> bool:
    if phase != Phase.COMPLETE or not _return_acknowledgement_pending:
        return false
    _return_acknowledgement_pending = false
    return_acknowledged.emit()
    chapter_completed.emit()
    return true


func placed_slots() -> Dictionary:
    return _placed_slots.duplicate()


func all_items_acquired() -> bool:
    return _all_items_acquired()


func _collect_pair(
    item_ids: Array,
    acquired_observation: StringName,
    repeated_observation: StringName
) -> void:
    var acquired := false
    for item_id in item_ids:
        if _session.acquire_item(item_id):
            acquired = true
    if acquired:
        observation_requested.emit(acquired_observation)
        if _all_items_acquired():
            _session.add_journal_entry(&"act00.journal.components")
    else:
        observation_requested.emit(repeated_observation)


func _emit_first_or_repeat(
    action_id: StringName,
    first_observation: StringName,
    repeat_observation: StringName
) -> void:
    if _observed_actions.has(action_id):
        observation_requested.emit(repeat_observation)
    else:
        _observed_actions[action_id] = true
        observation_requested.emit(first_observation)


func _emit_slot_rejection(item_id: StringName, slot_id: StringName) -> void:
    if REJECTION_OBSERVATIONS.has(item_id) and REJECTION_OBSERVATIONS[item_id].has(slot_id):
        observation_requested.emit(REJECTION_OBSERVATIONS[item_id][slot_id])
    else:
        observation_requested.emit(&"act00.observation.wrong_slot")


func _all_items_acquired() -> bool:
    for item_id in ALL_CANDIDATES:
        if not _session.has_item(item_id):
            return false
    return true


func _has_calibration_datum() -> bool:
    return (
        _session.has_journal_entry(&"act00.journal.spatial_datum")
        or _session.has_journal_entry(&"act00.journal.temporal_datum")
    )


func _set_phase(next_phase: Phase) -> void:
    if phase == next_phase:
        return
    phase = next_phase
    phase_changed.emit(phase)
