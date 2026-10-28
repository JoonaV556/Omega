class_name SpaceChunkGenerator
extends RefCounted


enum ChunkDetailLevel {
	LOW, ## Returns chunk without any object data. Contains parent galaxy (if any) and system (if any).
	MEDIUM, ## Returns a chunk with orbital structure (excluding body sizes and orbit radiuses) If chunk has a system, system contains primary object.
	FULL ## Returns a chunk with complete object information (type, location, size etc.)
}


const _seed: int = 123

const _default_system_odds: float = 0.2


class generator_params:
	var chunk_belongs_to_galaxy_odds: float = 0.3

	var has_system_odds_in_galaxy: float = 0.2
	var has_system_odds_no_galaxy: float = 0.05

	var bodies_per_system_min: int = 1 
	var bodies_per_system_max: int = 10

	var has_bodies_odds_without_system: float = 0.02

	var bodies_without_system_min: int = 1 
	var bodies_without_system_max: int = 3

	## Radius in pixels
	var planet_radius_min: float = 100.0
	var planet_radius_max: float = 2000.0
	
	var chunk_size_pixels: Vector2 = Vector2(5000.0, 5000.0)

	var orbit_around_empty_center_odds: float = 0.1

	## Odds for a body to orbit around the center (root) body. Lower values introduce more complex orbits.
	var secondary_body_orbit_around_center_odds: float = 0.4
	
	var orbital_center_grid_size: Vector2i = Vector2i(3, 3)

	var minimum_orbit_radius: float = 100.0

	var physical_body_minimum_size_radius: float = 10.0

	# Orbital spin and velocity 
	var body_min_spin_speed: float = 1.0
	var body_max_spin_speed: float = 4.0

	## Pixels per second
	var root_min_orbital_velocity: float = 5.0
	var root_max_orbital_velocity: float = 10.0

	var orbital_velocity_scale: float = 30.0

static func generate_chunk_old(
	coords: Vector2i, 
	detail_level: ChunkDetailLevel = ChunkDetailLevel.FULL,
	params: generator_params = SpaceGlobals.get_chunk_generator_params()
	) -> SpaceChunk:

	# Ensure chunk stays same across platforms with same seed
	var chunk_rng := RandomNumberGenerator.new()
	var chunk_hash = hash(Vector3i(coords.x, coords.y, _seed))
	chunk_rng.seed = chunk_hash

	var chunk := SpaceChunk.new(coords)

	# Decide if chunk belongs to a galaxy
	var gal := _generate_galaxy(coords, params.chunk_belongs_to_galaxy_odds)

	if gal:
		chunk.galaxy = gal

	# Decide if has system
	var system_odds: float = params.has_system_odds_no_galaxy

	if gal:
		system_odds = params.has_system_odds_in_galaxy

	var has_system = chunk_rng.randf() <= system_odds
	
	# Generate empty system
	if has_system:
		var system := System.new(_generate_random_name(chunk_rng))
		chunk.system = system
	
	# Return with low detail
	if detail_level == ChunkDetailLevel.LOW:
		return chunk

	# Generate objects for the chunk
	if has_system:
		var objects := _generate_objects(chunk_rng, detail_level, params)
		chunk.objects = objects

		# Update objects for system too
		var system := chunk.system as System
		system.objects = objects.keys()
		system.primary_object = objects.keys()[0] # Pick primary object for the system

	return chunk


static func generate_chunk(
	coords: Vector2i, 
	detail_level: ChunkDetailLevel = ChunkDetailLevel.FULL,
	params: generator_params = SpaceGlobals.get_chunk_generator_params()
	) -> SpaceChunk:

	# Ensure chunk stays same across platforms with same seed
	var chunk_rng := RandomNumberGenerator.new()
	var chunk_hash = hash(Vector3i(coords.x, coords.y, _seed))
	chunk_rng.seed = chunk_hash
	
	var chunk := SpaceChunk.new(coords)

	# Decide if chunk belongs to a galaxy
	var gal := _generate_galaxy(coords, params.chunk_belongs_to_galaxy_odds)

	if gal:
		chunk.galaxy = gal

	# Decide if has system
	var system_odds: float = params.has_system_odds_no_galaxy if !gal else params.has_system_odds_in_galaxy

	var has_system = chunk_rng.randf() <= system_odds
	
	# Generate empty system
	if has_system:
		var system := System.new(_generate_random_name(chunk_rng))
		chunk.system = system

	# Return with low detail
	if detail_level == ChunkDetailLevel.LOW:
		return chunk

	# Decide if chunk has bodies
	var has_bodies := chunk_rng.randf() <= (100.0 if has_system else params.has_bodies_odds_without_system)

	if !has_bodies:
		return chunk

	# Generate orbital structure (strictly data, which bodies orbit which etc.)
	var bodies := generate_bodies(
		chunk_hash,
		params.bodies_per_system_min if has_system else params.bodies_without_system_min,
		params.bodies_per_system_max if has_system else params.bodies_without_system_max,
		params
		)

	if bodies == null:
		return chunk

	# Decide orbital center position (Position in chunk where bodies orbit around)
	var _orbital_center_position := get_random_point_in_inner_square(
		params.chunk_size_pixels,
		chunk_rng
	)

	# Assign primary object for system
	if has_system:
		chunk.system.primary_object = bodies
		chunk.system.primary_object_position = _orbital_center_position

	# Assign orbital center
	chunk.orbital_center_position = _orbital_center_position

	# Return with medium detail
	if detail_level == ChunkDetailLevel.MEDIUM:
		return chunk

	# Decide sizes of orbits
	generate_orbit_radiuses(
		bodies,
		 _orbital_center_position, 
		 chunk_rng,
		 params
		 )

	# Decide sizes of the bodies
	generate_body_sizes(
		bodies,
		_orbital_center_position,
		chunk_rng,
		params
	)

	# Assign spin speeds and velocities for bodies
	assign_spins_and_velocities(
		bodies,
		chunk_rng,
		params
	)

	print('Generated chunk %s with following orbital structure: ' % [coords])
	print_orbital_structure(bodies)

	if coords == Vector2i(1005, 1000):
		print("asd")

	# Assign bodies to chunk 
	chunk.bodies_root = bodies

	return chunk


static func assign_spins_and_velocities(
	root: OrbitalBody,
	rng: RandomNumberGenerator,
	params: generator_params = SpaceGlobals.get_chunk_generator_params()
	):
	# Use a randomized root velocity as the baseline for every orbiting body.
	var base_velocity := rng.randf_range(
		params.root_min_orbital_velocity,
		params.root_max_orbital_velocity
	)
	
	root.orbital_velocity = base_velocity
	root.spin_speed = rng.randf_range(
		params.body_min_spin_speed,
		params.body_max_spin_speed
	)

	var minimum_distance := maxf(params.minimum_orbit_radius, 0.001)
	var orbit_levels := root.get_orbit_levels_num()

	# Scale orbital and spin rates down as bodies get farther from the center.
	for level in range(orbit_levels):
		for body: OrbitalBody in root.get_bodies_on_orbit_level(level):
			var distance_scale := minimum_distance / maxf(
				body.get_accumulated_orbit_radius(),
				minimum_distance
			)

			body.orbital_velocity = base_velocity * params.orbital_velocity_scale * distance_scale
			
			body.spin_speed = rng.randf_range(
				params.body_min_spin_speed,
				params.body_max_spin_speed
			) * distance_scale


static func generate_body_sizes(
	root: OrbitalBody,
	orbital_center_position: Vector2,
	rng: RandomNumberGenerator,
	params: generator_params = SpaceGlobals.get_chunk_generator_params()
	):

	# Calculate distance to closest chunk edge
	var _center_edge_distance := _get_distance_to_closest_chunk_edge(
		orbital_center_position,
		params.chunk_size_pixels
	)

	# Assign size to root body before sizing its descendants.
	if root is PhysicalBody:
		_generate_body_size(
			root as PhysicalBody,
			rng,
			_center_edge_distance,
			params
		)

	# Assign sizes to child bodies from the root outward, ascending towards the deepest level.
	var orbit_levels := root.get_orbit_levels_num()

	for level in range(orbit_levels):
		var bodies_on_level := root.get_bodies_on_orbit_level(level)

		for body: OrbitalBody in bodies_on_level:
			if body is not PhysicalBody:
				continue

			_generate_body_size(
				body as PhysicalBody,
				rng,
				_center_edge_distance,
				params
			)


## NOTE: may remove bodies in the orbital hierarchy if they dont fit inside the chunk bounds
static func generate_orbit_radiuses(
	root: OrbitalBody,
	orbital_center_position: Vector2,
	rng: RandomNumberGenerator,
	params: generator_params = SpaceGlobals.get_chunk_generator_params()) -> void:
		
	# The root has a radius of 0.0 because it is the center and doesnt have a parent to orbit around
	root.orbit_radius = 0.0

	# Calulate distance to closest chunk edge
	var _center_edge_distance := _get_distance_to_closest_chunk_edge(
		orbital_center_position,
		params.chunk_size_pixels
	)

	var orbit_levels := root.get_orbit_levels_num()

	# Root body has no children to generate orbits for
	if root.orbiting_children.is_empty():
		return

	# Assign radiuses to bodies, starting from direct children of the root body.
	var body_children_orbit_tracks: Dictionary[OrbitalBody, Array]
	for orbit_level in range(orbit_levels):
		
		var bodies_on_level := root.get_bodies_on_orbit_level(orbit_level) 

		for body in bodies_on_level:

			# Remove the body and its children if it doesnt fit inside the chunk
			var radius_extent := body.get_accumulated_orbit_radius() + params.minimum_orbit_radius
			if radius_extent >= _center_edge_distance:
				body.orbit_parent.orbiting_children.erase(body)
				continue

			# If there are valid tracks already created, choose one
			if body.orbit_parent and body_children_orbit_tracks.has(body.orbit_parent):
				var track_candidates = body_children_orbit_tracks[body.orbit_parent]
				var rnd_idx := rng.randi_range(0, track_candidates.size() - 1)
				body.orbit_radius = track_candidates[rnd_idx]
				continue

			# Generate maximum of 3 orbit track candidates and choose one for the body		
			var parents_sibling_orbit_tracks: Array[float] = []
			if body_children_orbit_tracks.has(body.orbit_parent.orbit_parent):
				parents_sibling_orbit_tracks = body_children_orbit_tracks[body.orbit_parent.orbit_parent]

			var max_orbit_radius := _body_limit_orbit_radius( # Limit orbit radius by several criteria
				body,
				_center_edge_distance,
				params,
				parents_sibling_orbit_tracks
			)

			# Randomize orbit radius
			var deviation := absf(max_orbit_radius - params.minimum_orbit_radius) / 5.15
			var randomized_max := clampf(
				rng.randfn(
					(params.minimum_orbit_radius + max_orbit_radius) / 2.0,
					deviation
				),
				params.minimum_orbit_radius,
				max_orbit_radius
			)

			var generated_orbit_tracks := _generate_orbit_tracks_v2(randomized_max)

			# Filter out too small orbit tracks
			generated_orbit_tracks = generated_orbit_tracks.filter(
				func(track): return track >= params.minimum_orbit_radius
			)

			# Filter out tracks too close to each other.
			var tracks_to_erase: Array[float] = []
			var erased_idx: Array[int] = []
			for track_idx in range(generated_orbit_tracks.size()):
				var track = generated_orbit_tracks[track_idx]

				for other_idx in range(generated_orbit_tracks.size()):
					if other_idx == track_idx:
						continue

					if erased_idx.has(other_idx):
						continue

					var other_track = generated_orbit_tracks[other_idx]
					if absf(track - other_track) < params.minimum_orbit_radius:
						tracks_to_erase.append(track)
						erased_idx.append(track_idx)
						break

			generated_orbit_tracks = generated_orbit_tracks.filter(
				func(track): return !tracks_to_erase.has(track)
			)

			# No valid orbit tracks found, erase the body from hierarchy
			if generated_orbit_tracks.is_empty():
				body.orbit_parent.orbiting_children.erase(body)
				continue

			body.orbit_radius = generated_orbit_tracks[rng.randi_range(0, generated_orbit_tracks.size() - 1)]

			# Update track candidates
			body_children_orbit_tracks[body.orbit_parent] = generated_orbit_tracks

static func _generate_body_size(
	body: PhysicalBody, 
	rng: RandomNumberGenerator, 
	_center_edge_distance: float,
	params: SpaceChunkGenerator.generator_params = generator_params.new()
	):

	var radius_min := params.physical_body_minimum_size_radius

	var radius_max: float
	
	var radius_limiters: Array[float]

	# Limit body radius by various factors

	# Limit so body is always smaller than its parent
	if body.orbit_parent:
		if body.orbit_parent is PhysicalBody:
			var _parent := body.orbit_parent as PhysicalBody
			var parent_radius := _parent.size_radius

			var _max_radius := parent_radius * 0.95

			if params.physical_body_minimum_size_radius > _max_radius:
				_parent.remove_child(body)
			else:
				radius_limiters.append(_max_radius)

	# Limit by distance to chunk edge
	var distance_to_chunk_edge := _center_edge_distance - body.get_accumulated_orbit_radius() - params.physical_body_minimum_size_radius
	
	if distance_to_chunk_edge < params.physical_body_minimum_size_radius:
		body.orbit_parent.remove_child(body)
		return

	radius_limiters.append(distance_to_chunk_edge)

	# Limit by distance to siblings on other tracks
	if !body.get_siblings().is_empty():
		var orbit_distance_to_nearest_sibling := body.get_distance_to_nearest_sibling_orbit_track()

		if !is_inf(orbit_distance_to_nearest_sibling):
			var _max_radius := (orbit_distance_to_nearest_sibling / 2.0) * 0.9

			if params.physical_body_minimum_size_radius > _max_radius:
				body.orbit_parent.remove_child(body)
			else:
				radius_limiters.append(_max_radius)

	# Limit by distance to parents sibling orbit tracks
	if body.orbit_parent:
		var parent_sibs := body.orbit_parent.get_siblings()

		if !parent_sibs.is_empty():
			# Get distance to parents closest sibling
			var p_cs_distance := body.orbit_parent.get_distance_to_nearest_sibling_orbit_track()
			
			if !is_inf(p_cs_distance):
				var is_too_close_to_parent_sibling_track := (body.orbit_radius + params.physical_body_minimum_size_radius) >= (p_cs_distance / 2.0) * 0.8
				
				if is_too_close_to_parent_sibling_track:
					body.orbit_parent.remove_child(body) # Not enough space between orbit tracks to give the body a size
				else:
					radius_limiters.append(
						0.8 * ((p_cs_distance / 2.0) - body.orbit_radius) 
					)

	# Limit by distance to parent the body orbits around 
	if body.orbit_parent:
		var _max_radius_within_orbit = (body.orbit_radius / 2.0) * 0.9

		# Body orbits too close to parent to have a size. Erase it
		if _max_radius_within_orbit <= params.physical_body_minimum_size_radius:
			body.orbit_parent.remove_child(body)
		else:
			radius_limiters.append(
				_max_radius_within_orbit
			)
	
	# Limit by distance to nearest child body
	if !body.orbiting_children.is_empty():
		var children := body.orbiting_children

		# Get distance to nearest child
		var nearest_distance: float = INF
		for c in children:
			if c.orbit_radius < nearest_distance:
				nearest_distance = c.orbit_radius

		radius_limiters.append(
			(nearest_distance / 2.0) * 0.9
		)

	# Randomize size between bounds
	radius_max = radius_limiters.min()
	body = body as PhysicalBody
	body.size_radius = rng.randf_range(radius_min, radius_max)

	return body


static func _generate_orbit_tracks_v2(max_radius: float, tracks_num: int = 3) -> Array[float]:
	var tracks: Array[float] = [max_radius]

	var scale_factor = 0.7

	for n in range(1, tracks_num -1):
		var radius_base = tracks[-1]

		tracks.append(
			radius_base * (scale_factor)
		)

	return tracks


## Limits the orbit radius of the given body by several criteria to ensure valid, non-colliding orbit tracks
static func _body_limit_orbit_radius(
	body: OrbitalBody,
	_center_edge_distance: float,
	params: SpaceChunkGenerator.generator_params,
	parents_sibling_orbit_tracks: Array[float] = []
	) -> float:

	var radius_limiters: Array[float] = []
	
	# Limit radius inside chunk bounds
	var parent_to_chunk_edge_distance := _center_edge_distance - body.orbit_parent.get_accumulated_orbit_radius() - params.minimum_orbit_radius
	radius_limiters.append((2.0 / 3.0) * parent_to_chunk_edge_distance)

	# If parent has 3 or more siblings, ensure the radius doesnt extend over to its siblings area
	if (body.orbit_parent.get_siblings().size() + 1) >= 3:
		radius_limiters.append((2.0 / 3.0) * body.orbit_parent.get_sibling_divider_distance())

	# Limit radius to 2/5 of parents orbit radius
	if (body.orbit_parent.has_orbit_radius()):
		radius_limiters.append((2.0 / 5.0) * body.orbit_parent.orbit_radius)

	# Limit radius to 2/5 of distance to parents nearest sibling orbit track
	if parents_sibling_orbit_tracks and !parents_sibling_orbit_tracks.is_empty():
		var parent_orbit_track := body.orbit_parent.orbit_radius
		var tracks_excluding_parents := parents_sibling_orbit_tracks.duplicate()
		tracks_excluding_parents.erase(parent_orbit_track)

		var dist_to_nearest_track := INF
		for track_radius in tracks_excluding_parents:
			if absf(parent_orbit_track - track_radius) < dist_to_nearest_track:
				dist_to_nearest_track = absf(parent_orbit_track - track_radius)
		
		radius_limiters.append((2.0 / 5.0) * dist_to_nearest_track)
		
	return radius_limiters.min()


## Generates an orbital structure (orbital bodies orbiting each other). Returns the root body other bodies orbit around. Does not generate orbit radiuses or body sizes.
static func generate_bodies(
		bodies_seed: int,
		bodies_min: int,
		bodies_max: int,
		params: generator_params = SpaceGlobals.get_chunk_generator_params()
	) -> OrbitalBody:

	# Ensure bodies stay consistent
	var rng := RandomNumberGenerator.new()
	rng.seed = bodies_seed

	# Decide number of bodies
	var bodies_to_generate := rng.randi_range(bodies_min, bodies_max)

	# No bodies
	if bodies_to_generate <= 0:
		return null

	# Decide if bodies orbit each other around an empty center, or if the center is a physical body 
	var empty_center := rng.randf() <= params.orbit_around_empty_center_odds

	var root: OrbitalBody

	var bodies_left := bodies_to_generate

	var generated_bodies: Array[OrbitalBody] = []

	# Create root
	if empty_center:
		root = OrbitalBody.new(
			_generate_random_name(rng)
		)
	else:
		root = PhysicalBody.new(
			_generate_random_name(rng)
		)
		bodies_left -=1
	generated_bodies.append(root)

	# Generate rest of the bodies
	for body_idx: int in range(bodies_left):
		# Create body
		## TODO - randomize body type here in future to introduce new types (stars, planets, gas giants etc.)
		var body := PhysicalBody.new(
			_generate_random_name(rng)
		)

		# Allow new bodies to be created only on first 2 orbit levels (children of root, and children of roots children)
		var parent_candidates := [root]

		if !root.orbiting_children.is_empty():
			parent_candidates.append_array(root.orbiting_children)

		# Make secondary bodies less likely to orbit around center
		var orbit_around_center := rng.randf() <= params.secondary_body_orbit_around_center_odds

		if !orbit_around_center and parent_candidates.size() > 1:
			parent_candidates.remove_at(0)

		# Decide which object the body orbits around
		var parent = parent_candidates[rng.randi_range(0, parent_candidates.size() - 1)]

		parent.add_child(body)

		generated_bodies.append(body)

	return root


static func print_orbital_structure(root: OrbitalBody) -> void:
	if root == null:
		print("\nOrbital structure: no bodies generated")
		return

	print("\nPrinting orbital structure:")
	print("Orbital structure root: %s" % [root.name])
	_print_orbital_children(root, 1)


static func _print_orbital_children(parent: OrbitalBody, depth: int) -> void:
	for body: OrbitalBody in parent.orbiting_children:
		var indentation := "  ".repeat(depth)
		print("%sSecondary body: %s orbits %s" % [indentation, body.name, parent.name])
		_print_orbital_children(body, depth + 1)


## Prints each body's orbit radius, parent, and total distance from the orbital center.
static func _print_orbit_radius_report(body: OrbitalBody, depth: int = 0) -> void:
	if depth == 0:
		print("\nGenerated orbit radii:")

	if body == null:
		print("No orbital bodies generated")
		return

	var parent_name := "orbital center"
	if body.orbit_parent != null:
		parent_name = body.orbit_parent.name

	var indentation := "  ".repeat(depth)
	print(
		"%s%s: orbit radius %.2f px around %s; accumulated radius %.2f px"
		% [indentation, body.name, body.orbit_radius, parent_name, body.get_accumulated_orbit_radius()]
	)

	for child: OrbitalBody in body.orbiting_children:
		_print_orbit_radius_report(child, depth + 1)


## Prints each physical body's size radius and diameter alongside its orbital distance.
static func _print_body_size_report(body: OrbitalBody, depth: int = 0) -> void:
	if depth == 0:
		print("\nGenerated body sizes:")

	if body == null:
		print("No orbital bodies generated")
		return

	var indentation := "  ".repeat(depth)
	if body is PhysicalBody:
		var physical_body := body as PhysicalBody
		print(
			"%s%s: size radius %.2f px; diameter %.2f px; orbit radius %.2f px; accumulated orbit radius %.2f px"
			% [
				indentation,
				body.name,
				physical_body.size_radius,
				physical_body.size_radius * 2.0,
				body.orbit_radius,
				body.get_accumulated_orbit_radius()
			]
		)
	else:
		print("%s%s: non-physical orbital center" % [indentation, body.name])

	for child: OrbitalBody in body.orbiting_children:
		_print_body_size_report(child, depth + 1)


## Returns the galaxy the given chunk belongs to. Null if the chunk is in empty space (no galaxy).
static func _generate_galaxy(chunk_coords: Vector2i, galaxy_odds: float) -> Galaxy:
	# Decide if chunk has galaxy 
	var gal_coords := SpaceUtils.get_galaxy_space_coords(chunk_coords)
	var gal_seed := hash(Vector4i(gal_coords.x, gal_coords.y, _seed, 1))
	var rng := RandomNumberGenerator.new()
	rng.seed = gal_seed
	
	var has_galaxy := rng.randf() <= galaxy_odds

	if !has_galaxy:
		return null

	var gal := Galaxy.new(_generate_random_name(rng))

	return gal


static func _generate_objects(
	rng: RandomNumberGenerator, 
	detail_level: ChunkDetailLevel, 
	params: generator_params = generator_params.new()
	) -> Dictionary[SpaceObject, Vector2]:

	var objects: Dictionary[SpaceObject, Vector2]

	## TODO - Anything past this line should be reworked once new stellar objects other than planets are introduced, and in case if chunk generation requires rework
	# Generate planets by dividing the chunk into a grid and picking a cell for each object
	# Init grid variables
	var num_planets := rng.randi_range(params.bodies_per_system_min, params.bodies_per_system_max)
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
		var candidate_position := _get_grid_cell_center(cell, chunk_size, grid_size)

		# Limit the radius of the planet so it doesnt extend over the chunk boundaries or occupied planet grid cells
		var max_radius := _get_max_radius_for_position(candidate_position, chunk_size, occupied_cells, cell_size, grid_size)
		var max_allowed_radius := minf(params.planet_radius_max, max_radius)
		if max_allowed_radius < params.planet_radius_min:
			continue

		var planet_radius := rng.randf_range(params.planet_radius_min, max_allowed_radius)
		var planet_name := _generate_random_name(rng)
		var planet: Planet = Planet.new(planet_name, planet_radius)

		objects[planet as SpaceObject] = candidate_position
		
		# Mark the grid cell occupied so it wont be picked for other planets
		occupied_cells[cell] = true
		_consume_cells_for_radius(occupied_cells, candidate_position, planet_radius, chunk_size, grid_size, cell_size)

	return objects


static func get_random_point_in_inner_square(square_dimensions: Vector2, rng: RandomNumberGenerator, inner_square_scale_ratio: float = 0.7) -> Vector2:
	var scale_ratio := clampf(inner_square_scale_ratio, 0.0, 1.0)
	var inner_dimensions := square_dimensions * scale_ratio
	var inner_min := (square_dimensions - inner_dimensions) * 0.5

	return Vector2(
		rng.randf_range(inner_min.x, inner_min.x + inner_dimensions.x),
		rng.randf_range(inner_min.y, inner_min.y + inner_dimensions.y)
	)


static func _generate_random_name(_rng: RandomNumberGenerator = RandomNumberGenerator.new()) -> String:
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


## Divides chunk into a grid and returns a centered position inside a randomly picked grid cell. Useful for randomizing positions inside chunks while preventing objects from being too close to chunk edges.
static func _pick_random_grid_cell_center(
	rng: RandomNumberGenerator,
	chunk_size: Vector2,
	grid_size: Vector2i
	) -> Vector2:
	var cell := Vector2i(
		rng.randi_range(0, grid_size.x - 1),
		rng.randi_range(0, grid_size.y - 1)
	)
	return _get_grid_cell_center(cell, chunk_size, grid_size)


static func _get_grid_cell_center(cell: Vector2i, chunk_size: Vector2, grid_size: Vector2i) -> Vector2:
	var cell_size := Vector2(
		chunk_size.x / float(grid_size.x),
		chunk_size.y / float(grid_size.y)
	)
	return (Vector2(cell) + Vector2(0.5, 0.5)) * cell_size


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
	var max_radius := _get_distance_to_closest_chunk_edge(position, chunk_size)

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


static func _get_distance_to_closest_chunk_edge(position: Vector2, chunk_size: Vector2) -> float:
	return minf(
		minf(absf(position.x), absf(chunk_size.x - position.x)),
		minf(absf(position.y), absf(chunk_size.y - position.y))
	)


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
