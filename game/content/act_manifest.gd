class_name ActManifest
extends Resource

@export var act_id: StringName
@export var title := ""
@export var items: Array[ItemDefinition] = []
@export var journal_entries: Array[JournalEntryDefinition] = []
@export var observations: Array[ObservationDefinition] = []
