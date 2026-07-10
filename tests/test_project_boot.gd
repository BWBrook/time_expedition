extends RefCounted

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    suite.expect_equal(
        ProjectSettings.get_setting("application/config/name"),
        "Time Expedition",
        "project name"
    )
    var main_path: String = ProjectSettings.get_setting("application/run/main_scene", "")
    suite.expect_equal(main_path, "res://game/main.tscn", "main scene path")
    var packed := load(main_path) as PackedScene
    suite.expect_not_null(packed, "main scene loads")
    if packed != null:
        var instance := packed.instantiate()
        suite.expect_equal(instance.name, "Main", "main root name")
        instance.free()
