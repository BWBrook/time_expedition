extends RefCounted

const InteractableScript := preload("res://game/shared/interactable.gd")
const PlayerScript := preload("res://game/player/player_controller.gd")

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
    player.facing = -1
    suite.expect_equal(player.choose_focus([near_left, forward]), near_left, "left-facing selection")
    suite.expect_equal(forward.prompt_text(), "Open drawer", "prompt composition")

    var trigger_count: Array[int] = [0]
    forward.interacted.connect(func(_id: StringName) -> void: trigger_count[0] += 1)
    forward.trigger()
    suite.expect_equal(trigger_count[0], 1, "interactable emits semantic action")

    near_left.free()
    forward.free()
    high_priority.free()
    player.free()
