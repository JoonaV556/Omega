extends Node2D
# Allows zooming in closer and further away from target
@export var camera: 	Camera2D
@export var zoom_step: 	float 	= 0.3
@export var min_zoom: 	Vector2 = Vector2(1.0, 1.0)
@export var max_zoom: 	Vector2 = Vector2(5.0, 5.0)
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ZoomIn"):
		if not (camera.zoom.x + zoom_step) >= max_zoom.x:
			camera.zoom.x += zoom_step
			camera.zoom.y += zoom_step
	if Input.is_action_just_pressed("ZoomOut"):
		if not (camera.zoom.x - zoom_step) <= min_zoom.x:
			camera.zoom.x -= zoom_step
			camera.zoom.y -= zoom_step
