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
    preload("res://tests/test_workshop_scene_contract.gd"),
    preload("res://tests/test_art_assets.gd"),
    preload("res://tests/test_scene_flow.gd"),
    preload("res://tests/test_act_00_playtest_matrix.gd"),
    preload("res://tests/test_qa_capture_contract.gd"),
]

const FAST_TEST_SCRIPTS := [
    preload("res://tests/test_project_boot.gd"),
    preload("res://tests/test_content_registry.gd"),
    preload("res://tests/test_game_session.gd"),
    preload("res://tests/test_workshop_director.gd"),
    preload("res://tests/test_focus_selection.gd"),
    preload("res://tests/test_game_hud.gd"),
    preload("res://tests/test_model_workbench.gd"),
    preload("res://tests/test_workshop_scene_contract.gd"),
]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var suite := TestSuite.new()
    var fast := OS.get_cmdline_user_args().has("--fast")
    var test_scripts: Array = FAST_TEST_SCRIPTS if fast else TEST_SCRIPTS
    for test_script in test_scripts:
        var test_case: RefCounted = test_script.new()
        await test_case.run(suite, self)
        test_case = null

    for _frame in 3:
        await process_frame

    if suite.failures.is_empty():
        var label := "fast" if fast else "full"
        print("TESTS PASSED (%s): %d assertions" % [label, suite.assertions])
        quit(0)
        return

    for failure in suite.failures:
        push_error("TEST FAILURE: %s" % failure)
    print("TESTS FAILED: %d of %d assertions" % [suite.failures.size(), suite.assertions])
    quit(1)
