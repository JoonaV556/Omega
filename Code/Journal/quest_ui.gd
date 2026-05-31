class_name QuestUI
extends VBoxContainer

@onready var title_label: Label = get_node("%Label - Title")
@onready var notes_cont: VBoxContainer = get_node("%VBoxContainer - Notes")

func set_title(title: String):
	title_label.text = title

func add_note(note: String):
	var n_lab = Label.new()
	n_lab.text = note
	notes_cont.add_child(n_lab)

func mark_complete(complete: bool):
	pass
