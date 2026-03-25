# Makes the camera follow the given target object on screen
extends Node2D
@export var camera: Camera2D
@export var target: Node2D
func _process(_delta: float) -> void:
	if target == null:
		return
	if camera == null:
		return
	camera.global_position = target.global_position
