class_name Journal
extends Node

var quests: Array[Quest] # Ordered by newest quest first

signal journal_init(quests: Array[Quest])
signal on_quest_added(q: Quest)
signal on_quest_note_added(q: Quest, note: String)

func _ready():
	quests = []
	journal_init.emit(quests)
	
func add_quest(quest: Quest, add_initial_note: bool = false):
	quests.push_front(quest)
	on_quest_added.emit(quest)
	
	if add_initial_note:
		advance_quest_notes(quest.unique_name)

## see [member Quest.unique_name]
func advance_quest_notes(quest_unique_name: StringName):
	print_debug("advancing quest...")
	for q in quests:
		if q.unique_name == quest_unique_name:
			var note = q.next_note()
			on_quest_note_added.emit(q, note)

func add_quest_by_uid(uid: StringName, add_initial_note: bool = false):
	var q = load(uid) as Quest
	add_quest(q, add_initial_note)
	
