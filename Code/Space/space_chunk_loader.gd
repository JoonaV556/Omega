class_name SpaceChunkLoader
extends Node

## Radius of (1,1) means chunks in 3x3 square are generated around player. (2, 2) means 5x5 square
@export var chunk_generation_radius: Vector2i = Vector2i(1, 1)


signal on_chunk_loaded(chunk: SpaceChunk)
signal on_chunk_unloaded(chunk: SpaceChunk)
signal on_chunk_loaded_at_coords(chunk_coords: Vector2i)

var loaded_chunks: Dictionary[Vector2i, Chunk]

var origin_chunk_coords: Vector2i


func init(initial_chunk_coords: Vector2i):
	# init rng
	seed(SpaceChunkGenerator._seed)

	# Generate initial chunks
	load_chunks_in_radius(initial_chunk_coords, chunk_generation_radius)


## Loads unloaded chunks in radius and unloads stale chunks outside of radius
func update_chunks(current_chunk: Vector2i):
	# Load new chunks
	load_chunks_in_radius(current_chunk, chunk_generation_radius)

	# Unload old chunks
	unload_chunks_outside_radius(current_chunk)


func load_chunks_in_radius(chunk_coords: Vector2i, radius: Vector2i) -> Array[Vector2i]:
	var chunks_to_load: Array[Vector2i] = []

	for x in range(chunk_coords.x - radius.x, chunk_coords.x + radius.x + 1):
		for y in range(chunk_coords.y - radius.y, chunk_coords.y + radius.y + 1):
			var candidate := Vector2i(x, y)
			if chunks_to_load.has(candidate):
				continue
			
			if is_loaded(candidate):
				continue 

			chunks_to_load.append(candidate)
			load_chunk(candidate)
	
	print('\nLoaded %s new chunks for %s in radius of %s.' % [chunks_to_load.size(), chunk_coords, chunk_generation_radius])

	return chunks_to_load


func load_chunk(chunk_coords: Vector2i) -> SpaceChunk:
	# Generate chunk
	var chunk := SpaceChunkGenerator.generate_chunk(chunk_coords, SpaceChunkGenerator.ChunkDetailLevel.FULL)

	# Load the chunk
	loaded_chunks[chunk.coordinates] = chunk

	on_chunk_loaded.emit(chunk)
	on_chunk_loaded_at_coords.emit(chunk_coords)

	return chunk


func unload_chunks_outside_radius(chunk_coords: Vector2i):
	var chunks_to_unload: Array[Vector2i] = []

	for loaded_coords in loaded_chunks.keys():
		var offset: Vector2i = loaded_coords - chunk_coords
		if abs(offset.x) > chunk_generation_radius.x or abs(offset.y) > chunk_generation_radius.y:
			chunks_to_unload.append(loaded_coords)

	for stale_coords in chunks_to_unload:
		unload_chunk(stale_coords)


func unload_chunk(chunk_coords: Vector2i) -> void:
	if !loaded_chunks.has(chunk_coords):
		return
		
	var chunk := loaded_chunks[chunk_coords] as SpaceChunk
	loaded_chunks.erase(chunk_coords)
	on_chunk_unloaded.emit(chunk)


func is_loaded(chunk_coords: Vector2i):
	return loaded_chunks.has(chunk_coords)
