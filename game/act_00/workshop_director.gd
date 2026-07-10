class_name WorkshopDirector
extends Node

signal observation_requested(id: StringName)
signal phase_changed(next_phase: Phase)
signal workbench_requested
signal excursion_requested
signal chapter_completed

enum Phase {
    DISCOVERY,
    ASSEMBLY,
    CALIBRATION,
    EXCURSION,
    COMPLETE,
}

const REQUIRED_SLOTS := {
    &"act00.slot.ivory_guides": &"act00.item.ivory_guides",
    &"act00.slot.crystal_prism": &"act00.item.crystal_prism",
    &"act00.slot.control_levers": &"act00.item.control_levers",
}

const COLLECTIONS := {
    &"act00.action.collect_guides": [
        &"act00.item.ivory_guides",
        &"act00.observation.take_guides",
        &"act00.observation.guides_taken",
    ],
    &"act00.action.collect_prism": [
        &"act00.item.crystal_prism",
        &"act00.observation.take_prism",
        &"act00.observation.prism_taken",
    ],
    &"act00.action.collect_levers": [
        &"act00.item.control_levers",
        &"act00.observation.take_levers",
        &"act00.observation.levers_taken",
    ],
}

var phase := Phase.DISCOVERY
var spatial_alignment := 0
var temporal_bias := 0
var _session: Node
var _placed_slots := {}

func initialize(session: Node) -> void:
    _session = session
    phase = Phase.DISCOVERY
    spatial_alignment = 0
    temporal_bias = 0
    _placed_slots.clear()

func handle_action(action_id: StringName) -> void:
    if phase == Phase.EXCURSION or phase == Phase.COMPLETE:
        return

    if COLLECTIONS.has(action_id):
        var values: Array = COLLECTIONS[action_id]
        _collect_item(values[0], values[1], values[2])
        return

    match action_id:
        &"act00.action.notebook":
            _session.add_journal_entry(&"act00.journal.experiment")
            observation_requested.emit(&"act00.observation.notebook")
        &"act00.action.bench":
            if phase == Phase.DISCOVERY:
                _set_phase(Phase.ASSEMBLY)
            observation_requested.emit(
                &"act00.observation.bench_ready"
                if _all_items_acquired()
                else &"act00.observation.bench_missing"
            )
            workbench_requested.emit()
        &"act00.action.clock":
            observation_requested.emit(&"act00.observation.clock")
        &"act00.action.window":
            observation_requested.emit(&"act00.observation.window")
        &"act00.action.apparatus":
            observation_requested.emit(&"act00.observation.apparatus")

func request_place_component(item_id: StringName, slot_id: StringName) -> bool:
    if phase == Phase.CALIBRATION:
        return _placed_slots.get(slot_id) == item_id
    if phase != Phase.ASSEMBLY:
        observation_requested.emit(&"act00.observation.wrong_slot")
        return false
    if _placed_slots.get(slot_id) == item_id:
        return true
    if REQUIRED_SLOTS.get(slot_id) != item_id or not _session.has_item(item_id):
        observation_requested.emit(&"act00.observation.wrong_slot")
        return false
    if _placed_slots.values().has(item_id):
        observation_requested.emit(&"act00.observation.wrong_slot")
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

func pull_lever() -> bool:
    if phase != Phase.CALIBRATION:
        if phase == Phase.DISCOVERY or phase == Phase.ASSEMBLY:
            observation_requested.emit(&"act00.observation.bench_missing")
        return false
    if _placed_slots.size() != REQUIRED_SLOTS.size():
        observation_requested.emit(&"act00.observation.bench_missing")
        return false
    if spatial_alignment != 0 or temporal_bias != 1:
        _session.add_journal_entry(&"act00.journal.misfire")
        observation_requested.emit(&"act00.observation.misfire")
        return false

    observation_requested.emit(&"act00.observation.excursion")
    _set_phase(Phase.EXCURSION)
    excursion_requested.emit()
    return true

func complete_excursion() -> bool:
    if phase != Phase.EXCURSION:
        return false
    _session.add_journal_entry(&"act00.journal.success")
    observation_requested.emit(&"act00.observation.return")
    _set_phase(Phase.COMPLETE)
    chapter_completed.emit()
    return true

func placed_slots() -> Dictionary:
    return _placed_slots.duplicate()

func all_items_acquired() -> bool:
    return _all_items_acquired()

func _collect_item(
    item_id: StringName,
    acquired_observation: StringName,
    repeated_observation: StringName
) -> void:
    if _session.acquire_item(item_id):
        observation_requested.emit(acquired_observation)
        if _all_items_acquired():
            _session.add_journal_entry(&"act00.journal.components")
        return
    observation_requested.emit(repeated_observation)

func _all_items_acquired() -> bool:
    for item_id in REQUIRED_SLOTS.values():
        if not _session.has_item(item_id):
            return false
    return true

func _set_phase(next_phase: Phase) -> void:
    if phase == next_phase:
        return
    phase = next_phase
    phase_changed.emit(phase)
