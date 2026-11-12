class_name Camera2DZoom
extends Node


# Allows zooming in closer and further away from target
@export var camera: 	Camera2D

@export var zoom_step: 	float 	= 0.3
@export var use_dynamic_zoom_step: bool = false
@export_range(1.0, 20.0, 0.5) var dynamic_zoom_step_range: float = 5.0

@export var min_zoom: 	Vector2 = Vector2(1.0, 1.0)
@export var max_zoom: 	Vector2 = Vector2(5.0, 5.0)


func _input(event: InputEvent) -> void:
	if !camera:
		var parent = get_parent() as Camera2D
		
		if parent:
			camera = parent
		else:
			return

	if event.is_action_pressed("ZoomIn"):
		var step := _get_zoom_step(camera.zoom, max_zoom)
		camera.zoom = Vector2(
			minf(camera.zoom.x + step.x, max_zoom.x),
			minf(camera.zoom.y + step.y, max_zoom.y)
		)
	if event.is_action_pressed("ZoomOut"):
		var step := _get_zoom_step(camera.zoom, min_zoom)
		camera.zoom = Vector2(
			maxf(camera.zoom.x - step.x, min_zoom.x),
			maxf(camera.zoom.y - step.y, min_zoom.y)
		)


func _get_zoom_step(current_zoom: Vector2, target_limit: Vector2) -> Vector2:
	var base_step := absf(zoom_step)
	if !use_dynamic_zoom_step:
		return Vector2.ONE * base_step

	return Vector2(
		_get_axis_zoom_step(current_zoom.x, target_limit.x, base_step),
		_get_axis_zoom_step(current_zoom.y, target_limit.y, base_step)
	)


func _get_axis_zoom_step(current_zoom: float, target_limit: float, base_step: float) -> float:
	var distance_to_limit := absf(target_limit - current_zoom)
	var taper_range := base_step * dynamic_zoom_step_range
	var progress := clampf(distance_to_limit / maxf(taper_range, 0.001), 0.0, 1.0)
	var eased_progress := progress * progress * (3.0 - 2.0 * progress)
	var step := lerpf(base_step * 0.1, base_step, eased_progress)

	return minf(step, distance_to_limit)


