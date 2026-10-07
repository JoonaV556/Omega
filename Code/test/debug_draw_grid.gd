@tool
class_name DebugDrawGrid
extends Node2D

## Size of each grid cell in pixels
@export var grid_cell_size: Vector2 = Vector2(64, 64):
	set(value):
		grid_cell_size = value
		queue_redraw()

## Color of the grid lines
@export var line_color: Color = Color(1, 1, 1, 0.3):
	set(value):
		line_color = value
		queue_redraw()

@export var grid_extent_pixels : Vector2 = Vector2(16*256, 16*256)

@export var editor_only : bool = true


func _draw() -> void:
	if editor_only and !Engine.is_editor_hint():
		return

	# Get the viewport visible rectangle
	var points := PackedVector2Array()

	# Center the grid on the node pivot and extend it equally in all directions.
	var x := -grid_extent_pixels.x
	while x <= grid_extent_pixels.x:
		points.append(Vector2(x, -grid_extent_pixels.y))
		points.append(Vector2(x, grid_extent_pixels.y))
		x += grid_cell_size.x

	# Horizontal lines
	var y := -grid_extent_pixels.y
	while y <= grid_extent_pixels.y:
		points.append(Vector2(-grid_extent_pixels.x, y))
		points.append(Vector2(grid_extent_pixels.x, y))
		y += grid_cell_size.y

	# Draw all line segments at once
	if points.size() > 0:
		draw_multiline(points, line_color)
