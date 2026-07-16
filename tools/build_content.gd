extends SceneTree

const OUTPUT := "res://game/content/act_00/act_00_manifest.tres"
const ITEM_ICON_PATHS := {
    &"act00.item.ivory_guides": "res://assets/art/act_00/ivory_guides.png",
    &"act00.item.brass_rails": "res://assets/art/act_00/brass_rails.png",
    &"act00.item.crystal_prism": "res://assets/art/act_00/crystal_prism.png",
    &"act00.item.smoked_lens": "res://assets/art/act_00/smoked_lens.png",
    &"act00.item.control_levers": "res://assets/art/act_00/control_levers.png",
    &"act00.item.clockwork_escapement": "res://assets/art/act_00/clockwork_escapement.png",
}

const REJECTION_TEXTS := [
    [&"act00.observation.reject.ivory_guides.crystal_prism", "The ivory is light and inert, but the optical cradle requires a faceted body to interrupt the light path. These smooth bars bridge the cradle without presenting any useful surface to the beam."],
    [&"act00.observation.reject.ivory_guides.control_levers", "The light ivory bars have neither a lever yoke nor joints for the paired pivots. Forcing them across the actuator pivot spacing would convert an electrical virtue into a mechanical absurdity."],
    [&"act00.observation.reject.brass_rails.ivory_guides", "The brass rails meet the guide sockets neatly, which makes their failure worth noticing. They are heavy and conductive; the longitudinal field would acquire both inertia and a path to earth."],
    [&"act00.observation.reject.brass_rails.crystal_prism", "Machining cannot make heavy, conductive brass serve as an optical element. The optical cradle encloses an opaque rail and receives no divided light path at all."],
    [&"act00.observation.reject.brass_rails.control_levers", "The heavy brass rails span the paired pivots but provide neither articulation nor a common lever yoke. Conductivity is no compensation for incompatible actuator geometry."],
    [&"act00.observation.reject.crystal_prism.ivory_guides", "The transparent prism enters one guide socket and leaves the other bare; its faceted body cannot occupy two parallel channels. A longitudinal guide must constrain motion, not merely sparkle beside it."],
    [&"act00.observation.reject.crystal_prism.control_levers", "The transparent, faceted prism has no journals for the actuator pivots and no lever yoke to move them together. A clean spectrum is persuasive evidence, but not of mechanical fitness."],
    [&"act00.observation.reject.smoked_lens.ivory_guides", "The smoked glass is broad, dark, and absorptive, while the guide sockets demand two slender longitudinal members. It touches both parallel channels badly and constrains neither."],
    [&"act00.observation.reject.smoked_lens.crystal_prism", "The smoked glass fits the optical cradle, but it absorbs the lamp instead of dividing it. Correct geometry is only half an answer when the light path emerges dimmer and spectrally unchanged."],
    [&"act00.observation.reject.smoked_lens.control_levers", "The smoked glass offers no lever yoke, and its nickel rim cannot engage the paired pivots. An absorbing optical surface is particularly unhelpful where actuator geometry requires free rotation."],
    [&"act00.observation.reject.control_levers.ivory_guides", "The low-friction lever yoke enters the longitudinal guide fitting crosswise, with the white handle projecting beyond one guide socket. It can initiate motion, but it cannot constrain a parallel translation."],
    [&"act00.observation.reject.control_levers.crystal_prism", "The white handle and low-friction lever yoke occupy the optical cradle but leave its light path blocked by metal. Nothing in this geometry can divide the beam, however agreeably the pivots move."],
    [&"act00.observation.reject.clockwork_escapement.ivory_guides", "The escapement wheel is precise, but its periodic arrest and added friction are fatal in the guide sockets. The longitudinal motion requires two continuous low-mass surfaces, not regulated hesitation."],
    [&"act00.observation.reject.clockwork_escapement.crystal_prism", "The clockwork escapement fills the optical cradle with brass teeth and periodic arrest. Its friction may regulate a clock admirably, but no transparent or faceted surface reaches the light path."],
    [&"act00.observation.reject.clockwork_escapement.control_levers", "The escapement's anchor can rock between the actuator pivots, yet its purpose is periodic arrest rather than a free paired command. Its friction would make every departure a negotiation with a clock."],
]

const DIAGNOSTIC_TEXTS := [
    [&"act00.observation.misfire.left_slow", "The lateral field pull is left of centre; the frame leans towards the cabinet before settling. The temporal cadence is slow, with each impulse arriving late enough to count by ear."],
    [&"act00.observation.misfire.left_correct", "The lateral field pull is left of centre, although the frame no longer gains or loses ground between beats. The temporal cadence is correct; only the sideways strain remains to be removed."],
    [&"act00.observation.misfire.left_fast", "The lateral field pull is left of centre and draws a blue edge along the cabinet side of the frame. The temporal cadence is fast, crowding one impulse upon the next before the anchor can settle."],
    [&"act00.observation.misfire.centred_slow", "The lateral field pull is centred; neither guide carries more strain than its fellow. The temporal cadence is slow, and the model completes each pulse after the chronometer has already advanced."],
    [&"act00.observation.misfire.centred_fast", "The lateral field pull is centred, for once giving me no quarrel. The temporal cadence is fast, a clipped succession of impulses that outruns the regulating beat."],
    [&"act00.observation.misfire.right_slow", "The lateral field pull is right of centre; the prism cradle shivers towards the window. The temporal cadence is slow, each pulse lingering when it ought to release."],
    [&"act00.observation.misfire.right_correct", "The lateral field pull is right of centre, visible in the unequal flex of the ivory bars. The temporal cadence is correct; lateral equilibrium alone prevents a clean displacement."],
    [&"act00.observation.misfire.right_fast", "The lateral field pull is right of centre and the window-side guide sings under strain. The temporal cadence is fast, delivering the next impulse before the previous one has decayed."],
]

func _initialize() -> void:
    var manifest := ActManifest.new()
    manifest.act_id = &"act00"
    manifest.title = "Act 0: The Model"
    manifest.items = [
        _item(
            &"act00.item.ivory_guides",
            "Ivory guide bars",
            "Twin ivory guides, smooth, light in hand, and electrically inert; their parallel faces were ground against the same datum."
        ),
        _item(
            &"act00.item.brass_rails",
            "Brass guide rails",
            "Two precisely machined brass rails, heavy for their size and plainly conductive, with mounting holes aligned to the model frame."
        ),
        _item(
            &"act00.item.crystal_prism",
            "Crystalline prism",
            "A transparent, faceted crystal prism whose clean spectral division gives each band of lamplight a separate path."
        ),
        _item(
            &"act00.item.smoked_lens",
            "Smoked-glass lens",
            "A smoked-glass lens in a nickel rim; the dark optical glass absorbs incident light rather than dividing its spectrum."
        ),
        _item(
            &"act00.item.control_levers",
            "Paired control levers",
            "A paired low-friction lever yoke, with the white departure handle moving beside its darker companion."
        ),
        _item(
            &"act00.item.clockwork_escapement",
            "Clockwork escapement",
            "A precise clockwork escapement whose wheel and anchor periodically arrest motion, adding regulation, friction, and delay."
        ),
    ]
    manifest.journal_entries = [
        _journal(
            &"act00.journal.experiment",
            "The model",
            "Three functions remain unresolved. The longitudinal guides must be light and electrically inert; the optical core must divide rather than extinguish light; the actuator must move as a low-friction pair. I shall test the model once before I submit the thing to witnesses."
        ),
        _journal(
            &"act00.journal.materials",
            "Candidate materials",
            "Ivory against brass, clear crystal against smoked glass, free levers against an escapement. Each pair offers similar geometry and a different physical answer. Appearances have agreed to be unhelpful, which is almost considerate of them."
        ),
        _journal(
            &"act00.journal.components",
            "Materials assembled",
            "All six candidates are at hand. Their masses, optical behaviour, conductivity, and resistance differ more honestly than their shapes. Selection should follow the recorded constraints, not the seductions of polished brass."
        ),
        _journal(
            &"act00.journal.spatial_datum",
            "Spatial datum",
            "The frame-mounted level settles only at the central mark. Lateral displacement must therefore begin at equilibrium: spatial datum 0."
        ),
        _journal(
            &"act00.journal.temporal_datum",
            "Temporal datum",
            "Against the house clock, the trial chronometer loses the interval recovered when advanced one division. Temporal bias must begin at +1."
        ),
        _journal(
            &"act00.journal.calibration",
            "Calibration",
            "The mechanism is assembled. Apply the independently observed spatial and temporal datums before drawing the white departure handle through its full travel."
        ),
        _journal(
            &"act00.journal.misfire",
            "An incomplete displacement",
            "The frame shuddered but did not depart. The mechanism is sound; the fault lies in my calibration."
        ),
        _journal(
            &"act00.journal.success",
            "Eleven seconds",
            "Four seconds passed in the workshop. The model's chronometer advanced fifteen. An error of measurement remains possible, but an error with a very particular direction, and one that has just crossed the room."
        ),
    ]
    manifest.observations = [
        _observation(&"act00.observation.notebook", "The ink is scarcely dry; the last three lines remain wet enough to shine beside a violet crust at the nib. I have specified functions rather than objects: light inert guides, an element that divides light, and a low-friction paired actuator. Better to make the mechanism answer the question than to tutor myself with labels."),
        _observation(&"act00.observation.notebook_after_datum", "A pencilled datum now stands beside the inked constraints, obtained from an instrument rather than rescued from preference. One measured fact is not a theory, but it is a welcome reduction in the number of ways I may be foolish."),
        _observation(&"act00.observation.notebook_calibration", "The construction pages are crowded with ticks, oil, and one small burn where confidence preceded insulation. The component constraints and measured datums now agree; whatever follows belongs to experiment, not assembly."),
        _observation(&"act00.observation.diagrams", "Compass arcs converge on three functional blocks, while a rejected field equation has been crossed through hard enough to score the paper beneath. The surviving sketch keeps mass away from the guides, separates the spectrum at the core, and couples the controls without a regulator."),
        _observation(&"act00.observation.diagrams_repeat", "The trial sketch is less elegant than yesterday's and more likely to work. Elegance is permitted to return after the apparatus has done so."),
        _observation(&"act00.observation.take_guides", "The ivory pair scarcely depresses the balance, while the brass rails drive its other pan down with theatrical certainty. A continuity probe leaves the ivory silent and the brass electrically candid. I take both; resemblance is not a measurement."),
        _observation(&"act00.observation.guides_taken", "Two pairs of long impressions remain in the cabinet velvet, one pale and one edged with brass filings. The balance still rocks from their comparison, but there is no further candidate hiding beneath it."),
        _observation(&"act00.observation.clock", "The house clock advances evenly while the trial chronometer drops one division over the marked interval. Advancing the trial regulator by one division restores coincidence across three repetitions. A domestic clock has contributed to temporal physics and will be intolerable about it."),
        _observation(&"act00.observation.clock_repeat", "The hands meet their comparison marks again with the trial regulator one division forward. Repetition has failed to improve the romance of the result, which is generally a sign that it may be useful."),
        _observation(&"act00.observation.glassware", "A violet residue clings above the meniscus in the exhausted discharge tube, but none has plated onto the insulated ivory chip beside it. The brass coupon carries a bright contact scar. Conductivity leaves better evidence than recollection."),
        _observation(&"act00.observation.glassware_repeat", "The residue has settled and the contact scar has not. Chemistry has completed its testimony; further heating would merely make the room smell decisive."),
        _observation(&"act00.observation.bench_missing", "Three empty fittings wait on the frame, but the candidate drawers are not yet exhausted. Building from the first plausible object would turn a material question into a habit. I have enough habits already."),
        _observation(&"act00.observation.bench_ready", "Six candidates lie beside three fittings, and each pair differs in a property the frame can expose. Everything required is here. Now accuracy must do what theory has promised."),
        _observation(&"act00.observation.bench_calibration", "The guides sit without loading the field, the prism cuts a narrow spectrum, and the paired handles move together without hesitation. Construction is no longer the uncertainty. The scales must now be made to agree with the room's evidence."),
        _observation(&"act00.observation.spirit_level", "The bubble runs left under negative excitation and right under positive, but settles between its etched lines at the central setting. I repeat the reversal twice with the same result. The spatial datum is equilibrium, not an offset disguised as one."),
        _observation(&"act00.observation.spirit_level_repeat", "The bubble returns to the centre mark after disturbance from either side. It is pleasant when an instrument answers the same question without developing a personality."),
        _observation(&"act00.observation.window", "Rain stipples the Richmond glass and runs downward in separate threads before joining at the sill. Beyond it, carriages pass at ordinary speed, indifferent to the several kinds of time accumulating on this bench."),
        _observation(&"act00.observation.window_repeat", "The rain has strengthened enough to erase the garden and leave my reflection among the instruments. The outside world remains a useful control, chiefly because it has not consented to the experiment."),
        _observation(&"act00.observation.take_prism", "The clear prism throws a clean spectral ladder across the card; the smoked lens leaves only a charcoal oval and a weaker lamp. Both share the cradle's width. I take both, since geometry has arranged an alibi for bad optics."),
        _observation(&"act00.observation.prism_taken", "The optical bench retains a bright spectrum on the card and a dark ring where the smoked lens rested. Neither candidate remains, only the evidence by which they should be judged."),
        _observation(&"act00.observation.take_levers", "The paired levers move through their arc under a breath, the white handle keeping exact company with its mate. The escapement advances tooth by tooth and arrests them with admirable precision. I take both; precision and freedom are not synonyms."),
        _observation(&"act00.observation.levers_taken", "Empty pivot pins and two ruby-coloured oil marks remain on the tray. The control candidates are already in hand, and the rejected frames can offer nothing further tonight."),
        _observation(&"act00.observation.displacement_rig", "This abandoned displacement rig carried a coil, a field compass, and several optimistic kilograms across the floor before it fused its contact. It was field apparatus for an earlier experiment, not a larger version of the present machine. Failure becomes less embarrassing once properly labelled."),
        _observation(&"act00.observation.displacement_rig_calibration", "The old rig's compass still kicks left and right with unequal excitation, though its carriage cannot move. It confirms direction but says nothing about cadence. I shall not ask a burnt contact to become a chronometer."),
        _observation(&"act00.observation.gas_lamp", "A narrowed gas flame gives the prism a sharper spectrum and the smoked lens a darker extinction. The mantle flutters whenever the frame is energised, a crude but immediate witness to each pulse."),
        _observation(&"act00.observation.gas_lamp_repeat", "The flame steadies when the circuit opens and bows towards the frame when it closes. It is not a measuring instrument, but it has the virtue of reacting before I can invent an explanation."),
        _observation(&"act00.observation.drafting_stool", "A calculation sheet lies under the stool, rejected after one denominator quietly changed dimensions halfway down the page. The stool has prevented it from returning to the desk, which is the soundest peer review it has received."),
        _observation(&"act00.observation.drafting_stool_repeat", "The discarded calculation remains pinned beneath one brass foot. Its arithmetic has not improved under pressure."),
        _observation(&"act00.observation.specimen_cabinet", "The cabinet seals waxed coils, cracked dielectrics, and a moth whose label predates my tenancy. None belongs to the model, but each records the useful moment when an assumption met matter."),
        _observation(&"act00.observation.specimen_cabinet_repeat", "Dust has entered the cabinet despite the felt seal, while common sense remains excluded with remarkable success. I leave both arrangements undisturbed."),
        _observation(&"act00.observation.apparatus", "A respectable collection of failures, each one useful enough to deserve dusting. The largest is an earlier displacement rig, not the machine I mean one day to build."),
        _observation(&"act00.observation.wrong_slot", "No. The fitting refuses it without force, which is more wisdom than many men display."),
        _observation(&"act00.observation.component_fitted", "The component seats without force and the witness marks remain aligned. One uncertainty removed; two are not invited to celebrate."),
        _observation(&"act00.observation.assembly_complete", "The three functions now share one frame, and each can still be examined independently. Construction has stopped being an excuse. Calibration may commence."),
        _observation(&"act00.observation.misfire", "A displacement begins, folds sideways, and collapses before the bench loses sight of the frame. The construction remains intact; the calibration, annoyingly but usefully, has supplied the failure."),
        _observation(&"act00.observation.excursion", "The frame thins to a bright edge and vanishes without smoke, debris, or the customary assistance of metaphor. For four seconds the bench is indisputably empty."),
        _observation(&"act00.observation.return", "The model returns with its oil still warm and its frame displaced less than a hair from the witness marks. Its chronometer reads fifteen seconds; the workshop clock has advanced four. I distrust both instruments equally, which is an excellent reason to repeat the experiment at full scale."),
    ]
    for values in REJECTION_TEXTS:
        manifest.observations.append(_observation(values[0], values[1]))
    for values in DIAGNOSTIC_TEXTS:
        manifest.observations.append(_observation(values[0], values[1]))

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
    value.icon = load(ITEM_ICON_PATHS[id]) as Texture2D
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
