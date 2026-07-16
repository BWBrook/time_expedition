extends RefCounted

const EXPECTED_SIZES := {
    "res://assets/art/act_00/workshop_background.png": Vector2i(3200, 720),
    "res://assets/art/act_00/time_traveller_strip.png": Vector2i(2048, 512),
    "res://assets/art/act_00/workbench_background.png": Vector2i(1280, 720),
    "res://assets/art/act_00/model_frame.png": Vector2i(1024, 300),
    "res://assets/art/act_00/model_cloth.png": Vector2i(1024, 300),
    "res://assets/art/act_00/ivory_guides.png": Vector2i(256, 256),
    "res://assets/art/act_00/brass_rails.png": Vector2i(256, 256),
    "res://assets/art/act_00/crystal_prism.png": Vector2i(256, 256),
    "res://assets/art/act_00/smoked_lens.png": Vector2i(256, 256),
    "res://assets/art/act_00/control_levers.png": Vector2i(256, 256),
    "res://assets/art/act_00/clockwork_escapement.png": Vector2i(256, 256),
    "res://assets/art/act_00/journal_icon.png": Vector2i(256, 256),
    "res://assets/art/act_00/inventory_icon.png": Vector2i(256, 256),
}

const SOURCE_PLATES := [
    "res://assets/art/act_00/source/workshop_master.png",
    "res://assets/art/act_00/source/time_traveller_master.png",
    "res://assets/art/act_00/source/workbench_master.png",
    "res://assets/art/act_00/source/model_frame_master.png",
    "res://assets/art/act_00/source/model_cloth_master.png",
    "res://assets/art/act_00/source/icon_strip_master.png",
]

const SOURCE_VECTORS := [
    "res://assets/art/act_00/source/brass_rails.svg",
    "res://assets/art/act_00/source/smoked_lens.svg",
    "res://assets/art/act_00/source/clockwork_escapement.svg",
]

const ITEM_ICON_PATHS := {
    &"act00.item.ivory_guides": "res://assets/art/act_00/ivory_guides.png",
    &"act00.item.brass_rails": "res://assets/art/act_00/brass_rails.png",
    &"act00.item.crystal_prism": "res://assets/art/act_00/crystal_prism.png",
    &"act00.item.smoked_lens": "res://assets/art/act_00/smoked_lens.png",
    &"act00.item.control_levers": "res://assets/art/act_00/control_levers.png",
    &"act00.item.clockwork_escapement": "res://assets/art/act_00/clockwork_escapement.png",
}

const WORKBENCH_TOKEN_PATHS := {
    "Guides": "res://assets/art/act_00/ivory_guides.png",
    "BrassRails": "res://assets/art/act_00/brass_rails.png",
    "Prism": "res://assets/art/act_00/crystal_prism.png",
    "SmokedLens": "res://assets/art/act_00/smoked_lens.png",
    "Levers": "res://assets/art/act_00/control_levers.png",
    "Escapement": "res://assets/art/act_00/clockwork_escapement.png",
}

const CURRENT_WORKBENCH_TOKEN_PATHS := {
    "Guides": "res://assets/art/act_00/ivory_guides.png",
    "Prism": "res://assets/art/act_00/crystal_prism.png",
    "Levers": "res://assets/art/act_00/control_levers.png",
}

const FOREGROUND_COVERAGE := {
    "res://assets/art/act_00/time_traveller_strip.png": Vector2(0.03, 0.65),
    "res://assets/art/act_00/model_frame.png": Vector2(0.015, 0.55),
    "res://assets/art/act_00/model_cloth.png": Vector2(0.08, 0.65),
    "res://assets/art/act_00/ivory_guides.png": Vector2(0.025, 0.65),
    "res://assets/art/act_00/brass_rails.png": Vector2(0.025, 0.65),
    "res://assets/art/act_00/crystal_prism.png": Vector2(0.025, 0.65),
    "res://assets/art/act_00/smoked_lens.png": Vector2(0.025, 0.65),
    "res://assets/art/act_00/control_levers.png": Vector2(0.025, 0.65),
    "res://assets/art/act_00/clockwork_escapement.png": Vector2(0.025, 0.65),
    "res://assets/art/act_00/journal_icon.png": Vector2(0.025, 0.65),
    "res://assets/art/act_00/inventory_icon.png": Vector2(0.025, 0.65),
}

const MANIFEST_PATH := "res://game/content/act_00/act_00_manifest.tres"
const PLAYER_SCENE_PATH := "res://game/player/player.tscn"
const WORKSHOP_SCENE_PATH := "res://game/act_00/workshop.tscn"
const WORKBENCH_SCENE_PATH := "res://game/workbench/model_workbench.tscn"
const HUD_SCENE_PATH := "res://game/ui/game_hud.tscn"
const INVENTORY_TRAY_SCENE_PATH := "res://game/ui/inventory_tray.tscn"
const CONTENT_REGISTRY_SCRIPT := preload("res://game/content/content_registry.gd")
const PROVENANCE_PATH := "res://assets/art/act_00/ASSET_PROVENANCE.md"
const ART_REQUIREMENTS_PATH := "res://requirements-art.txt"
const CHROMA_HELPER_PATH := "res://tools/remove_chroma_key.py"
const ART_PROCESSOR_PATH := "res://tools/process_art.sh"

const ALPHA_OPAQUE := 0.85
const CORNER_ALPHA_MAX := 0.03
const SAMPLE_STRIDE := 4
const MAX_FRINGE_FRACTION := 0.002
const TRAVELLER_CELL_SIZE := Vector2i(512, 512)
const TRAVELLER_EDGE_PADDING := 8
const MAX_BASELINE_DELTA := 6

const WORKSHOP_ART_ANCHORS := {
    "Notebook": {"area": Vector2(260, 560), "focus": Vector2(0, -130)},
    "Drawer": {"area": Vector2(850, 560), "focus": Vector2(0, -130)},
    "Clock": {"area": Vector2(1150, 560), "focus": Vector2(0, -310)},
    "Bench": {"area": Vector2(1580, 540), "focus": Vector2(0, -180)},
    "Window": {"area": Vector2(2050, 560), "focus": Vector2(0, -280)},
    "Prism": {"area": Vector2(2300, 560), "focus": Vector2(0, -90)},
    "Levers": {"area": Vector2(2620, 560), "focus": Vector2(0, -90)},
    "Apparatus": {"area": Vector2(2820, 530), "focus": Vector2(0, -120)},
}


func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    _test_runtime_assets(suite)
    _test_foreground_alpha(suite)
    _test_icon_neighbor_fragments(suite)
    _test_traveller_cells(suite)
    _test_manifest_icon_bindings(suite)
    _test_workbench_token_path_contract(suite)
    _test_player_atlas(suite)
    _test_scene_bindings(suite)
    await _test_inventory_icon_population(suite, tree)
    _test_provenance(suite)
    _test_repo_owned_art_processor(suite)


func _test_runtime_assets(suite: TestSuite) -> void:
    for path_value in EXPECTED_SIZES:
        var path := String(path_value)
        var expected: Vector2i = EXPECTED_SIZES[path]
        suite.expect_true(FileAccess.file_exists(path), "%s runtime PNG exists" % path)
        _test_import_metadata(suite, path)
        if not FileAccess.file_exists(path):
            continue

        var image := Image.new()
        var error := image.load(ProjectSettings.globalize_path(path))
        suite.expect_equal(error, OK, "%s decodes as PNG" % path)
        if error == OK:
            suite.expect_equal(image.get_size(), expected, "%s source dimensions" % path)

        var texture := ResourceLoader.load(path) as Texture2D
        suite.expect_not_null(texture, "%s imports as Texture2D" % path)
        if texture != null:
            suite.expect_equal(
                Vector2i(texture.get_width(), texture.get_height()),
                expected,
                "%s runtime dimensions" % path
            )


func _test_import_metadata(suite: TestSuite, path: String) -> void:
    var import_path := "%s.import" % path
    suite.expect_true(FileAccess.file_exists(import_path), "%s import metadata exists" % import_path)
    if not FileAccess.file_exists(import_path):
        return
    var contents := FileAccess.get_file_as_string(import_path)
    for required in [
        "[remap]",
        "importer=\"texture\"",
        "type=\"CompressedTexture2D\"",
        "[deps]",
        "source_file=\"%s\"" % path,
        "dest_files=[",
        "[params]",
    ]:
        suite.expect_true(contents.contains(required), "%s contains %s" % [import_path, required])


func _test_foreground_alpha(suite: TestSuite) -> void:
    for path_value in FOREGROUND_COVERAGE:
        var path := String(path_value)
        if not FileAccess.file_exists(path):
            continue
        var image := _load_image(suite, path)
        if image == null:
            continue
        suite.expect_true(image.detect_alpha() != Image.ALPHA_NONE, "%s has an alpha channel" % path)
        _test_transparent_corners(suite, image, path)
        _test_coverage_and_fringe(suite, image, path)


func _test_transparent_corners(suite: TestSuite, image: Image, path: String) -> void:
    var last_x := image.get_width() - 1
    var last_y := image.get_height() - 1
    for point in [Vector2i(0, 0), Vector2i(last_x, 0), Vector2i(0, last_y), Vector2i(last_x, last_y)]:
        suite.expect_true(
            image.get_pixel(point.x, point.y).a <= CORNER_ALPHA_MAX,
            "%s corner %s is transparent" % [path, point]
        )


func _test_coverage_and_fringe(suite: TestSuite, image: Image, path: String) -> void:
    var opaque := 0
    var samples := 0
    var fringe_pixels := 0
    for y in range(0, image.get_height(), SAMPLE_STRIDE):
        for x in range(0, image.get_width(), SAMPLE_STRIDE):
            var pixel := image.get_pixel(x, y)
            samples += 1
            if pixel.a >= ALPHA_OPAQUE:
                opaque += 1
            if _looks_like_key_fringe(pixel):
                fringe_pixels += 1

    var coverage := float(opaque) / float(samples)
    var limits: Vector2 = FOREGROUND_COVERAGE[path]
    suite.expect_true(coverage >= limits.x, "%s alpha coverage exceeds %.3f" % [path, limits.x])
    suite.expect_true(coverage <= limits.y, "%s alpha coverage stays below %.3f" % [path, limits.y])
    var fringe_limit := maxi(10, int(ceil(float(samples) * MAX_FRINGE_FRACTION)))
    suite.expect_true(
        fringe_pixels <= fringe_limit,
        "%s has no obvious chroma-key fringe (%d <= %d sampled pixels)" % [path, fringe_pixels, fringe_limit]
    )


func _looks_like_key_fringe(pixel: Color) -> bool:
    var green_fringe := (
        pixel.a > CORNER_ALPHA_MAX
        and pixel.a < ALPHA_OPAQUE
        and pixel.g >= 0.45
        and pixel.g > pixel.r * 1.35
        and pixel.g > pixel.b * 1.35
    )
    var magenta_fringe := (
        pixel.a > CORNER_ALPHA_MAX
        and pixel.a < ALPHA_OPAQUE
        and pixel.r >= 0.45
        and pixel.b >= 0.45
        and pixel.g < mini(pixel.r, pixel.b) * 0.7
    )
    return green_fringe or magenta_fringe


func _test_icon_neighbor_fragments(suite: TestSuite) -> void:
    _expect_transparent_region(
        suite,
        "res://assets/art/act_00/control_levers.png",
        Rect2i(205, 0, 51, 256),
        "control-lever neighbor mask"
    )
    _expect_transparent_region(
        suite,
        "res://assets/art/act_00/journal_icon.png",
        Rect2i(210, 0, 46, 256),
        "journal neighbor mask"
    )
    _expect_transparent_region(
        suite,
        "res://assets/art/act_00/journal_icon.png",
        Rect2i(203, 90, 7, 119),
        "journal detached neighbor fragment"
    )


func _expect_transparent_region(
    suite: TestSuite,
    path: String,
    region: Rect2i,
    label: String
) -> void:
    var image := _load_image(suite, path)
    if image == null:
        return
    var opaque_pixels := 0
    for y in range(region.position.y, region.end.y):
        for x in range(region.position.x, region.end.x):
            if image.get_pixel(x, y).a > CORNER_ALPHA_MAX:
                opaque_pixels += 1
    suite.expect_equal(opaque_pixels, 0, "%s is fully transparent" % label)


func _test_traveller_cells(suite: TestSuite) -> void:
    var path := "res://assets/art/act_00/time_traveller_strip.png"
    if not FileAccess.file_exists(path):
        return
    var image := _load_image(suite, path)
    if image == null:
        return

    var baselines: Array[int] = []
    for cell in range(4):
        var bounds := _local_alpha_bounds(image, cell * TRAVELLER_CELL_SIZE.x)
        suite.expect_true(bounds["max_x"] >= bounds["min_x"], "traveller cell %d has nonempty local alpha bounds" % cell)
        if bounds["max_x"] < bounds["min_x"]:
            continue
        suite.expect_true(
            bounds["min_x"] >= TRAVELLER_EDGE_PADDING and bounds["max_x"] < TRAVELLER_CELL_SIZE.x - TRAVELLER_EDGE_PADDING,
            "traveller cell %d stays inside its 512px atlas cell" % cell
        )
        suite.expect_true(bounds["max_y"] < TRAVELLER_CELL_SIZE.y - TRAVELLER_EDGE_PADDING, "traveller cell %d keeps headroom" % cell)
        baselines.append(bounds["max_y"])

    if baselines.size() == 4:
        var lowest := baselines[0]
        var highest := baselines[0]
        for baseline in baselines:
            lowest = mini(lowest, baseline)
            highest = maxi(highest, baseline)
        suite.expect_true(
            highest - lowest <= MAX_BASELINE_DELTA,
            "traveller feet baselines agree within %dpx" % MAX_BASELINE_DELTA
        )


func _local_alpha_bounds(image: Image, cell_start_x: int) -> Dictionary:
    var min_x := TRAVELLER_CELL_SIZE.x
    var min_y := TRAVELLER_CELL_SIZE.y
    var max_x := -1
    var max_y := -1
    for local_y in range(0, TRAVELLER_CELL_SIZE.y, 2):
        for local_x in range(0, TRAVELLER_CELL_SIZE.x, 2):
            if image.get_pixel(cell_start_x + local_x, local_y).a >= ALPHA_OPAQUE:
                min_x = mini(min_x, local_x)
                min_y = mini(min_y, local_y)
                max_x = maxi(max_x, local_x)
                max_y = maxi(max_y, local_y)
    return {"min_x": min_x, "min_y": min_y, "max_x": max_x, "max_y": max_y}


func _test_manifest_icon_bindings(suite: TestSuite) -> void:
    var manifest := ResourceLoader.load(MANIFEST_PATH) as ActManifest
    suite.expect_not_null(manifest, "Act 0 manifest loads for icon bindings")
    if manifest == null:
        return
    for id_value in ITEM_ICON_PATHS:
        var item_id := StringName(id_value)
        var expected_path := String(ITEM_ICON_PATHS[item_id])
        var item := _find_item(manifest, item_id)
        suite.expect_not_null(item, "%s remains in the Act 0 manifest" % item_id)
        if item == null:
            continue
        suite.expect_not_null(item.icon, "%s has a runtime icon binding" % item_id)
        if item.icon != null:
            suite.expect_equal(item.icon.resource_path, expected_path, "%s binds its exact icon path" % item_id)


func _test_workbench_token_path_contract(suite: TestSuite) -> void:
    suite.expect_equal(WORKBENCH_TOKEN_PATHS.size(), 6, "six deterministic workbench token paths")
    for item_id in ITEM_ICON_PATHS:
        var slug := String(item_id).get_slice(".", 2)
        var expected_path := "res://assets/art/act_00/%s.png" % slug
        suite.expect_equal(ITEM_ICON_PATHS[item_id], expected_path, "%s uses its stable token path" % item_id)
        suite.expect_true(WORKBENCH_TOKEN_PATHS.values().has(expected_path), "%s path is available to the workbench" % item_id)


func _find_item(manifest: ActManifest, item_id: StringName) -> ItemDefinition:
    for item in manifest.items:
        if item.id == item_id:
            return item
    return null


func _test_player_atlas(suite: TestSuite) -> void:
    var player := _instantiate_scene(suite, PLAYER_SCENE_PATH)
    if player == null:
        return
    var sprite := player.get_node_or_null("Visual/AnimatedSprite2D") as AnimatedSprite2D
    suite.expect_not_null(sprite, "player uses AnimatedSprite2D art")
    if sprite != null:
        suite.expect_equal(sprite.position, Vector2(0, -151), "player sprite visual anchor")
        suite.expect_equal(sprite.scale, Vector2(0.62, 0.62), "player sprite visual scale")
        suite.expect_equal(sprite.animation, &"idle", "player starts on idle animation")
        _test_sprite_frames(suite, sprite.sprite_frames)
    player.free()


func _test_sprite_frames(suite: TestSuite, frames: SpriteFrames) -> void:
    suite.expect_not_null(frames, "player has SpriteFrames")
    if frames == null:
        return
    _test_animation(suite, frames, &"idle", [Rect2(0, 0, 512, 512)], 1.0, true)
    _test_animation(suite, frames, &"walk", [Rect2(512, 0, 512, 512), Rect2(1024, 0, 512, 512)], 6.0, true)
    _test_animation(suite, frames, &"inspect", [Rect2(1536, 0, 512, 512)], 2.5, false)


func _test_animation(
    suite: TestSuite,
    frames: SpriteFrames,
    animation: StringName,
    regions: Array,
    speed: float,
    loops: bool
) -> void:
    suite.expect_true(frames.has_animation(animation), "player SpriteFrames defines %s" % animation)
    if not frames.has_animation(animation):
        return
    suite.expect_equal(frames.get_frame_count(animation), regions.size(), "%s frame count" % animation)
    suite.expect_equal(frames.get_animation_speed(animation), speed, "%s speed" % animation)
    suite.expect_equal(frames.get_animation_loop(animation), loops, "%s loop mode" % animation)
    for index in range(regions.size()):
        var atlas_frame := frames.get_frame_texture(animation, index) as AtlasTexture
        suite.expect_not_null(atlas_frame, "%s frame %d is an AtlasTexture" % [animation, index])
        if atlas_frame == null:
            continue
        suite.expect_not_null(atlas_frame.atlas, "%s frame %d has an atlas texture" % [animation, index])
        if atlas_frame.atlas != null:
            suite.expect_equal(
                atlas_frame.atlas.resource_path,
                "res://assets/art/act_00/time_traveller_strip.png",
                "%s frame %d atlas path" % [animation, index]
            )
        suite.expect_equal(atlas_frame.region, regions[index], "%s frame %d atlas region" % [animation, index])


func _test_scene_bindings(suite: TestSuite) -> void:
    _test_workshop_bindings(suite)
    _test_workbench_bindings(suite)
    _test_hud_bindings(suite)


func _test_workshop_bindings(suite: TestSuite) -> void:
    var workshop := _instantiate_scene(suite, WORKSHOP_SCENE_PATH)
    if workshop == null:
        return
    _expect_texture_path(
        suite,
        workshop.get_node_or_null("BackgroundArt") as Sprite2D,
        "res://assets/art/act_00/workshop_background.png",
        "workshop background art"
    )
    for prop_name in ["Notebook", "Drawer", "Clock", "Bench", "Window", "Prism", "Levers", "Apparatus"]:
        var visual := workshop.get_node_or_null("Props/%s/Visual" % prop_name) as CanvasItem
        suite.expect_not_null(visual, "%s retains its focus-alignment visual" % prop_name)
        if visual != null:
            suite.expect_true(not visual.visible, "%s blockout visual hides behind artwork" % prop_name)
    _expect_texture_path(
        suite,
        workshop.get_node_or_null("Props/Prism/ItemArt") as Sprite2D,
        "res://assets/art/act_00/crystal_prism.png",
        "workshop prism item art"
    )
    _expect_texture_path(
        suite,
        workshop.get_node_or_null("Props/Levers/ItemArt") as Sprite2D,
        "res://assets/art/act_00/control_levers.png",
        "workshop levers item art"
    )
    var floor_visual := workshop.get_node_or_null("FloorVisual") as CanvasItem
    suite.expect_not_null(floor_visual, "workshop retains a floor visual node")
    if floor_visual != null:
        suite.expect_true(not floor_visual.visible, "opaque FloorVisual hides behind painted workshop floor")
    for prop_name_value in WORKSHOP_ART_ANCHORS:
        var prop_name := String(prop_name_value)
        var expected: Dictionary = WORKSHOP_ART_ANCHORS[prop_name]
        var prop := workshop.get_node_or_null("Props/%s" % prop_name) as Area2D
        var focus := workshop.get_node_or_null("Props/%s/FocusVisual" % prop_name) as Polygon2D
        suite.expect_not_null(prop, "%s interaction area exists" % prop_name)
        suite.expect_not_null(focus, "%s focus shape exists" % prop_name)
        if prop != null:
            suite.expect_equal(prop.position, expected["area"], "%s reachable collision anchor" % prop_name)
        if focus != null:
            suite.expect_equal(focus.position, expected["focus"], "%s painted-object focus anchor" % prop_name)
    for item_name in ["Prism", "Levers"]:
        var item_art := workshop.get_node_or_null("Props/%s/ItemArt" % item_name) as Sprite2D
        suite.expect_not_null(item_art, "%s item art exists" % item_name)
        if item_art != null:
            suite.expect_equal(item_art.position, Vector2(0, -90), "%s item art sits on its painted shelf" % item_name)
    workshop.free()


func _test_workbench_bindings(suite: TestSuite) -> void:
    var workbench := _instantiate_scene(suite, WORKBENCH_SCENE_PATH)
    if workbench == null:
        return
    _expect_texture_path(
        suite,
        workbench.get_node_or_null("Frame/Plate") as TextureRect,
        "res://assets/art/act_00/workbench_background.png",
        "workbench plate"
    )
    _expect_texture_path(
        suite,
        workbench.get_node_or_null("Frame/Margin/Rows/Machine/FrameArt") as TextureRect,
        "res://assets/art/act_00/model_frame.png",
        "workbench frame art"
    )
    var cloth := workbench.get_node_or_null("Frame/Margin/Rows/Machine/ClothCover") as TextureRect
    _expect_texture_path(
        suite,
        cloth,
        "res://assets/art/act_00/model_cloth.png",
        "workbench cloth cover"
    )
    if cloth != null:
        suite.expect_true(not cloth.visible, "cloth cover starts hidden")
        suite.expect_equal(cloth.mouse_filter, Control.MOUSE_FILTER_IGNORE, "cloth cover cannot trap input")
    for binding_value in CURRENT_WORKBENCH_TOKEN_PATHS:
        var binding := String(binding_value)
        var expected_path := String(CURRENT_WORKBENCH_TOKEN_PATHS[binding])
        var button := workbench.get_node_or_null("Frame/Margin/Rows/Tray/%s" % binding) as Button
        _expect_button_icon(suite, button, binding, expected_path)
    var installed_slot_paths := {
        "GuidesSlot": "res://assets/art/act_00/ivory_guides.png",
        "PrismSlot": "res://assets/art/act_00/crystal_prism.png",
        "LeversSlot": "res://assets/art/act_00/control_levers.png",
    }
    for slot_name in installed_slot_paths:
        var slot := workbench.get_node_or_null(
            "Frame/Margin/Rows/Machine/Slots/%s" % slot_name
        ) as ComponentSlot
        suite.expect_not_null(slot, "%s installed-component slot exists" % slot_name)
        if slot == null:
            continue
        var filled_icon := slot.get("filled_icon") as Texture2D
        suite.expect_not_null(filled_icon, "%s has a filled icon mapping" % slot_name)
        if filled_icon != null:
            suite.expect_equal(
                filled_icon.resource_path,
                installed_slot_paths[slot_name],
                "%s maps its exact installed icon" % slot_name
            )
        suite.expect_equal(slot.icon, null, "%s hides its icon while empty" % slot_name)
    workbench.free()


func _test_hud_bindings(suite: TestSuite) -> void:
    var hud := _instantiate_scene(suite, HUD_SCENE_PATH)
    if hud == null:
        return
    var journal := hud.get_node_or_null("Toolbar/Buttons/Journal") as Button
    _expect_button_icon(suite, journal, "Journal", "res://assets/art/act_00/journal_icon.png")
    var inventory := hud.get_node_or_null("Toolbar/Buttons/Inventory") as Button
    _expect_button_icon(suite, inventory, "Inventory", "res://assets/art/act_00/inventory_icon.png")
    for button in [journal, inventory]:
        if button != null:
            suite.expect_equal(button.custom_minimum_size, Vector2(52, 52), "%s icon control dimensions" % button.name)
    hud.free()


func _expect_texture_path(suite: TestSuite, control: CanvasItem, expected_path: String, message: String) -> void:
    suite.expect_not_null(control, "%s node exists" % message)
    if control == null:
        return
    var texture: Texture2D
    if control is Sprite2D:
        texture = (control as Sprite2D).texture
    elif control is TextureRect:
        texture = (control as TextureRect).texture
    suite.expect_not_null(texture, "%s texture is assigned" % message)
    if texture != null:
        suite.expect_equal(texture.resource_path, expected_path, "%s texture path" % message)


func _expect_button_icon(suite: TestSuite, button: Button, label: String, expected_path: String) -> void:
    suite.expect_not_null(button, "%s icon button exists" % label)
    if button == null:
        return
    suite.expect_not_null(button.icon, "%s icon is assigned" % label)
    if button.icon != null:
        suite.expect_equal(button.icon.resource_path, expected_path, "%s icon path" % label)
    suite.expect_true(button.expand_icon, "%s icon expands within its button" % label)


func _test_inventory_icon_population(suite: TestSuite, tree: SceneTree) -> void:
    var manifest := ResourceLoader.load(MANIFEST_PATH) as ActManifest
    var packed := ResourceLoader.load(INVENTORY_TRAY_SCENE_PATH) as PackedScene
    suite.expect_not_null(packed, "inventory tray scene loads for icon population")
    if manifest == null or packed == null:
        return
    var registry := CONTENT_REGISTRY_SCRIPT.new()
    registry.load_manifest(manifest)
    var tray := packed.instantiate() as InventoryTray
    tree.root.add_child(tray)
    await tree.process_frame
    tray.populate(PackedStringArray(ITEM_ICON_PATHS.keys()), registry)
    var items := tray.get_node("Margin/Rows/Items") as HBoxContainer
    suite.expect_equal(items.get_child_count(), ITEM_ICON_PATHS.size(), "inventory renders one column per Act 0 item")
    for index in range(items.get_child_count()):
        var column := items.get_child(index) as VBoxContainer
        var icon := column.get_child(0) as TextureRect if column != null and column.get_child_count() > 0 else null
        suite.expect_not_null(icon, "inventory column %d begins with an item icon" % index)
        if icon != null:
            suite.expect_equal(icon.custom_minimum_size, Vector2(72, 72), "inventory item icon dimensions")
            suite.expect_equal(icon.expand_mode, TextureRect.EXPAND_IGNORE_SIZE, "inventory item icon expands")
            suite.expect_equal(icon.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "inventory item icon aspect mode")
    tree.root.remove_child(tray)
    tray.free()
    registry.free()


func _test_provenance(suite: TestSuite) -> void:
    suite.expect_true(FileAccess.file_exists("res://assets/art/act_00/source/.gdignore"), "art source directory is ignored by Godot")
    for source_path in SOURCE_PLATES:
        suite.expect_true(FileAccess.file_exists(source_path), "%s generated source plate exists" % source_path)
    for source_path in SOURCE_VECTORS:
        suite.expect_true(FileAccess.file_exists(source_path), "%s hand-authored source vector exists" % source_path)
        if FileAccess.file_exists(source_path):
            var vector := FileAccess.get_file_as_string(source_path)
            suite.expect_true(vector.contains('viewBox="0 0 256 256"'), "%s uses a 256px viewBox" % source_path)
            suite.expect_true(not vector.contains("<text"), "%s is text-free" % source_path)
    suite.expect_true(FileAccess.file_exists(PROVENANCE_PATH), "Act 0 art provenance exists")
    if not FileAccess.file_exists(PROVENANCE_PATH):
        return
    var contents := FileAccess.get_file_as_string(PROVENANCE_PATH)
    suite.expect_true(contents.contains("# Act 0 Art Provenance"), "provenance title")
    for section in ["Workshop panorama", "Time Traveller", "Model workbench", "Model framework", "Model cloth", "Item and UI icons"]:
        var section_start := contents.find("## %s" % section)
        var prompt_start := contents.find("### Prompt", section_start)
        var next_section := contents.find("## ", section_start + 3)
        suite.expect_true(
            section_start >= 0 and prompt_start > section_start and (next_section < 0 or prompt_start < next_section),
            "%s records a self-contained prompt" % section
        )
    suite.expect_true(contents.contains("## SHA-256 Checksums"), "provenance has checksum heading")
    suite.expect_true(contents.contains("### Source plates"), "provenance has source checksum heading")
    suite.expect_true(contents.contains("### Runtime assets"), "provenance has runtime checksum heading")
    suite.expect_true(contents.contains("Original hand-authored vector sources"), "provenance distinguishes original vectors")
    for path_value in SOURCE_PLATES + SOURCE_VECTORS + EXPECTED_SIZES.keys():
        var path := String(path_value)
        var provenance_path := path.trim_prefix("res://")
        suite.expect_true(contents.contains(provenance_path), "provenance names %s" % path)
        if not FileAccess.file_exists(path):
            continue
        suite.expect_true(
            contents.contains("%s  %s" % [_sha256(path), provenance_path]),
            "provenance records exact SHA-256 for %s" % path
        )


func _test_repo_owned_art_processor(suite: TestSuite) -> void:
    suite.expect_true(FileAccess.file_exists(CHROMA_HELPER_PATH), "art processor has a repo-owned chroma-key helper")
    suite.expect_true(FileAccess.file_exists(ART_REQUIREMENTS_PATH), "art processor pins its Python dependency")
    if FileAccess.file_exists(ART_REQUIREMENTS_PATH):
        var requirements := FileAccess.get_file_as_string(ART_REQUIREMENTS_PATH)
        suite.expect_true(requirements.contains("Pillow==12.2.0"), "art processor pins Pillow 12.2.0")
    if FileAccess.file_exists(ART_PROCESSOR_PATH):
        var processor := FileAccess.get_file_as_string(ART_PROCESSOR_PATH)
        suite.expect_true(processor.contains('key_helper="$root/tools/remove_chroma_key.py"'), "art processor invokes its repo-owned helper")
        suite.expect_true(not processor.contains("CODEX_HOME"), "art processor does not depend on CODEX_HOME")
        suite.expect_true(processor.contains("model_cloth_master.png"), "art processor requires the cloth source plate")
        suite.expect_true(processor.contains("model_cloth.png"), "art processor deterministically emits the cloth runtime asset")
        suite.expect_true(processor.contains("for icon in brass_rails smoked_lens clockwork_escapement"), "art processor names all vector icons")
        suite.expect_true(processor.contains('require_file "$source_dir/$icon.svg"'), "art processor requires each vector source")
        suite.expect_true(processor.contains("-resize '200x200' -gravity center -extent 256x256"), "art processor normalises vector icons")
    var verification := FileAccess.get_file_as_string("res://scripts/verify.sh")
    suite.expect_true(
        verification.contains("ImageMagick 7.1.2-26"),
        "verification enforces exact ImageMagick 7.1.2-26"
    )
    var readme := FileAccess.get_file_as_string("res://README.md")
    suite.expect_true(
        readme.contains("ImageMagick `7.1.2-26`"),
        "README documents exact ImageMagick 7.1.2-26"
    )


func _sha256(path: String) -> String:
    var context := HashingContext.new()
    context.start(HashingContext.HASH_SHA256)
    context.update(FileAccess.get_file_as_bytes(path))
    return context.finish().hex_encode()


func _load_image(suite: TestSuite, path: String) -> Image:
    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(path))
    suite.expect_equal(error, OK, "%s decodes for pixel checks" % path)
    return image if error == OK else null


func _instantiate_scene(suite: TestSuite, path: String) -> Node:
    var packed := ResourceLoader.load(path) as PackedScene
    suite.expect_not_null(packed, "%s loads" % path)
    return packed.instantiate() if packed != null else null
