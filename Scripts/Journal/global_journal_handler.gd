extends Node

const JournalUI = preload("res://Scenes/Journal/JournalUI.tscn")

var journal_ui: JournalUI

func _ready():
	journal_ui = JournalUI.instantiate()
	
	add_child(journal_ui)
	journal_ui.hide()
	
func open_journal(journal: Journal):
	if journal_ui.visible: return
	journal_ui.load_journal(journal)
	journal_ui.show()
