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

	## Radius in pixels
	var planet_radius_min: float = 100.0
	var planet_radius_max: float = 2000.0
	
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

	if has_system: # Update objects for system too
		var system := chunk.system as System
		system.objects = objects.keys()
		system.primary_object = objects.keys()[0] # Pick primary object for the system

	return chunk


static func _generate_objects(
	rng: RandomNumberGenerator, 
	detail_level: ChunkDetailLevel, 
	params: generator_params = generator_params.new()
	) -> Dictionary[StellarObject, Vector2]:

	var objects: Dictionary[StellarObject, Vector2]

	## TODO - Anything past this line should be reworked once new stellar objects other than planets are introduced, and in case if chunk generation requires rework
	# Generate planets by dividing the chunk into a grid and picking a cell for each object
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

	for x in range(grid_size.x):
		for y in range(grid_size.y):
			free_cells.append(Vector2i(x, y))

	# Only generate primary object
	if detail_level == ChunkDetailLevel.MEDIUM:
		num_planets = 1

	# Place each planet in the grid
	for _planet_index in range(num_planets):
		if free_cells.is_empty():
			break

		# Pick a free grid cell for the planet
		var cell_index := rng.randi_range(0, free_cells.size() - 1) 
		var cell := free_cells[cell_index]
		free_cells.remove_at(cell_index) # Consume the cell so other planets cannot pick it

		# Place the planet in the center of the grid cell
		var cell_min := Vector2(cell.x * cell_size.x, cell.y * cell_size.y)
		var candidate_position := cell_min + (cell_size * 0.5)

		# Limit the radius of the planet so it doesnt extend over the chunk boundaries or occupied planet grid cells
		var max_radius := _get_max_radius_for_position(candidate_position, chunk_size, occupied_cells, cell_size, grid_size)
		var max_allowed_radius := minf(params.planet_radius_max, max_radius)
		if max_allowed_radius < params.planet_radius_min:
			continue

		var planet_radius := rng.randf_range(params.planet_radius_min, max_allowed_radius)
		var planet_name := _generate_random_name(rng)
		var planet: Planet = Planet.new(planet_name, planet_radius)

		objects[planet as StellarObject] = candidate_position
		
		# Mark the grid cell occupied so it wont be picked for other planets
		occupied_cells[cell] = true
		_consume_cells_for_radius(occupied_cells, candidate_position, planet_radius, chunk_size, grid_size, cell_size)

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


static func _get_max_radius_for_position(
	position: Vector2,
	chunk_size: Vector2,
	occupied_cells: Dictionary,
	cell_size: Vector2,
	grid_size: Vector2i
) -> float:
	var max_radius: float = min(
		position.x,
		chunk_size.x - position.x,
		position.y,
		chunk_size.y - position.y
	)
	if max_radius < 0.0:
		return 0.0

	for cell_key in occupied_cells.keys():
		var cell := cell_key as Vector2i
		var cell_min := Vector2(cell.x * cell_size.x, cell.y * cell_size.y)
		var cell_max := cell_min + cell_size
		var nearest_point := _clamp_point_to_rect(position, cell_min, cell_max)
		var distance_to_cell := position.distance_to(nearest_point)
		var allowed_radius := maxf(0.0, distance_to_cell - 0.001)
		if allowed_radius < max_radius:
			max_radius = allowed_radius

	return max_radius


static func _clamp_point_to_rect(point: Vector2, rect_min: Vector2, rect_max: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, rect_min.x, rect_max.x),
		clampf(point.y, rect_min.y, rect_max.y)
	)


static func _consume_cells_for_radius(
	occupied_cells: Dictionary,
	position: Vector2,
	radius: float,
	chunk_size: Vector2,
	grid_size: Vector2i,
	cell_size: Vector2
) -> void:
	var start_x := int(floor((position.x - radius) / cell_size.x))
	var end_x := int(ceil((position.x + radius) / cell_size.x))
	var start_y := int(floor((position.y - radius) / cell_size.y))
	var end_y := int(ceil((position.y + radius) / cell_size.y))

	start_x = clampi(start_x, 0, grid_size.x - 1)
	end_x = clampi(end_x, 0, grid_size.x - 1)
	start_y = clampi(start_y, 0, grid_size.y - 1)
	end_y = clampi(end_y, 0, grid_size.y - 1)

	for x in range(start_x, end_x + 1):
		for y in range(start_y, end_y + 1):
			var cell := Vector2i(x, y)
			if cell.x < 0 or cell.x >= grid_size.x:
				continue
			if cell.y < 0 or cell.y >= grid_size.y:
				continue
			occupied_cells[cell] = true
