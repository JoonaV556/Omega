class_name GhostMoveTo
extends Node

@export var imitation_target: Character
@export var move_speed: float = 2*16.0
@export var target_pos: Vector2
@export var target_pos_anchor: Node2D

signal on_done

var move = false
var parent: Node2D

func execute_moveto():
	parent = get_parent()
	parent.global_position = imitation_target.global_position
	if target_pos_anchor:
		target_pos = target_pos_anchor.global_position
	move = true

func _process(delta):
	if move:
		var amnt = delta * move_speed
		var dir = parent.global_position.direction_to(target_pos).normalized()
		parent.translate(dir * amnt)

		if parent.global_position.distance_to(target_pos) < 1.0:
			move = false
			on_done.emit()
