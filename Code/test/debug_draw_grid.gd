@tool
extends Node2D

## Size of each grid cell in pixels
@export var grid_size: Vector2 = Vector2(64, 64):
	set(value):
		grid_size = value
		queue_redraw()

## Color of the grid lines
@export var line_color: Color = Color(1, 1, 1, 0.3):
	set(value):
		line_color = value
		queue_redraw()

@export var grid_extent_pixels : Vector2 = Vector2(16*256, 16*256)


func _draw() -> void:
	# Get the viewport visible rectangle
	var viewport_rect := get_viewport_rect()
	var points := PackedVector2Array()

	# Vertical lines
	var x := 0.0
	while x <= grid_extent_pixels.x:
		points.append(Vector2(x, 0))
		points.append(Vector2(x, grid_extent_pixels.y))
		x += grid_size.x

	# Horizontal lines
	var y := 0.0
	while y <= grid_extent_pixels.y:
		points.append(Vector2(0, y))
		points.append(Vector2(grid_extent_pixels.x, y))
		y += grid_size.y

	# Draw all line segments at once
	if points.size() > 0:
		draw_multiline(points, line_color)
