class_name TestSuite
extends RefCounted

var assertions := 0
var failures := PackedStringArray()

func expect_true(condition: bool, message: String) -> void:
    assertions += 1
    if not condition:
        failures.append(message)

func expect_equal(actual: Variant, expected: Variant, message: String) -> void:
    assertions += 1
    if actual != expected:
        failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])

func expect_not_null(value: Variant, message: String) -> void:
    expect_true(value != null, message)
