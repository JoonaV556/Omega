extends Node

# const JournalUIScene = preload("res://Scenes/Journal/JournalUIObsolete.tscn")

var journal_ui: JournalUIObsolete

func _ready():
	# journal_ui = JournalUIScene.instantiate()
	
	add_child(journal_ui)
	journal_ui.hide()
	
func open_journal(journal: Journal):
	if journal_ui.visible: return
	journal_ui.load_journal(journal)
	journal_ui.show()
	
