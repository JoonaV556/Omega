class_name Floor
extends Node2D

@export var collision_layer: int = 1

func _ready():
	for node in get_children():
		if node is CollisionObject2D:
			node.set_collision_layer(collision_layer)
			node.set_collision_mask(collision_layer)
			
		if not node.has_meta("is_player"):
			continue
		show()
		return
	
	hide()
