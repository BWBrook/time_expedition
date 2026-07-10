extends RefCounted

const RegistryScript := preload("res://game/content/content_registry.gd")
const ManifestScript := preload("res://game/content/act_manifest.gd")
const ItemScript := preload("res://game/content/item_definition.gd")

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var manifest := load("res://game/content/act_00/act_00_manifest.tres") as ActManifest
    suite.expect_not_null(manifest, "Act 0 manifest loads")

    var registry := RegistryScript.new()
    var errors := registry.load_manifest(manifest)
    suite.expect_equal(errors.size(), 0, "canonical manifest validates")
    suite.expect_equal(registry.item_count(), 3, "three inventory items")
    suite.expect_equal(registry.journal_count(), 5, "five journal entries")
    suite.expect_true(registry.observation_count() >= 16, "authored observations present")
    suite.expect_equal(
        registry.get_item(&"act00.item.crystal_prism").display_name,
        "Crystalline prism",
        "item lookup by stable ID"
    )

    var duplicate_manifest := ManifestScript.new()
    var duplicate_a := ItemScript.new()
    duplicate_a.id = &"act00.item.duplicate"
    var duplicate_b := ItemScript.new()
    duplicate_b.id = &"act00.item.duplicate"
    duplicate_manifest.items = [duplicate_a, duplicate_b]
    var duplicate_errors := registry.load_manifest(duplicate_manifest)
    suite.expect_true(duplicate_errors.size() == 1, "duplicate ID rejected")
    suite.expect_equal(registry.item_count(), 3, "invalid load preserves prior registry")
    registry.free()
