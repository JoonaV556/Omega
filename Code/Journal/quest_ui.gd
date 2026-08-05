class_name QuestUI
extends VBoxContainer

@onready var title_label: Label = get_node("%Label - Title")
@onready var notes_cont: VBoxContainer = get_node("%VBoxContainer - Notes")
@export var note_font_size: int = 14

func set_title(title: String):
	title_label.text = title

func add_note(note: String):
	var n_lab: Label = Label.new()
	n_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n_lab.text = note

	var st = LabelSettings.new()
	st.font_size = note_font_size
	n_lab.label_settings = st

	notes_cont.add_child(n_lab)

func mark_complete(complete: bool):
	if !complete:
		return
	var c_txt = str("[DONE] "+str(title_label.text))
	title_label.text = c_txt
