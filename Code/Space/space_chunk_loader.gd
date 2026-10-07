class_name SpaceChunkGenerator
extends Node


const world_seed: int = 123

## Radius of (1,1) means chunks in 3x3 square are generated around player. (2, 2) means 5x5 square
@export var chunk_generation_radius: Vector2i = Vector2i(1, 1)

@export_category("System generator params")
@export var chunk_has_system_odds: float = 0.2
@export var planets_per_system_min = 1
@export var planets_per_system_max = 10
## Minimum radius of generated planets in pixels
@export var planet_radius_min = 100.0
## Maximum radius of generated planets in pixels
@export var planet_radius_max = 30000.0

signal on_chunk_loaded(chunk: SpaceChunk)
signal on_chunk_unloaded(chunk: SpaceChunk)
signal on_chunk_loaded_at_coords(chunk_coords: Vector2i)

var loaded_chunks: Dictionary[Vector2i, Chunk]

var origin_chunk_coords: Vector2i


func init(initial_chunk_coords: Vector2i):
	# init rng
	seed(world_seed)

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
	# Ensure chunk stays same across platforms with same seed
	var chunk_rng := RandomNumberGenerator.new()
	var chunk_hash = hash(Vector3i(chunk_coords.x, chunk_coords.y, world_seed))
	chunk_rng.seed = chunk_hash

	var chunk = SpaceChunk.new(chunk_coords)

	# Decide if system
	var has_system = chunk_rng.randf() <= chunk_has_system_odds
	
	if has_system:
		# create planets data
		var planets_data := _generate_planets(chunk_rng)

		# Stupid middle step because typed dicts are strictly typed
		var chunk_objects : Dictionary[StellarObject, Vector2]
		for planet: Planet in planets_data.keys():
			chunk_objects[planet as StellarObject] = planets_data[planet]

		# Generate system ...
		# create system with random name
		var pivot_idx = chunk_rng.randi_range(0, planets_data.keys().size() - 1)
		var pivot_planet = planets_data.keys()[pivot_idx]
		var system := System.new(_generate_random_name(chunk_rng), pivot_planet)
		chunk.stellar_type = system
		chunk.stellar_objects = chunk_objects

		for planet in planets_data.keys():
			system.objects.append([planet, planets_data[planet]])

		# Print descriptive summary of generated planets
		print("\nChunk %s generated with system: %s. Chunk has %s planet(s):" % [chunk_coords, system.name, planets_data.size()])
		for planet in planets_data.keys():
			var position = planets_data[planet]
			print("\t - %s: radius=%s, position=%s" % [planet.name, planet.radius_pixels, position])

	# Load the chunk
	loaded_chunks[chunk.coordinates] = chunk

	on_chunk_loaded.emit(chunk)
	on_chunk_loaded_at_coords.emit(chunk_coords)

	return chunk


func generate_chunk(chunk_coords: Vector2i, _has_system_odds: float) -> SpaceChunk:
	# Ensure chunk stays same across platforms with same seed
	var chunk_rng := RandomNumberGenerator.new()
	var chunk_hash = hash(Vector3i(chunk_coords.x, chunk_coords.y, world_seed))
	chunk_rng.seed = chunk_hash

	var chunk := SpaceChunk.new(chunk_coords)

	# Decide if system
	var has_system = chunk_rng.randf() <= _has_system_odds
	
	if has_system:
		# create planets data
		var planets_data := _generate_planets(chunk_rng)

		# Stupid middle step because typed dicts are strictly typed
		var chunk_objects : Dictionary[StellarObject, Vector2]
		for planet: Planet in planets_data.keys():
			chunk_objects[planet as StellarObject] = planets_data[planet]

		# Generate system ...
		# create system with random name
		var pivot_idx = chunk_rng.randi_range(0, planets_data.keys().size() - 1)
		var pivot_planet = planets_data.keys()[pivot_idx]
		var system := System.new(_generate_random_name(chunk_rng), pivot_planet)
		chunk.stellar_type = system
		chunk.stellar_objects = chunk_objects

		for planet in planets_data.keys():
			system.objects.append([planet, planets_data[planet]])

		# Print descriptive summary of generated planets
		print("\nChunk %s generated with system: %s. Chunk has %s planet(s):" % [chunk_coords, system.name, planets_data.size()])
		for planet in planets_data.keys():
			var position = planets_data[planet]
			print("\t - %s: radius=%s, position=%s" % [planet.name, planet.radius_pixels, position])

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


## Returns a dictionary of planets and their theoretical positions inside the chunk
func _generate_planets(chunk_rng: RandomNumberGenerator) -> Dictionary[Planet, Vector2]:
	var num_planets := chunk_rng.randi_range(planets_per_system_min, planets_per_system_max)
	var grid_size := _pick_planet_grid_size(num_planets)
	var chunk_size := SpaceGlobals.chunk_size_pixels
	var cell_size := Vector2(
		chunk_size.x / float(grid_size.x),
		chunk_size.y / float(grid_size.y)
	)
	var occupied_cells: Dictionary = {}
	var free_cells: Array[Vector2i] = []
	var planets_data: Dictionary[Planet, Vector2] = {}

	for x in range(grid_size.x):
		for y in range(grid_size.y):
			free_cells.append(Vector2i(x, y))

	for _planet_index in range(num_planets):
		if free_cells.is_empty():
			break

		var cell_index := chunk_rng.randi_range(0, free_cells.size() - 1) # Pick a free grid cell for the planet
		var cell := free_cells[cell_index]
		free_cells.remove_at(cell_index) # Consume the cell so other planets cannot pick it

		# Place the planet in the center of the grid cell
		var cell_min := Vector2(cell.x * cell_size.x, cell.y * cell_size.y)
		var candidate_position := cell_min + (cell_size * 0.5)

		# Limit the radius of the planet so it doesnt extend over the chunk boundaries or occupied planet grid cells
		var max_radius := _get_max_radius_for_position(candidate_position, chunk_size, occupied_cells, cell_size, grid_size)
		var max_allowed_radius := minf(planet_radius_max, max_radius)
		if max_allowed_radius < planet_radius_min:
			continue

		var planet_radius := chunk_rng.randf_range(planet_radius_min, max_allowed_radius)
		var planet_name := _generate_random_name(chunk_rng)
		var planet: Planet = Planet.new(planet_name, planet_radius)
		planets_data[planet] = candidate_position
		occupied_cells[cell] = true
		_consume_cells_for_radius(occupied_cells, candidate_position, planet_radius, chunk_size, grid_size, cell_size)

	print('Succesfully generated %s planets out of initial target number of %s planets.' % [planets_data.keys().size(), num_planets])

	return planets_data


static func _pick_planet_grid_size(num_planets: int) -> Vector2i:
	var columns := int(ceil(sqrt(float(maxi(1, num_planets)))))
	var rows := int(ceil(float(maxi(1, num_planets)) / float(columns)))
	return _clamp_grid_size(Vector2i(columns, rows))


static func _clamp_grid_size(grid_size: Vector2i) -> Vector2i:
	return Vector2i(
		maxi(1, grid_size.x),
		maxi(1, grid_size.y)
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


static func _generate_random_name(_rng: RandomNumberGenerator) -> String:
	var roots: Array = [
		"Aster", "Boreal", "Cinder", "Drift", "Eos", "Feral",
		"Gale", "Hallow", "Iris", "Juno", "Kite", "Lyra",
		"Mira", "Nyx", "Orion", "Peregrin", "Quill", "Rift",
		"Sol", "Talon", "Umbra", "Vega", "Warden", "Yara", "Zephyr"
	]
	var suffix := _rng.randi_range(1, 999)
	return "%s %s" % [roots[_rng.randi() % roots.size()], suffix]
