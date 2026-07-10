class_name JournalOverlay
extends ColorRect

signal closed

var _displayed_count := 0
@onready var _entries: VBoxContainer = $Frame/Margin/Rows/Pages/EntryScroll/Entries
@onready var _sketch: Label = $Frame/Margin/Rows/Pages/Sketch

func _ready() -> void:
    $Frame/Margin/Rows/Header/Close.pressed.connect(close)

func populate(entry_ids: PackedStringArray, registry: Node) -> void:
    for child in _entries.get_children():
        child.free()
    _displayed_count = 0
    if registry == null:
        return
    for id_text in entry_ids:
        var definition := registry.get_journal_entry(StringName(id_text)) as JournalEntryDefinition
        if definition == null:
            push_error("Missing journal entry: %s" % id_text)
            continue
        var title := Label.new()
        title.text = definition.title
        title.add_theme_font_size_override("font_size", 19)
        var body := Label.new()
        body.text = definition.body
        body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        _entries.add_child(title)
        _entries.add_child(body)
        _displayed_count += 1
    _sketch.text = (
        "EXPERIMENT SKETCH\n\n"
        + "Spatial axes: equilibrium (0)\n"
        + "Temporal bias: one division forward (+1)\n\n"
        + "White lever: departure"
    )

func open() -> void:
    visible = true
    $Frame/Margin/Rows/Header/Close.grab_focus()

func close() -> void:
    if not visible:
        return
    visible = false
    closed.emit()

func displayed_count() -> int:
    return _displayed_count
