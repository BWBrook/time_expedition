class_name InventoryTray
extends PanelContainer

signal closed

var _displayed_count := 0
@onready var _items: GridContainer = $Margin/Rows/Items

func _ready() -> void:
    $Margin/Rows/Header/Close.pressed.connect(close)

func populate(item_ids: PackedStringArray, registry: Node) -> void:
    for child in _items.get_children():
        child.free()
    _displayed_count = 0
    if registry == null:
        return
    for id_text in item_ids:
        var definition := registry.get_item(StringName(id_text)) as ItemDefinition
        if definition == null:
            push_error("Missing inventory item: %s" % id_text)
            continue
        var cell := HBoxContainer.new()
        cell.custom_minimum_size = Vector2(300, 118)
        cell.add_theme_constant_override("separation", 12)

        var icon := TextureRect.new()
        icon.name = "Icon"
        icon.custom_minimum_size = Vector2(56, 56)
        icon.texture = definition.icon
        icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        cell.add_child(icon)

        var text_column := VBoxContainer.new()
        text_column.name = "Text"
        text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        text_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
        text_column.custom_minimum_size = Vector2(0, 118)
        text_column.add_theme_constant_override("separation", 2)
        var title := Label.new()
        title.name = "Title"
        title.text = definition.display_name
        title.add_theme_font_size_override("font_size", 16)
        var description := Label.new()
        description.name = "Description"
        description.text = definition.description
        description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        description.size_flags_vertical = Control.SIZE_EXPAND_FILL
        description.add_theme_font_size_override("font_size", 14)
        text_column.add_child(title)
        text_column.add_child(description)
        cell.add_child(text_column)
        _items.add_child(cell)
        _displayed_count += 1

func open() -> void:
    visible = true
    $Margin/Rows/Header/Close.grab_focus()

func close() -> void:
    if not visible:
        return
    visible = false
    closed.emit()

func displayed_count() -> int:
    return _displayed_count

func column_count() -> int:
    return _items.columns

func maximum_cell_width() -> float:
    var maximum := 0.0
    for child in _items.get_children():
        maximum = maxf(maximum, child.size.x)
    return maximum


func content_fits_bounds() -> bool:
    return _items.get_global_rect().end.y <= get_global_rect().end.y + 0.5
