extends RefCounted

const InteractableScript := preload("res://game/shared/interactable.gd")
const PlayerScript := preload("res://game/player/player_controller.gd")
const PlayerScene := preload("res://game/player/player.tscn")

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var player := PlayerScript.new()
    player.position = Vector2.ZERO
    player.facing = 1

    var near_left := InteractableScript.new()
    near_left.position = Vector2(-20, 0)
    near_left.action_id = &"act00.action.left"
    near_left.prompt_verb = "Inspect"
    near_left.prompt_name = "left object"

    var forward := InteractableScript.new()
    forward.position = Vector2(90, 0)
    forward.action_id = &"act00.action.forward"
    forward.prompt_verb = "Open"
    forward.prompt_name = "drawer"

    var high_priority := InteractableScript.new()
    high_priority.position = Vector2(100, 0)
    high_priority.action_id = &"act00.action.priority"
    high_priority.focus_priority = 2

    suite.expect_equal(
        player.choose_focus([near_left, forward]),
        forward,
        "facing preference beats nearby object behind player"
    )
    suite.expect_equal(
        player.choose_focus([forward, high_priority]),
        high_priority,
        "focus priority breaks nearby competition"
    )
    var tie_alpha := InteractableScript.new()
    tie_alpha.position = Vector2(60, 0)
    tie_alpha.action_id = &"act00.action.alpha"
    var tie_beta := InteractableScript.new()
    tie_beta.position = Vector2(60, 0)
    tie_beta.action_id = &"act00.action.beta"
    suite.expect_equal(
        player.choose_focus([tie_beta, tie_alpha]),
        tie_alpha,
        "lexical action ID breaks equal-score ties in reverse input order"
    )
    suite.expect_equal(
        player.choose_focus([tie_alpha, tie_beta]),
        tie_alpha,
        "lexical action ID breaks equal-score ties in forward input order"
    )
    player.facing = -1
    suite.expect_equal(player.choose_focus([near_left, forward]), near_left, "left-facing selection")
    suite.expect_equal(forward.prompt_text(), "Open drawer", "prompt composition")

    var trigger_count: Array[int] = [0]
    forward.interacted.connect(func(_id: StringName) -> void: trigger_count[0] += 1)
    forward.trigger()
    suite.expect_equal(trigger_count[0], 1, "interactable emits semantic action")

    var scene_player := PlayerScene.instantiate() as PlayerController
    tree.root.add_child(scene_player)
    var overlap_target := InteractableScript.new()
    overlap_target.position = Vector2(40, -55)
    overlap_target.prompt_name = "overlap target"
    var overlap_shape := CollisionShape2D.new()
    var overlap_rectangle := RectangleShape2D.new()
    overlap_rectangle.size = Vector2(20, 20)
    overlap_shape.shape = overlap_rectangle
    overlap_target.add_child(overlap_shape)
    var focused_prompts: Array[String] = []
    scene_player.focus_prompt_changed.connect(
        func(text: String, visible: bool) -> void:
            if visible:
                focused_prompts.append(text)
    )
    tree.root.add_child(overlap_target)
    await tree.physics_frame
    await tree.physics_frame
    await tree.physics_frame
    suite.expect_equal(
        focused_prompts,
        ["Inspect overlap target"],
        "default interactable enters player interaction range"
    )

    near_left.free()
    forward.free()
    high_priority.free()
    tie_alpha.free()
    tie_beta.free()
    player.free()
    overlap_target.queue_free()
    scene_player.queue_free()
