extends RefCounted

const RegistryScript := preload("res://game/content/content_registry.gd")
const ManifestScript := preload("res://game/content/act_manifest.gd")
const ItemScript := preload("res://game/content/item_definition.gd")
const JournalScript := preload("res://game/content/journal_entry_definition.gd")
const ObservationScript := preload("res://game/content/observation_definition.gd")

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

    suite.expect_true(registry.has_method("load_default_manifest"), "registry exposes strict default loading")
    if registry.has_method("load_default_manifest"):
        var missing_contract := ManifestScript.new()
        missing_contract.act_id = &"act00"
        missing_contract.title = "Act 0: The Model"
        var strict_errors: PackedStringArray = registry.load_default_manifest(missing_contract)
        suite.expect_true(
            strict_errors.has("Act 0 manifest is missing required item ID: act00.item.ivory_guides"),
            "strict default validation names a missing required item"
        )
        suite.expect_true(
            strict_errors.has("Act 0 manifest is missing required journal ID: act00.journal.success"),
            "strict default validation names a missing required journal entry"
        )
        suite.expect_true(
            strict_errors.has("Act 0 manifest is missing required observation ID: act00.observation.return"),
            "strict default validation names a missing required observation"
        )

        var blank_manifest := manifest.duplicate(true) as ActManifest
        blank_manifest.items[0].display_name = "   "
        blank_manifest.items[1].icon = null
        blank_manifest.journal_entries[0].body = ""
        blank_manifest.observations[0].text = "\t"
        var blank_errors: PackedStringArray = registry.load_default_manifest(blank_manifest)
        suite.expect_true(
            blank_errors.has("Act 0 item act00.item.ivory_guides has a blank display name"),
            "strict default validation rejects blank item names"
        )
        suite.expect_true(
            blank_errors.has("Act 0 item act00.item.crystal_prism has no icon"),
            "strict default validation rejects missing item icons"
        )
        suite.expect_true(
            blank_errors.has("Act 0 journal act00.journal.experiment has a blank body"),
            "strict default validation rejects blank journal bodies"
        )
        suite.expect_true(
            blank_errors.has("Act 0 observation act00.observation.notebook has blank text"),
            "strict default validation rejects blank observation text"
        )

        var partial_manifest := ManifestScript.new()
        var partial_item := ItemScript.new()
        partial_item.id = &"fixture.item.partial"
        partial_manifest.items = [partial_item]
        suite.expect_equal(
            registry.load_manifest(partial_manifest).size(),
            0,
            "generic manifest validation remains available for partial fixtures"
        )
    registry.free()
