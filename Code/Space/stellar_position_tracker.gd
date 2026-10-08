class_name StellarPositionTracker
extends Node


@export var start_chunk_coords: Vector2i = Vector2i(1000, 1000)

@export var start_local_position: Vector2 = SpaceGlobals.chunk_size_pixels / 2.0

@export var chunk_size_pixels: Vector2 = SpaceGlobals.chunk_size_pixels

var current_chunk_coordinates: Vector2i

var current_local_position: Vector2


func _ready() -> void:
	# Initialize
	set_position(start_chunk_coords, start_local_position)


func set_chunk_size(new_size: Vector2):
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
	current_local_position += movement_delta_pixels

	# Update on x axis
	while current_local_position.x >= chunk_size_pixels.x:
		current_local_position.x -= chunk_size_pixels.x
		current_chunk_coordinates.x += 1

	while current_local_position.x < 0.0:
		current_local_position.x += chunk_size_pixels.x
		current_chunk_coordinates.x -= 1

	# Update on y axis
	while current_local_position.y >= chunk_size_pixels.y:
		current_local_position.y -= chunk_size_pixels.y
		current_chunk_coordinates.y += 1

	while current_local_position.y < 0.0:
		current_local_position.y += chunk_size_pixels.y
		current_chunk_coordinates.y -= 1
