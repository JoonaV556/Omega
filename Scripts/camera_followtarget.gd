extends Camera2D
# Makes the camera follow the given target object on screen
@export var target: Node2D
func _process(delta: float) -> void:
	position = target.position
