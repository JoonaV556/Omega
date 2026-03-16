class_name Aim
extends Node2D

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	self.look_at(mouse_pos)
