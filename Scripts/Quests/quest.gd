class_name Quest
extends Resource

@export var title: String
@export var notes: PackedStringArray # Ordered by newest note first
@export var completed: bool

func add_note(note: String):
	notes.insert(0, note)

func set_completed(value: bool):
	completed = value
