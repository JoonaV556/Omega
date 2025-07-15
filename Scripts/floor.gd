class_name Floor
extends Node2D

func _ready():
	for node in get_children():
		if not node.has_meta("is_player"):
			continue
		show()
		return
	
	hide()
