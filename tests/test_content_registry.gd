extends RefCounted

const RegistryScript := preload("res://game/content/content_registry.gd")
const ManifestScript := preload("res://game/content/act_manifest.gd")
const ItemScript := preload("res://game/content/item_definition.gd")
const JournalScript := preload("res://game/content/journal_entry_definition.gd")
const ObservationScript := preload("res://game/content/observation_definition.gd")

const CANDIDATES: Array[StringName] = [
    &"act00.item.ivory_guides",
    &"act00.item.brass_rails",
    &"act00.item.crystal_prism",
    &"act00.item.smoked_lens",
    &"act00.item.control_levers",
    &"act00.item.clockwork_escapement",
]
const DEDUCTIONS: Array[StringName] = [
    &"act00.journal.experiment",
    &"act00.journal.materials",
    &"act00.journal.components",
    &"act00.journal.spatial_datum",
    &"act00.journal.temporal_datum",
    &"act00.journal.calibration",
    &"act00.journal.misfire",
    &"act00.journal.success",
]
const STATEFUL_OBSERVATIONS: Array[StringName] = [
    &"act00.observation.notebook",
    &"act00.observation.notebook_after_datum",
    &"act00.observation.notebook_calibration",
    &"act00.observation.bench_missing",
    &"act00.observation.bench_ready",
    &"act00.observation.bench_calibration",
    &"act00.observation.clock",
    &"act00.observation.clock_repeat",
    &"act00.observation.spirit_level",
    &"act00.observation.spirit_level_repeat",
    &"act00.observation.displacement_rig",
    &"act00.observation.displacement_rig_calibration",
]
const DIAGNOSTICS: Array[StringName] = [
    &"act00.observation.misfire.left_slow",
    &"act00.observation.misfire.left_correct",
    &"act00.observation.misfire.left_fast",
    &"act00.observation.misfire.centred_slow",
    &"act00.observation.misfire.centred_fast",
    &"act00.observation.misfire.right_slow",
    &"act00.observation.misfire.right_correct",
    &"act00.observation.misfire.right_fast",
]
const ITEM_PROPERTY_FRAGMENTS := {
    &"act00.item.ivory_guides": ["light", "inert"],
    &"act00.item.brass_rails": ["heavy", "conductive"],
    &"act00.item.crystal_prism": ["transparent", "spectral"],
    &"act00.item.smoked_lens": ["absorb", "glass"],
    &"act00.item.control_levers": ["low-friction", "white"],
    &"act00.item.clockwork_escapement": ["periodic", "arrest"],
}

func run(suite: TestSuite, tree: SceneTree) -> void:
    await tree.process_frame
    var manifest := load("res://game/content/act_00/act_00_manifest.tres") as ActManifest
    suite.expect_not_null(manifest, "Act 0 manifest loads")

    var registry := RegistryScript.new()
    var errors := registry.load_manifest(manifest)
    suite.expect_equal(errors.size(), 0, "canonical manifest validates")
    suite.expect_equal(registry.item_count(), 6, "six candidate inventory items")
    suite.expect_equal(registry.journal_count(), 8, "eight journal deductions")
    suite.expect_true(registry.observation_count() >= 55, "at least 55 authored observations")
    _test_candidate_contract(suite, registry)
    _test_journal_contract(suite, registry)
    _test_observation_contract(suite, manifest, registry)
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
    suite.expect_equal(registry.item_count(), 6, "invalid load preserves prior registry")

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
            strict_errors.has("Act 0 manifest is missing required item ID: act00.item.brass_rails"),
            "strict default validation includes a decoy item"
        )
        suite.expect_true(
            strict_errors.has("Act 0 manifest is missing required journal ID: act00.journal.success"),
            "strict default validation names a missing required journal entry"
        )
        suite.expect_true(
            strict_errors.has("Act 0 manifest is missing required journal ID: act00.journal.materials"),
            "strict default validation includes a material deduction"
        )
        suite.expect_true(
            strict_errors.has("Act 0 manifest is missing required observation ID: act00.observation.return"),
            "strict default validation names a missing required observation"
        )
        suite.expect_true(
            strict_errors.has("Act 0 manifest is missing required observation ID: act00.observation.misfire.left_slow"),
            "strict default validation includes an exact diagnostic"
        )

        var blank_manifest := manifest.duplicate(true) as ActManifest
        blank_manifest.items[0].display_name = "   "
        for item in blank_manifest.items:
            if item.id == &"act00.item.crystal_prism":
                item.icon = null
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


func _test_candidate_contract(suite: TestSuite, registry: Node) -> void:
    for item_id in CANDIDATES:
        var item := registry.get_item(item_id) as ItemDefinition
        suite.expect_not_null(item, "%s is present" % item_id)
        if item == null:
            continue
        suite.expect_not_null(item.icon, "%s has an icon" % item_id)
        var description := item.description.to_lower()
        for fragment in ITEM_PROPERTY_FRAGMENTS[item_id]:
            suite.expect_true(
                description.contains(fragment),
                "%s description exposes %s" % [item_id, fragment]
            )
        suite.expect_true(not description.contains("correct"), "%s does not reveal the answer" % item_id)
        suite.expect_true(not description.contains("incorrect"), "%s does not label a decoy" % item_id)


func _test_journal_contract(suite: TestSuite, registry: Node) -> void:
    for journal_id in DEDUCTIONS:
        var entry := registry.get_journal_entry(journal_id) as JournalEntryDefinition
        suite.expect_not_null(entry, "%s is present" % journal_id)
        if entry != null:
            suite.expect_true(not entry.title.strip_edges().is_empty(), "%s has a title" % journal_id)
            suite.expect_true(not entry.body.strip_edges().is_empty(), "%s has a body" % journal_id)


func _test_observation_contract(suite: TestSuite, manifest: ActManifest, registry: Node) -> void:
    for observation in manifest.observations:
        suite.expect_true(
            not observation.text.strip_edges().is_empty(),
            "%s has nonblank authored text" % observation.id
        )

    for observation_id in STATEFUL_OBSERVATIONS:
        suite.expect_not_null(registry.get_observation(observation_id), "%s state exists" % observation_id)

    var diagnostic_ids := _ids_with_prefix(manifest, "act00.observation.misfire.")
    var expected_diagnostics := _sorted_strings(DIAGNOSTICS)
    suite.expect_equal(diagnostic_ids, expected_diagnostics, "exact eight diagnostic IDs")
    for diagnostic_id in DIAGNOSTICS:
        var diagnostic := registry.get_observation(diagnostic_id) as ObservationDefinition
        if diagnostic == null:
            continue
        var text := diagnostic.text.to_lower()
        suite.expect_true(text.contains("lateral field pull"), "%s names lateral field pull" % diagnostic_id)
        suite.expect_true(text.contains("temporal cadence"), "%s names temporal cadence" % diagnostic_id)

    var rejection_ids := _ids_with_prefix(manifest, "act00.observation.reject.")
    var expected_rejections := _expected_rejection_ids()
    suite.expect_equal(rejection_ids, expected_rejections, "exact fifteen rejection IDs")
    for rejection_id in rejection_ids:
        var rejection := registry.get_observation(StringName(rejection_id)) as ObservationDefinition
        if rejection == null:
            continue
        var text := rejection.text.to_lower()
        suite.expect_true(text.length() >= 90, "%s gives a substantive reason" % rejection_id)
        suite.expect_true(not text.contains("wrong slot"), "%s does not use generic rejection" % rejection_id)
        suite.expect_true(_names_item_property(rejection_id, text), "%s names an item property" % rejection_id)
        suite.expect_true(_names_slot_geometry(rejection_id, text), "%s names fitting geometry" % rejection_id)


func _expected_rejection_ids() -> Array[String]:
    var ids: Array[String] = []
    var matching := {
        "ivory_guides": "ivory_guides",
        "crystal_prism": "crystal_prism",
        "control_levers": "control_levers",
    }
    for item_slug in ["ivory_guides", "brass_rails", "crystal_prism", "smoked_lens", "control_levers", "clockwork_escapement"]:
        for slot_slug in ["ivory_guides", "crystal_prism", "control_levers"]:
            if matching.get(item_slug, "") == slot_slug:
                continue
            ids.append("act00.observation.reject.%s.%s" % [item_slug, slot_slug])
    ids.sort()
    return ids


func _ids_with_prefix(manifest: ActManifest, prefix: String) -> Array[String]:
    var ids: Array[String] = []
    for observation in manifest.observations:
        if String(observation.id).begins_with(prefix):
            ids.append(String(observation.id))
    ids.sort()
    return ids


func _sorted_strings(ids: Array[StringName]) -> Array[String]:
    var values: Array[String] = []
    for id in ids:
        values.append(String(id))
    values.sort()
    return values


func _names_item_property(rejection_id: String, text: String) -> bool:
    var fragments := {
        "ivory_guides": ["light", "inert", "ivory", "smooth"],
        "brass_rails": ["heavy", "conductive", "brass"],
        "crystal_prism": ["transparent", "spectral", "facet", "prism"],
        "smoked_lens": ["absorb", "smoked", "dark", "glass"],
        "control_levers": ["low-friction", "white handle", "yoke", "lever"],
        "clockwork_escapement": ["periodic", "arrest", "friction", "escapement"],
    }
    var slug := rejection_id.get_slice(".", 3)
    for fragment in fragments[slug]:
        if text.contains(fragment):
            return true
    return false


func _names_slot_geometry(rejection_id: String, text: String) -> bool:
    var fragments := {
        "ivory_guides": ["guide socket", "longitudinal", "parallel channel", "guide fitting"],
        "crystal_prism": ["optical cradle", "faceted", "light path", "prism cradle"],
        "control_levers": ["actuator pivot", "paired pivots", "lever yoke", "pivot spacing"],
    }
    var slug := rejection_id.get_slice(".", 4)
    for fragment in fragments[slug]:
        if text.contains(fragment):
            return true
    return false
