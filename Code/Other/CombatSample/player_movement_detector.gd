class_name CharacterMovementDetector
extends Node

@export var character: Character

var moved_last_frame: bool = false

signal started_moving
signal stopped_moving

func _process(delta: float) -> void:
	var moved_this_frame: bool = (character.velocity.length() > 0.0)
	
	if (not moved_last_frame) and moved_this_frame:
		#print("character started moving")
		started_moving.emit()
	
	if (not moved_this_frame) and moved_last_frame:
		#print("character stopped moving")
		stopped_moving.emit()
	
	moved_last_frame = moved_this_frame
