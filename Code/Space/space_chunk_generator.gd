class_name SpaceChunkGenerator
extends Node


@export var world_seed: int = 123

## Radius of (1,1) means chunks in 3x3 square are generated around player. (2, 2) means 5x5 square
@export var chunk_generation_radius: Vector2i = Vector2i(1, 1)

@export var chunk_nodes_parent: Node

@export_category("System generator params")
@export var num_planets_min = 1
@export var num_planets_max = 10
@export var planet_radius_min = 100.0
@export var planet_radius_max = 30000.0

var rng: RandomNumberGenerator

var loaded_chunks: Dictionary[Vector2i, Node2D]

var origin_chunk_coords: Vector2i

var player_initial_local_position: Vector2

var world_origin_global_position: Vector2


func init(chunk_coords: Vector2i, local_position: Vector2, world_position: Vector2):
	origin_chunk_coords = chunk_coords
	world_origin_global_position = world_position
	player_initial_local_position = local_position

	# init rng
	seed(world_seed)
	rng = RandomNumberGenerator.new()
	rng.seed = world_seed

	# Generate initial chunks
	generate_chunks_in_radius(chunk_coords, chunk_generation_radius)


func update_chunks(chunk_position: Vector2i, local_position: Vector2, world_positon: Vector2):
	# Generate new chunks

	# Unload old chunks

	pass


func generate_chunks_in_radius(chunk_coords: Vector2i, radius: Vector2i) -> Array[Vector2i]:
	var chunks_to_generate: Array[Vector2i] = []

	for x in range(chunk_coords.x - radius.x, chunk_coords.x + radius.x + 1):
		for y in range(chunk_coords.y - radius.y, chunk_coords.y + radius.y + 1):
			var candidate := Vector2i(x, y)
			if chunks_to_generate.has(candidate):
				continue

			chunks_to_generate.append(candidate)
			generate_chunk(candidate)

	return chunks_to_generate


func generate_chunk(chunk_coords: Vector2i):
	# Ensure chunk stays same across platforms with same seed
	var chunk_rng := RandomNumberGenerator.new()
	var chunk_hash = hash(Vector3i(chunk_coords.x, chunk_coords.y, world_seed))
	chunk_rng.seed = chunk_hash

	# Decide if system
	var has_system_roll := chunk_rng.randi_range(0, 1)
	var has_system = true if has_system_roll == 0 else false

	# Create root node for chunk
	var chunk_root := Node2D.new()
	chunk_root.name = String("Space chunk %s" % [chunk_coords])

	# add to tree
	if chunk_nodes_parent:
		chunk_nodes_parent.add_child(chunk_root)
	else:
		get_tree().add_child(chunk_root)

	# Position chunk
	var chunk_offset := chunk_coords - origin_chunk_coords
	var chunk_world_position := (world_origin_global_position - player_initial_local_position) + Vector2(
		chunk_offset.x * SpaceGlobals.chunk_size_pixels.x,
		chunk_offset.y * SpaceGlobals.chunk_size_pixels.y
	)
	chunk_root.global_position = chunk_world_position
	
	if !has_system:
		return

	# Generate system ...


func unload_stale_chunks():
	pass


func unload_chunk():
	pass
