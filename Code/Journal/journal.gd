class_name Journal
extends Node2D

var quests: Array[Quest] # Ordered by newest quest first

func _ready():
	quests = []
	
func add_quest(quest: Quest):
	quests.push_front(quest)
