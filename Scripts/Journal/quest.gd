class_name Quest
extends Node2D

var title: String
var notes: Array[Note] # Ordered by newest note first
var completed: bool

func _init(quest_title: String):
	title = quest_title
	notes = []
	completed = false

func add_note(note: Note):
	notes.push_front(note)

func set_completed(value: bool):
	completed = value
