extends SceneTree

const OUTPUT := "res://game/content/act_00/act_00_manifest.tres"

func _initialize() -> void:
    var manifest := ActManifest.new()
    manifest.act_id = &"act00"
    manifest.title = "Act 0: The Model"
    manifest.items = [
        _item(
            &"act00.item.ivory_guides",
            "Ivory guide bars",
            "Twin ivory guides, worked to an accuracy the eye can barely judge."
        ),
        _item(
            &"act00.item.crystal_prism",
            "Crystalline prism",
            "A transparent prism cut for the model's temporal axis."
        ),
        _item(
            &"act00.item.control_levers",
            "Paired control levers",
            "The white departure lever and its darker companion on one delicate yoke."
        ),
    ]
    manifest.journal_entries = [
        _journal(
            &"act00.journal.experiment",
            "The model",
            "The frame is complete, but the ivory guides, crystalline prism, and paired levers remain to be fitted. I shall test it once before I submit the thing to witnesses."
        ),
        _journal(
            &"act00.journal.components",
            "Materials assembled",
            "All three pieces are at hand. Their fittings are unlike enough that haste ought not defeat reason."
        ),
        _journal(
            &"act00.journal.calibration",
            "Calibration",
            "Spatial axes at equilibrium. Temporal bias one division forward. Only then may the departure lever describe a complete excursion."
        ),
        _journal(
            &"act00.journal.misfire",
            "An incomplete displacement",
            "The frame shuddered but did not depart. The mechanism is sound; the fault lies in my calibration."
        ),
        _journal(
            &"act00.journal.success",
            "Eleven seconds",
            "Four seconds passed in the workshop. The model's chronometer advanced fifteen. An error of measurement remains possible, but an error with a very particular direction."
        ),
    ]
    manifest.observations = [
        _observation(&"act00.observation.notebook", "The ink is scarcely dry. Three pieces remain, and the calibration note is underlined twice."),
        _observation(&"act00.observation.take_guides", "The ivory guides are cool and absurdly light. They belong on the model."),
        _observation(&"act00.observation.guides_taken", "Only their fitted impressions remain in the velvet."),
        _observation(&"act00.observation.take_prism", "The prism divides the lamplight into a narrow spectral edge."),
        _observation(&"act00.observation.prism_taken", "The optical stand is empty."),
        _observation(&"act00.observation.take_levers", "The paired levers survived the discarded mechanism. Waste is merely invention awaiting better judgement."),
        _observation(&"act00.observation.levers_taken", "The rejected frames can offer nothing further tonight."),
        _observation(&"act00.observation.bench_missing", "The frame is ready, but its three empty fittings make success impossible."),
        _observation(&"act00.observation.bench_ready", "Everything required is here. Now accuracy must do what theory has promised."),
        _observation(&"act00.observation.wrong_slot", "No. The fitting refuses it without force, which is more wisdom than many men display."),
        _observation(&"act00.observation.component_fitted", "It seats cleanly. One uncertainty removed."),
        _observation(&"act00.observation.assembly_complete", "The model is whole. Spatial equilibrium; temporal bias one division forward."),
        _observation(&"act00.observation.misfire", "A displacement began and collapsed. The calibration, not the construction, is at fault."),
        _observation(&"act00.observation.excursion", "For four seconds the bench is indisputably empty."),
        _observation(&"act00.observation.return", "The chronometer reads fifteen seconds. The workshop clock has advanced four."),
        _observation(&"act00.observation.clock", "The house clock is less forgiving than any scientific instrument. My guests will soon arrive."),
        _observation(&"act00.observation.window", "Rain stipples the Richmond glass. Beyond it, ordinary time proceeds with complete confidence."),
        _observation(&"act00.observation.apparatus", "A respectable collection of failures, each one useful enough to deserve dusting."),
    ]

    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.get_base_dir()))
    var error := ResourceSaver.save(manifest, OUTPUT)
    if error != OK:
        push_error("Unable to save %s: error %d" % [OUTPUT, error])
        quit(1)
        return
    print("WROTE %s" % OUTPUT)
    quit(0)

func _item(id: StringName, display_name: String, description: String) -> ItemDefinition:
    var value := ItemDefinition.new()
    value.resource_scene_unique_id = _subresource_id(id)
    value.id = id
    value.display_name = display_name
    value.description = description
    return value

func _journal(id: StringName, title: String, body: String) -> JournalEntryDefinition:
    var value := JournalEntryDefinition.new()
    value.resource_scene_unique_id = _subresource_id(id)
    value.id = id
    value.title = title
    value.body = body
    return value

func _observation(id: StringName, text: String) -> ObservationDefinition:
    var value := ObservationDefinition.new()
    value.resource_scene_unique_id = _subresource_id(id)
    value.id = id
    value.text = text
    return value

func _subresource_id(id: StringName) -> String:
    return String(id).replace(".", "_")
