class_name Quest
extends Resource

@export var title: String
@export var unique_name: StringName
## Ordered by oldest note first
@export var notes: PackedStringArray 
@export var completed: bool

signal on_note_added(note: String)

var notes_active: PackedStringArray # ordered by oldest (firstly added) note first

var notes_pending: PackedStringArray # ordered by next note to be added first 

var first_note: bool = true

## "advances" quest forward kinda like in stages
func next_note() -> String:
	if first_note: # stupid, but initializing notes_pending in func _init() does not work correctly
		notes_pending = notes.duplicate()
		first_note = false

	var n = notes_pending.get(0)
	notes_active.push_back(n)
	notes_pending.remove_at(0)
	on_note_added.emit(n)
	return n

func add_note(note: String):
	notes.insert(0, note)

func set_completed(value: bool):
	completed = value
