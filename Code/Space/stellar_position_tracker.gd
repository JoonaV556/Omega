class_name StellarPositionTracker
extends Node


@export var start_chunk_coords: Vector2i = Vector2i(1000, 1000)

@export var start_local_position: Vector2 = SpaceGlobals.chunk_size_pixels / 2.0

@export var chunk_size_pixels: Vector2 = SpaceGlobals.chunk_size_pixels


signal on_current_chunk_changed(new_chunk: Vector2i)


var current_chunk_coordinates: Vector2i

var current_local_position: Vector2


func _ready() -> void:
	# Initialize
	set_position(start_chunk_coords, start_local_position)


func set_chunk_size_pixels(new_size: Vector2):
	chunk_size_pixels = new_size
	
	# Clamp current position inside new chunk size limits
	set_position(current_chunk_coordinates, current_local_position)


func set_position(chunk_coords: Vector2i, local_pos: Vector2):
	current_chunk_coordinates = chunk_coords
	current_local_position = local_pos.clamp(
		Vector2.ZERO,
		chunk_size_pixels
	)


func move(movement_delta_pixels: Vector2):
	# Update position
	var new_local_position := current_local_position + movement_delta_pixels
	var new_chunk_coordinates := current_chunk_coordinates

	var old_chunk := current_chunk_coordinates

	# Update on x axis
	while new_local_position.x >= chunk_size_pixels.x:
		new_local_position.x -= chunk_size_pixels.x
		new_chunk_coordinates.x += 1

	while new_local_position.x < 0.0:
		new_local_position.x += chunk_size_pixels.x
		new_chunk_coordinates.x -= 1

	# Update on y axis
	while new_local_position.y >= chunk_size_pixels.y:
		new_local_position.y -= chunk_size_pixels.y
		new_chunk_coordinates.y += 1

	while new_local_position.y < 0.0:
		new_local_position.y += chunk_size_pixels.y
		new_chunk_coordinates.y -= 1

	set_position(new_chunk_coordinates, new_local_position)

	if old_chunk != current_chunk_coordinates:
		on_current_chunk_changed.emit(current_chunk_coordinates)