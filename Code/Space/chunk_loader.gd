class_name ChunkLoader
extends Node


enum LoadingMethod { CIRCULAR, SQUARE }

@export var chunk_loading_radius: Vector2i = Vector2i(1, 1)
@export var loading_method: LoadingMethod = LoadingMethod.CIRCULAR

signal on_chunk_loaded(coords: Vector2i)
signal on_chunk_unloaded(coords: Vector2i)

var loaded_chunks: Dictionary[Vector2i, bool]


func init(initial_chunk_coords: Vector2i) -> void:
	update_chunks(initial_chunk_coords)


func update_chunks(current_chunk_coords: Vector2i) -> void:
	load_chunks_in_radius(current_chunk_coords, chunk_loading_radius)
	unload_chunks_outside_radius(current_chunk_coords, chunk_loading_radius)


func load_chunks_in_radius(center: Vector2i, radius: Vector2i) -> Array[Vector2i]:
	var safe_radius := Vector2i(maxi(0, radius.x), maxi(0, radius.y))
	var newly_loaded: Array[Vector2i] = []

	for x_offset in range(-safe_radius.x, safe_radius.x + 1):
		for y_offset in range(-safe_radius.y, safe_radius.y + 1):
			var coords := center + Vector2i(x_offset, y_offset)
			if _is_within_loading_area(Vector2i(x_offset, y_offset), safe_radius):
				if _load_chunk(coords):
					newly_loaded.append(coords)

	return newly_loaded


func unload_chunks_outside_radius(center: Vector2i, radius: Vector2i) -> void:
	var safe_radius := Vector2i(maxi(0, radius.x), maxi(0, radius.y))
	for coords in loaded_chunks.duplicate():
		if not _is_within_loading_area(coords - center, safe_radius):
			_unload_chunk(coords)


func _load_chunk(coords: Vector2i) -> bool:
	if loaded_chunks.has(coords):
		return false

	loaded_chunks[coords] = true
	on_chunk_loaded.emit(coords)
	return true


func _unload_chunk(coords: Vector2i) -> bool:
	if not loaded_chunks.has(coords):
		return false

	loaded_chunks.erase(coords)
	on_chunk_unloaded.emit(coords)
	return true


func is_loaded(coords: Vector2i) -> bool:
	return loaded_chunks.has(coords)


func _is_within_loading_area(offset: Vector2i, radius: Vector2i) -> bool:
	if loading_method == LoadingMethod.SQUARE:
		return abs(offset.x) <= radius.x and abs(offset.y) <= radius.y

	if (radius.x == 0 and offset.x != 0) or (radius.y == 0 and offset.y != 0):
		return false

	var normalized_x := 0.0 if radius.x == 0 else float(offset.x) / radius.x
	var normalized_y := 0.0 if radius.y == 0 else float(offset.y) / radius.y
	return normalized_x * normalized_x + normalized_y * normalized_y <= 1.0