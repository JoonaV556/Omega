@tool
class_name JournalUIObsolete
extends CanvasLayer

@onready var quest_titles: ItemList = $Background/MarginContainer/PanelContainer/HSplitContainer/QuestTitleContainer
@onready var quest_notes: VBoxContainer = $Background/MarginContainer/PanelContainer/HSplitContainer/ScrollContainer/QuestNoteContainer

var journal: Journal

func _is_debug():
	return self == get_tree().current_scene

func _ready():
	quest_titles.item_clicked.connect(_on_quest_selected)
	
	if not Engine.is_editor_hint() and _is_debug():
		var test_journal = Journal.new()
		test_journal.add_quest(preload("res://Resources/Quests/fuck_around.tres"))
		test_journal.add_quest(preload("res://Resources/Quests/find_out.tres"))
		
		load_journal(test_journal)
	
func load_journal(journal_to_load: Journal):
	_clear()
	
	journal = journal_to_load
	
	for quest in journal.quests:
		quest_titles.add_item(quest.title)

func _on_quest_selected(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_LEFT: return
	_load_quest_notes_by_index(index, journal)

func _load_quest_notes_by_index(index: int, _journal: Journal):
	if _journal == null or _journal.quests.size()-1 < index: return
	var notes = _journal.quests[index].notes
	
	_clear_quest_notes()
	for note in notes:
		_add_quest_note(note)
	
func _add_quest_note(note: String):
	var note_label = Label.new()
	quest_notes.add_child(note_label)
	note_label.text = note

func _clear_quest_titles():
	for index in range(quest_titles.item_count):
		quest_titles.remove_item(index)

func _clear_quest_notes():
	for child in quest_notes.get_children():
		quest_notes.remove_child(child)

func _clear():
	_clear_quest_titles()
	_clear_quest_notes()

func _close():
	hide()
	_clear()

func _input(_event):
	if Input.is_action_just_released("Close Journal"):
		_close()
