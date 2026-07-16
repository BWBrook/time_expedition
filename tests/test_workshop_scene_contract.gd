extends RefCounted

const PLAYER_SCENE := preload("res://game/player/player.tscn")
const WORKSHOP_SCENE := preload("res://game/act_00/workshop.tscn")

const EXPECTED_ACTION_X := {
    &"act00.action.notebook": 260.0,
    &"act00.action.drafting_stool": 480.0,
    &"act00.action.diagrams": 650.0,
    &"act00.action.collect_guides": 850.0,
    &"act00.action.clock": 1150.0,
    &"act00.action.glassware": 1350.0,
    &"act00.action.bench": 1580.0,
    &"act00.action.spirit_level": 1810.0,
    &"act00.action.window": 2050.0,
    &"act00.action.collect_prism": 2300.0,
    &"act00.action.collect_levers": 2620.0,
    &"act00.action.apparatus": 2820.0,
    &"act00.action.gas_lamp": 2990.0,
    &"act00.action.specimen_cabinet": 3140.0,
}


func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    _test_adult_player_scale(suite)
    _test_workshop_hotspots(suite)


func _test_adult_player_scale(suite: TestSuite) -> void:
    var player := PLAYER_SCENE.instantiate() as PlayerController
    suite.expect_not_null(player, "player scene instantiates for scale contract")
    if player == null:
        return

    var sprite := player.get_node_or_null("Visual/AnimatedSprite2D") as AnimatedSprite2D
    var capsule_node := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
    var range_node := player.get_node_or_null("InteractionRange") as Area2D
    suite.expect_not_null(sprite, "adult player sprite exists")
    suite.expect_not_null(capsule_node, "adult player collision node exists")
    suite.expect_not_null(range_node, "adult player interaction range exists")

    if sprite != null:
        suite.expect_equal(sprite.scale, Vector2(0.62, 0.62), "adult visual scale")
        suite.expect_equal(sprite.position, Vector2(0, -151), "adult visual anchor")

    if capsule_node != null:
        var capsule := capsule_node.shape as CapsuleShape2D
        suite.expect_not_null(capsule, "adult player uses capsule collision")
        if capsule != null:
            suite.expect_equal(capsule.radius, 26.0, "adult collision radius")
            suite.expect_equal(capsule.height, 168.0, "adult collision height")
        suite.expect_equal(capsule_node.position, Vector2(0, -84), "adult collision anchor")

    if range_node != null:
        var range_collision := range_node.get_node_or_null("CollisionShape2D") as CollisionShape2D
        suite.expect_not_null(range_collision, "adult interaction collision node exists")
        if range_collision != null:
            var range_shape := range_collision.shape as RectangleShape2D
            suite.expect_not_null(range_shape, "adult interaction uses rectangle collision")
            if range_shape != null:
                suite.expect_equal(range_shape.size, Vector2(260, 260), "adult interaction size")
        suite.expect_equal(range_node.position, Vector2(0, -120), "adult interaction anchor")

    player.free()


func _test_workshop_hotspots(suite: TestSuite) -> void:
    var workshop := WORKSHOP_SCENE.instantiate()
    suite.expect_not_null(workshop, "workshop scene instantiates for hotspot contract")
    if workshop == null:
        return

    var props := workshop.get_node_or_null("Props")
    suite.expect_not_null(props, "workshop has hotspot container")
    if props == null:
        workshop.free()
        return

    suite.expect_equal(props.get_child_count(), EXPECTED_ACTION_X.size(), "workshop has exactly fourteen hotspots")
    var action_ids: Array[String] = []
    var prompts := {}
    for child in props.get_children():
        suite.expect_true(child is Interactable, "%s is an Interactable" % child.name)
        if not child is Interactable:
            continue
        var hotspot := child as Interactable
        action_ids.append(String(hotspot.action_id))
        suite.expect_true(EXPECTED_ACTION_X.has(hotspot.action_id), "%s has an approved action ID" % child.name)
        if EXPECTED_ACTION_X.has(hotspot.action_id):
            suite.expect_equal(hotspot.position.x, EXPECTED_ACTION_X[hotspot.action_id], "%s exact x anchor" % child.name)

        suite.expect_true(not hotspot.prompt_verb.is_empty(), "%s has a prompt verb" % child.name)
        suite.expect_true(not hotspot.prompt_name.is_empty(), "%s has a prompt name" % child.name)
        var prompt := hotspot.prompt_text()
        suite.expect_true(not prompts.has(prompt), "%s prompt is unique" % child.name)
        prompts[prompt] = true

        var collision := hotspot.get_node_or_null("CollisionShape2D") as CollisionShape2D
        suite.expect_not_null(collision, "%s has a collision node" % child.name)
        if collision != null:
            suite.expect_not_null(collision.shape, "%s has a collision shape" % child.name)
        suite.expect_not_null(hotspot.get_node_or_null("FocusVisual") as CanvasItem, "%s has a focus visual" % child.name)

    var expected_ids: Array[String] = []
    for action_id in EXPECTED_ACTION_X:
        expected_ids.append(String(action_id))
    action_ids.sort()
    expected_ids.sort()
    suite.expect_equal(action_ids, expected_ids, "workshop exposes the exact fourteen action IDs")

    var bench := props.get_node_or_null("Bench") as Interactable
    suite.expect_not_null(bench, "model bench hotspot exists")
    if bench != null:
        suite.expect_equal(bench.focus_priority, 2, "model bench retains focus priority")

    workshop.free()
