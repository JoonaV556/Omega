class_name SpaceChunkGenerator
extends RefCounted


enum ChunkDetailLevel {
	LOW, # Returns chunk without any object data, but contains system (if any) and its name
	MEDIUM, # Returns a chunk. If chunk has a system, contains primary object and its position in the system.
	FULL # Returns a chunk with complete object information (type, location, size etc.)
}


const _seed: int = 123

const _default_system_odds: float = 0.2


class generator_params:
	var has_system_odds: float = 0.2
	
	var planets_per_system_min: int = 1 
	var planets_per_system_max: int = 10
	
	var chunk_size_pixels: Vector2 = Vector2(5000.0, 5000.0)


static func generate_chunk(
	coords: Vector2i, 
	detail_level: ChunkDetailLevel = ChunkDetailLevel.FULL,
	params: generator_params = generator_params.new()
	) -> SpaceChunk:

	# Ensure chunk stays same across platforms with same seed
	var chunk_rng := RandomNumberGenerator.new()
	var chunk_hash = hash(Vector3i(coords.x, coords.y, _seed))
	chunk_rng.seed = chunk_hash

	var chunk := SpaceChunk.new(coords)

	# Decide if has system
	var has_system = chunk_rng.randf() <= params.has_system_odds
	
	# Generate empty system
	if has_system:
		var system := System.new(_generate_random_name(chunk_rng))
		chunk.system = system
	
	# Return with low detail
	if detail_level == ChunkDetailLevel.LOW:
		return chunk

	# Generate objects for the chunk
	var objects := _generate_objects(chunk_rng, detail_level, params)
	chunk.stellar_objects = objects

	return chunk


static func _generate_objects(
	rng: RandomNumberGenerator, 
	detail_level: ChunkDetailLevel, 
	params: generator_params = generator_params.new()
	) -> Dictionary[StellarObject, Vector2]:

	var objects: Dictionary[StellarObject, Vector2]

	# Generate objects by dividing the chunk into a grid and picking a cell for each object
	# Init grid variables
	var num_planets := rng.randi_range(params.planets_per_system_min, params.planets_per_system_max)
	var grid_size := _pick_planet_grid_size(num_planets)
	var chunk_size := params.chunk_size_pixels
	var cell_size := Vector2(
		chunk_size.x / float(grid_size.x),
		chunk_size.y / float(grid_size.y)
	)
	var occupied_cells: Dictionary = {}
	var free_cells: Array[Vector2i] = []

	## TODO LEFT HERE
	# Pick first generated planet as primary object and return if level == medium


	return objects


static func _generate_random_name(_rng: RandomNumberGenerator) -> String:
	var roots: Array = [
		"Aster", "Boreal", "Cinder", "Drift", "Eos", "Feral",
		"Gale", "Hallow", "Iris", "Juno", "Kite", "Lyra",
		"Mira", "Nyx", "Orion", "Peregrin", "Quill", "Rift",
		"Sol", "Talon", "Umbra", "Vega", "Warden", "Yara", "Zephyr"
	]
	var suffix := _rng.randi_range(1, 999)
	return "%s %s" % [roots[_rng.randi() % roots.size()], suffix]


static func _pick_planet_grid_size(num_planets: int) -> Vector2i:
	var columns := int(ceil(sqrt(float(maxi(1, num_planets)))))
	var rows := int(ceil(float(maxi(1, num_planets)) / float(columns)))
	return _clamp_grid_size(Vector2i(columns, rows))


static func _clamp_grid_size(grid_size: Vector2i) -> Vector2i:
	return Vector2i(
		maxi(1, grid_size.x),
		maxi(1, grid_size.y)
	)
