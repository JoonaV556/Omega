## makes the node follow the position of the target object completely, or optionally on single axis
extends Node2D

@export var target:Node2D
@export var follow_x:bool = true
@export var follow_y:bool = true

func _process(_delta: float) -> void:
	var newpos = self.global_position
	if follow_x:
		newpos.x = target.global_position.x
	if follow_y:
		newpos.y = target.global_position.y
	self.global_position = newpos
