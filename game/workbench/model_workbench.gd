class_name ModelWorkbench
extends Control

signal placement_requested(item_id: StringName, slot_id: StringName)
signal calibration_changed(spatial: int, temporal: int)
signal lever_pulled
signal closed
signal excursion_finished

const ITEM_LABELS := {
    &"act00.item.ivory_guides": "Ivory guides",
    &"act00.item.crystal_prism": "Crystalline prism",
    &"act00.item.control_levers": "Control levers",
}

var _selected_item: StringName
var _placed := {}
var _available_items := {}
var _spatial := 0
var _temporal := 0
var _excursion_active := false

@onready var _tokens: Array[ComponentToken] = [
    $Frame/Margin/Rows/Tray/Guides,
    $Frame/Margin/Rows/Tray/Prism,
    $Frame/Margin/Rows/Tray/Levers,
]
@onready var _slots: Array[ComponentSlot] = [
    $Frame/Margin/Rows/Machine/Slots/GuidesSlot,
    $Frame/Margin/Rows/Machine/Slots/PrismSlot,
    $Frame/Margin/Rows/Machine/Slots/LeversSlot,
]
@onready var _calibration: VBoxContainer = $Frame/Margin/Rows/Calibration
@onready var _spatial_label: Label = $Frame/Margin/Rows/Calibration/Spatial/Value
@onready var _temporal_label: Label = $Frame/Margin/Rows/Calibration/Temporal/Value
@onready var _lever: Button = $Frame/Margin/Rows/Lever
@onready var _status: Label = $Frame/Margin/Rows/Status
@onready var _close: Button = $Frame/Margin/Rows/Header/Close
@onready var _temporal_overlay: ColorRect = $TemporalOverlay
@onready var _temporal_effect: TemporalEffect = $TemporalEffect


func _ready() -> void:
    for token in _tokens:
        token.token_selected.connect(select_item)
    for slot in _slots:
        slot.slot_activated.connect(request_slot)
        slot.drop_requested.connect(_on_drop_requested)
    _close.pressed.connect(dismiss)
    $Frame/Margin/Rows/Calibration/Spatial/Decrease.pressed.connect(
        func() -> void: set_calibration(_spatial - 1, _temporal)
    )
    $Frame/Margin/Rows/Calibration/Spatial/Increase.pressed.connect(
        func() -> void: set_calibration(_spatial + 1, _temporal)
    )
    $Frame/Margin/Rows/Calibration/Temporal/Decrease.pressed.connect(
        func() -> void: set_calibration(_spatial, _temporal - 1)
    )
    $Frame/Margin/Rows/Calibration/Temporal/Increase.pressed.connect(
        func() -> void: set_calibration(_spatial, _temporal + 1)
    )
    _lever.pressed.connect(request_lever)


func open_with_items(
    item_ids: PackedStringArray,
    placed_slots: Dictionary,
    spatial: int,
    temporal: int
) -> void:
    if _excursion_active:
        return
    _selected_item = StringName()
    _available_items.clear()
    for item_id in item_ids:
        var typed_item_id := StringName(item_id)
        if ITEM_LABELS.has(typed_item_id):
            _available_items[typed_item_id] = true
    _placed = _sanitised_placements(placed_slots)
    for slot in _slots:
        slot.reset_slot()
        if _placed.has(slot.slot_id):
            var item_id: StringName = _placed[slot.slot_id]
            slot.set_filled(item_id, ITEM_LABELS[item_id])
    for token in _tokens:
        token.set_available(_available_items.has(token.item_id) and not _placed.values().has(token.item_id))
    set_calibration(spatial, temporal, false)
    _refresh_unlocks()
    if not _calibration.visible:
        _status.text = "Select a component, then its matching fitting."
    visible = true
    _focus_first_available_token()


func select_item(item_id: StringName) -> void:
    if _excursion_active or not _is_selectable_item(item_id):
        return
    _selected_item = item_id
    _status.text = "%s selected." % ITEM_LABELS[item_id]
    for slot in _slots:
        if not slot.disabled and slot.expected_item_id == item_id:
            slot.grab_focus()
            return


func request_slot(slot_id: StringName) -> void:
    if _excursion_active:
        return
    if _selected_item == StringName():
        _status.text = "Select a component first."
        return
    if not _is_empty_known_slot(slot_id):
        return
    placement_requested.emit(_selected_item, slot_id)


func _on_drop_requested(item_id: StringName, slot_id: StringName) -> void:
    if not _excursion_active and _is_selectable_item(item_id) and _is_empty_known_slot(slot_id) and _slot_expects(slot_id, item_id):
        placement_requested.emit(item_id, slot_id)


func apply_placement_result(item_id: StringName, slot_id: StringName, accepted: bool) -> void:
    if not accepted:
        _status.text = "The fitting refuses it."
        return
    if not _available_items.has(item_id) or not _slot_expects(slot_id, item_id):
        return
    if _placed.get(slot_id, StringName()) == item_id:
        return
    if _placed.has(slot_id) or _placed.values().has(item_id):
        return

    _placed[slot_id] = item_id
    var slot := _slot_for(slot_id)
    if slot != null:
        slot.set_filled(item_id, ITEM_LABELS[item_id])
    var token := _token_for(item_id)
    if token != null:
        token.set_available(false)
    _selected_item = StringName()
    _status.text = "The component seats cleanly."
    _refresh_unlocks()
    _focus_first_available_token()


func set_calibration(spatial: int, temporal: int, emit_change := true) -> void:
    if _excursion_active:
        return
    var next_spatial := clampi(spatial, -2, 2)
    var next_temporal := clampi(temporal, -2, 2)
    var changed := next_spatial != _spatial or next_temporal != _temporal
    _spatial = next_spatial
    _temporal = next_temporal
    _spatial_label.text = "%+d" % _spatial
    _temporal_label.text = "%+d" % _temporal
    if emit_change and changed:
        calibration_changed.emit(_spatial, _temporal)


func request_lever() -> void:
    if _excursion_active or _lever.disabled:
        return
    lever_pulled.emit()


func dismiss() -> void:
    if _excursion_active or not visible:
        return
    visible = false
    closed.emit()


func available_token_count() -> int:
    var count := 0
    for token in _tokens:
        if token.visible and not token.disabled:
            count += 1
    return count


func placed_count() -> int:
    return _placed.size()


func calibration_visible() -> bool:
    return _calibration.visible


func lever_enabled() -> bool:
    return not _lever.disabled


func calibration_values() -> Vector2i:
    return Vector2i(_spatial, _temporal)


func show_status(next_text: String) -> void:
    _status.text = next_text


func play_excursion(reduced_motion: bool) -> void:
    if _excursion_active:
        return
    _excursion_active = true
    _set_controls_locked(true)
    _status.text = "For four seconds the bench is indisputably empty."
    await _temporal_effect.play(
        $Frame/Margin/Rows/Machine,
        _temporal_overlay,
        reduced_motion,
        4.0
    )
    _status.text = "The onboard chronometer has advanced fifteen seconds."
    _excursion_active = false
    _set_controls_locked(false)
    excursion_finished.emit()


func excursion_active() -> bool:
    return _excursion_active


func controls_locked() -> bool:
    return _excursion_active


func excursion_target_visible() -> bool:
    return $Frame/Margin/Rows/Machine.visible


func _unhandled_input(event: InputEvent) -> void:
    var key_event := event as InputEventKey
    if visible and key_event != null and key_event.pressed and not key_event.echo:
        if key_event.keycode == KEY_ESCAPE:
            if not _excursion_active:
                dismiss()
                get_viewport().set_input_as_handled()


func _refresh_unlocks() -> void:
    var assembled := _placed.size() == _slots.size()
    _calibration.visible = assembled
    _lever.disabled = not assembled or _excursion_active
    if assembled:
        _status.text = "Spatial equilibrium; temporal bias one division forward."


func _focus_first_available_token() -> void:
    for token in _tokens:
        if token.visible and not token.disabled:
            token.grab_focus()
            return
    if _calibration.visible:
        $Frame/Margin/Rows/Calibration/Spatial/Decrease.grab_focus()


func _set_controls_locked(locked: bool) -> void:
    _close.disabled = locked
    _lever.disabled = locked
    for token in _tokens:
        token.disabled = locked or not token.visible
    for slot in _slots:
        slot.disabled = locked or _placed.has(slot.slot_id)
    for control in [
        $Frame/Margin/Rows/Calibration/Spatial/Decrease,
        $Frame/Margin/Rows/Calibration/Spatial/Increase,
        $Frame/Margin/Rows/Calibration/Temporal/Decrease,
        $Frame/Margin/Rows/Calibration/Temporal/Increase,
    ]:
        control.disabled = locked
    if not locked:
        for token in _tokens:
            token.set_available(_available_items.has(token.item_id) and not _placed.values().has(token.item_id))
        _refresh_unlocks()


func _sanitised_placements(placed_slots: Dictionary) -> Dictionary:
    var valid := {}
    for slot in _slots:
        if not placed_slots.has(slot.slot_id):
            continue
        var item_id := StringName(placed_slots[slot.slot_id])
        if _available_items.has(item_id) and slot.expected_item_id == item_id and not valid.values().has(item_id):
            valid[slot.slot_id] = item_id
    return valid


func _is_selectable_item(item_id: StringName) -> bool:
    return _available_items.has(item_id) and not _placed.values().has(item_id)


func _is_empty_known_slot(slot_id: StringName) -> bool:
    return _slot_for(slot_id) != null and not _placed.has(slot_id)


func _slot_expects(slot_id: StringName, item_id: StringName) -> bool:
    var slot := _slot_for(slot_id)
    return slot != null and slot.expected_item_id == item_id


func _slot_for(slot_id: StringName) -> ComponentSlot:
    for slot in _slots:
        if slot.slot_id == slot_id:
            return slot
    return null


func _token_for(item_id: StringName) -> ComponentToken:
    for token in _tokens:
        if token.item_id == item_id:
            return token
    return null
