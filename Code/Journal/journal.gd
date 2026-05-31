class_name Journal
extends Node

var quests: Array[Quest] # Ordered by newest quest first

signal journal_init(quests: Array[Quest])
signal journal_quest_added(q: Quest)

func _ready():
	quests = []
	journal_init.emit(quests)
	
func add_quest(quest: Quest):
	quests.push_front(quest)
	journal_quest_added.emit(quest)
