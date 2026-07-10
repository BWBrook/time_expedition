class_name InventoryTray
extends PanelContainer

signal closed

var _displayed_count := 0
@onready var _items: HBoxContainer = $Margin/Rows/Items

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
        var column := VBoxContainer.new()
        column.custom_minimum_size = Vector2(240, 0)
        if definition.icon != null:
            var icon := TextureRect.new()
            icon.custom_minimum_size = Vector2(72, 72)
            icon.texture = definition.icon
            icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            column.add_child(icon)
        var title := Label.new()
        title.text = definition.display_name
        title.add_theme_font_size_override("font_size", 18)
        var description := Label.new()
        description.text = definition.description
        description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        column.add_child(title)
        column.add_child(description)
        _items.add_child(column)
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
