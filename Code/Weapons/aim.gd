class_name Aim
extends Node2D

@export var lookat_target_override: Node2D

func _process(delta: float) -> void:
	if lookat_target_override:
		self.look_at(lookat_target_override.global_position)
	else:
		var mouse_pos = get_global_mouse_position()
		self.look_at(mouse_pos)
