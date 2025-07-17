# Makes the camera follow the given target object on screen
extends Node2D
@export var camera: Camera2D
@export var target: Node2D
func _process(delta: float) -> void:
	if target == null:
		return
	if camera == null:
		return
	camera.position = target.position
