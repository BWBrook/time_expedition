extends RefCounted

const CaptureQa := preload("res://tools/capture_qa.gd")
const CAPTURE_SCRIPT_PATH := "res://tools/capture_qa.gd"


func run(suite: TestSuite, _tree: SceneTree) -> void:
    _test_fitted_content_sizes(suite)
    _test_letterbox_composition(suite)
    _test_direct_output_boundary(suite)


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


func _test_direct_output_boundary(suite: TestSuite) -> void:
    var repository := ProjectSettings.globalize_path("res://").trim_suffix("/")
    var temp_root := ProjectSettings.globalize_path(
        "user://capture-boundary-%d" % Time.get_ticks_usec()
    )
    var directory_error := DirAccess.make_dir_recursive_absolute(temp_root)
    suite.expect_equal(directory_error, OK, "direct-boundary fixture directory is created")

    var safe_output := temp_root.path_join("safe-output")
    suite.expect_equal(
        CaptureQa.canonical_capture_output(repository, safe_output),
        safe_output,
        "direct boundary accepts and canonicalizes external output"
    )
    suite.expect_equal(
        CaptureQa.canonical_capture_output(repository, repository),
        "",
        "direct boundary rejects the canonical repository"
    )
    var sibling_output := "%s-qa-output" % repository
    suite.expect_equal(
        CaptureQa.canonical_capture_output(repository, sibling_output),
        sibling_output,
        "direct boundary accepts a similarly prefixed sibling"
    )

    var repository_link := temp_root.path_join("repository-link")
    var link_output: Array = []
    var link_status := OS.execute(
        "ln",
        PackedStringArray(["-s", repository, repository_link]),
        link_output,
        true
    )
    suite.expect_equal(link_status, 0, "direct-boundary fixture symlink is created")
    if link_status == 0:
        suite.expect_equal(
            CaptureQa.canonical_capture_output(
                repository,
                repository_link.path_join("capture-output")
            ),
            "",
            "direct boundary rejects a symlink resolving into the repository"
        )

    var capture_source := FileAccess.get_file_as_string(CAPTURE_SCRIPT_PATH)
    var prepare_start := capture_source.find("func _prepare_output_dir() -> bool:")
    suite.expect_true(prepare_start >= 0, "capture harness defines the output preparation boundary")
    if prepare_start >= 0:
        var prepare_end := capture_source.find("\n\nfunc ", prepare_start + 1)
        var prepare_source := capture_source.substr(prepare_start, prepare_end - prepare_start)
        suite.expect_true(
            prepare_source.contains("canonical_capture_output("),
            "output preparation invokes canonicalization"
        )
        var assignment_position := prepare_source.find("_output_dir = canonical_output")
        var mkdir_position := prepare_source.find("DirAccess.make_dir_recursive_absolute")
        suite.expect_true(
            assignment_position >= 0 and assignment_position < mkdir_position,
            "output preparation stores the canonical path before mkdir"
        )

    if link_status == 0:
        DirAccess.remove_absolute(repository_link)
    DirAccess.remove_absolute(temp_root)
