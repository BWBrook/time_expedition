extends SceneTree

const TEST_SCRIPTS := [
    preload("res://tests/test_project_boot.gd"),
    preload("res://tests/test_content_registry.gd"),
    preload("res://tests/test_game_session.gd"),
    preload("res://tests/test_workshop_director.gd"),
    preload("res://tests/test_focus_selection.gd"),
    preload("res://tests/test_game_hud.gd"),
    preload("res://tests/test_model_workbench.gd"),
    preload("res://tests/test_temporal_audio.gd"),
    preload("res://tests/test_scene_flow.gd"),
]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var suite := TestSuite.new()
    for test_script in TEST_SCRIPTS:
        var test_case: RefCounted = test_script.new()
        await test_case.run(suite, self)

    if suite.failures.is_empty():
        print("TESTS PASSED: %d assertions" % suite.assertions)
        quit(0)
        return

    for failure in suite.failures:
        push_error("TEST FAILURE: %s" % failure)
    print("TESTS FAILED: %d of %d assertions" % [suite.failures.size(), suite.assertions])
    quit(1)
