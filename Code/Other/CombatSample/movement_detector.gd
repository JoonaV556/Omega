# probably doesn't work on physics bodies
class_name MovementDetector
extends Node

@export var target: Node2D

signal started_moving
signal stopped_moving

var moved_last_frame: bool = false

const move_treshold:float = 0.5 # pixels

var position_last_frame: Vector2 = Vector2.ZERO

func _ready() -> void:
	position_last_frame = target.global_position

func _process(delta: float) -> void:
	var moved_pixels: float = target.global_position.distance_to(position_last_frame)
	var moved_this_frame: bool = (moved_pixels > 0.0)
	
	if !moved_last_frame and moved_this_frame:
		started_moving.emit()
	
	if moved_last_frame and !moved_this_frame:
		stopped_moving.emit()
	
	# reset state
	position_last_frame = target.global_position
	moved_last_frame = moved_this_frame
