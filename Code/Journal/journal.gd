class_name Journal
extends Node

var quests: Array[Quest] # Ordered by newest quest first

signal journal_init(quests: Array[Quest])
signal on_quest_added(q: Quest)
signal on_quest_note_added(q: Quest, note: String)
signal on_quest_completed(q: Quest)

func _ready():
	quests = []
	journal_init.emit(quests)
	
func add_quest(quest: Quest, add_initial_note: bool = false):
	quests.push_front(quest)
	on_quest_added.emit(quest)
	
	if add_initial_note:
		quest_advance_notes(quest)

func add_quest_by_uid(uid: StringName, add_initial_note: bool = false):
	var q = load(uid) as Quest
	add_quest(q, add_initial_note)

## see [member Quest.unique_name]
func quest_advance_notes_by_name(quest_unique_name: StringName):
	print_debug("advancing quest...")
	for q in quests:
		if q.unique_name == quest_unique_name:
			quest_advance_notes(q)

func quest_advance_notes(quest: Quest):
	var note = quest.next_note()
	on_quest_note_added.emit(quest, note)

func quest_mark_complete(quest_unique_name: StringName, complete_value: bool = true, mark_with_note: bool = false):
	for q in quests:

		if q.unique_name == quest_unique_name:
			q.set_completed(complete_value)
			on_quest_completed.emit(q)
			if mark_with_note:
				quest_advance_notes(q)
