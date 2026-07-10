extends RefCounted

const CaptureQa := preload("res://tools/capture_qa.gd")
const LAUNCHER_PATH := "res://scripts/capture-qa.sh"


func run(suite: TestSuite, _tree: SceneTree) -> void:
    _test_fitted_content_sizes(suite)
    _test_letterbox_composition(suite)
    _test_launcher_contract(suite)


func _test_fitted_content_sizes(suite: TestSuite) -> void:
    var cases := {
        Vector2i(1280, 720): Vector2i(1280, 720),
        Vector2i(1440, 900): Vector2i(1440, 810),
        Vector2i(1920, 1080): Vector2i(1920, 1080),
    }
    for requested in cases:
        suite.expect_equal(
            CaptureQa.expected_fitted_content_size(requested),
            cases[requested],
            "%s request fits a 16:9 content texture" % requested
        )


func _test_letterbox_composition(suite: TestSuite) -> void:
    var content := Image.create_empty(1440, 810, false, Image.FORMAT_RGBA8)
    content.fill(Color(0.8, 0.2, 0.1, 1.0))
    var content_pixel := content.get_pixel(0, 0)
    var framebuffer := CaptureQa.compose_requested_frame(content, Vector2i(1440, 900))

    suite.expect_equal(framebuffer.get_size(), Vector2i(1440, 900), "framebuffer matches requested size")
    suite.expect_equal(framebuffer.get_pixel(720, 0), Color.BLACK, "top letterbox is black")
    suite.expect_equal(framebuffer.get_pixel(720, 44), Color.BLACK, "top letterbox is 45 pixels high")
    suite.expect_equal(
        framebuffer.get_pixel(720, 45),
        content_pixel,
        "content begins after the top letterbox"
    )
    suite.expect_equal(
        framebuffer.get_pixel(720, 854),
        content_pixel,
        "content ends before the bottom letterbox"
    )
    suite.expect_equal(framebuffer.get_pixel(720, 855), Color.BLACK, "bottom letterbox is 45 pixels high")
    suite.expect_equal(framebuffer.get_pixel(720, 899), Color.BLACK, "bottom edge remains black")


func _test_launcher_contract(suite: TestSuite) -> void:
    var launcher := FileAccess.get_file_as_string(LAUNCHER_PATH)
    var resolution_position := launcher.find("--resolution")
    var script_position := launcher.find("--script")

    suite.expect_true(launcher.begins_with("#!/usr/bin/env bash"), "capture launcher requires Bash")
    suite.expect_true(launcher.contains("pathlib.Path"), "capture launcher canonicalizes paths with pathlib")
    suite.expect_true(launcher.contains(".resolve("), "capture launcher resolves symlinks")
    suite.expect_true(
        launcher.contains("output == repository or repository in output.parents"),
        "capture launcher rejects canonical output inside the repository"
    )
    suite.expect_true(
        launcher.contains("\"--output=$output\""),
        "capture launcher forwards the canonical output path"
    )
    suite.expect_true(
        launcher.contains("\"--viewport=$viewport\""),
        "capture launcher forwards the parsed viewport"
    )
    suite.expect_true(resolution_position >= 0, "capture launcher passes a Godot resolution")
    suite.expect_true(
        resolution_position < script_position,
        "capture launcher places resolution before the script argument"
    )
