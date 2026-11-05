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
	
	var chunk_size_pixels: Vector2 = Vector2(5000.0, 5000.0)

	var orbit_around_empty_center_odds: float = 0.1

	var secondary_body_max_children: int = 3

	## Odds for a body to orbit around a secondary body. Higher values introduce more complex orbits.
	var body_orbit_around_secondary_body_odds: float = 0.4

	var body_copy_sibling_orbit_odds: float = 0.3
	
	var orbital_center_grid_size: Vector2i = Vector2i(3, 3)

	var minimum_orbit_radius: float = 30.0

	var physical_body_minimum_size_radius: float = 10.0

	# Orbital spin and velocity 
	var body_min_spin_speed: float = 1.0
	var body_max_spin_speed: float = 4.0

	## Pixels per second
	var root_min_orbital_velocity: float = 5.0
	var root_max_orbital_velocity: float = 10.0

	var orbital_velocity_scale: float = 100.0


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

	# Decide orbital center position (Position in chunk where bodies orbit around)
	var _orbital_center_position := get_random_point_in_inner_square(
		params.chunk_size_pixels,
		chunk_rng,
		0.5
	)

	# Assign primary object for system
	if has_system:
		chunk.system.primary_object = bodies[0]
		chunk.system.primary_object_position = _orbital_center_position

	# Assign orbital center
	chunk.orbital_center_position = _orbital_center_position

	# Return with medium detail
	if detail_level == ChunkDetailLevel.MEDIUM:
		return chunk

	# Print bodies
	if !bodies.is_empty():
		print('Bodies pre-orbit assignment: ')
		for n in range(bodies.size()):
			var _body = bodies[n]
			print('\n%s' % [_body.name])

	# Decide sizes of orbits
	if coords == Vector2i(1001, 1001):
		print("asd")
	var bodies_root := _generate_orbits(
		bodies,
		 _orbital_center_position, 
		 chunk_rng,
		 params
	 )
		
	# Decide sizes of the bodies
	generate_body_sizes(
		bodies_root,
		_orbital_center_position,
		chunk_rng,
		params
	)
	
	# Assign spin speeds and velocities for bodies
	assign_spins_and_velocities(
		bodies_root,
		chunk_rng,
		params
	)
	
	print('Generated chunk %s with following orbital structure: ' % [coords])
	print_orbital_structure(bodies_root)

	if coords == Vector2i(1005, 1000):
		print("asd")

	# Assign bodies to chunk 
	chunk.bodies_root = bodies_root

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
static func _generate_orbits(
	_bodies: Array[OrbitalBody],
	orbital_center_position: Vector2,
	rng: RandomNumberGenerator,
	params: generator_params = SpaceGlobals.get_chunk_generator_params()) -> OrbitalBody:

	# Calulate distance to closest chunk edge
	var _center_edge_distance := _get_distance_to_closest_chunk_edge(
		orbital_center_position,
		params.chunk_size_pixels
	)

	# Choose root
	var root := _bodies[0]

	# No bodies to generate orbits for
	if _bodies.size() <= 1:
		return root

	# Pick parents and generate orbit tracks for each body
	var orbit_tracks: Dictionary[OrbitalBody, Array]
	var to_erase: Array[OrbitalBody] = []

	for n in range(0, _bodies.size()):

		var body := _bodies[n]

		if n != 0: # Skip parent picking for root

			# Pick parent for the body
			if !_assign_orbit_parent(body, orbit_tracks, rng, params):
				to_erase.append(body)
				break # No space for more child bodies, cancel

			# Pick orbit track
			var track_candidates := orbit_tracks[body.orbit_parent]
			var track_idx := rng.randi_range(0, track_candidates.size() - 1)
			body.orbit_radius = track_candidates[track_idx]
	
		# Generate orbit tracks for children
		var max_orbit_radius := _body_limit_orbit_radius( # Limit orbit radius by several criteria  to prevent colliding orbits
			body,
			_center_edge_distance,
		)

		var generated_orbit_tracks := _generate_orbit_tracks(params.minimum_orbit_radius, max_orbit_radius)

		# Remove some inner tracks to ensure body has space to grow in size
		var is_root := !body.orbit_parent
		var track_count := generated_orbit_tracks.size()

		if is_root:

			# Only two tracks, remove the other one
			if track_count == 2:
				generated_orbit_tracks = generated_orbit_tracks.slice(1, generated_orbit_tracks.size())
			
			# Multiple tracks, remove 1/3 of them
			elif track_count >= 3:
				var remove_count := clampi(
					floori(
						(1.0 / 3.0) * track_count
					),
					0, 
					track_count
				)
				generated_orbit_tracks = generated_orbit_tracks.slice(remove_count, generated_orbit_tracks.size())
		# Body is not root, remove a random amount, capped to 1/2 of total tracks
		else: 
			if track_count > 1:
				var upper_bound := maxf(0.0, float(track_count) * 0.5)
				var deviation := upper_bound / 2.576
				if deviation > 0.0:
					var remove_count := int(
						round(
							clampf(
								absf(rng.randfn(0.0, deviation)), 
								0.0, 
								upper_bound
								)
							)
						)
					remove_count = mini(remove_count, track_count)
					if remove_count > 0:
						generated_orbit_tracks = generated_orbit_tracks.slice(remove_count, generated_orbit_tracks.size())

		orbit_tracks[body] = generated_orbit_tracks
	
	for _body in to_erase:
		_body.erase()

	return root


static func _assign_orbit_parent(
	body: OrbitalBody,
	orbit_tracks: Dictionary[OrbitalBody, Array],
	rng: RandomNumberGenerator,
	params: generator_params
	) -> bool:

	# Pick a parent for the body from candidates with usable orbit tracks.
	var parent_candidates := orbit_tracks.keys().duplicate()

	# Filter out parent candidates without valid tracks.
	parent_candidates = parent_candidates.filter(
		func(candidate: OrbitalBody): return !orbit_tracks[candidate].is_empty()
	)

	# Filter out secondary bodies that already have the maximum number of children.
	parent_candidates = parent_candidates.filter(
		func(candidate: OrbitalBody):
			if !candidate.is_secondary() or candidate.orbiting_children.is_empty():
				return true

			return candidate.orbiting_children.size() < params.secondary_body_max_children
	)

	if parent_candidates.is_empty():
		return false

	var secondary_bodies := parent_candidates.filter(
		func(candidate: OrbitalBody): return candidate.is_secondary()
	)

	var pick_secondary := (
		!secondary_bodies.is_empty()
		and rng.randf() <= params.body_orbit_around_secondary_body_odds
	)

	if pick_secondary:
		var parent_idx := rng.randi_range(0, secondary_bodies.size() - 1)
		secondary_bodies[parent_idx].add_child(body)
	else:
		parent_candidates = parent_candidates.filter(
			func(candidate: OrbitalBody): return !candidate.is_secondary()
		)
		var parent_idx := rng.randi_range(0, parent_candidates.size() - 1)
		parent_candidates[parent_idx].add_child(body)

	return true


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

			var _max_radius := parent_radius * 0.70

			if params.physical_body_minimum_size_radius > _max_radius:
				body.erase()
			else:
				radius_limiters.append(_max_radius)

	# Limit by distance to chunk edge
	var distance_to_chunk_edge := _center_edge_distance - body.get_accumulated_orbit_radius() - params.physical_body_minimum_size_radius
	
	if distance_to_chunk_edge < params.physical_body_minimum_size_radius:
		body.erase()
		return

	radius_limiters.append(distance_to_chunk_edge)

	# Limit by distance to siblings on other tracks
	if !body.get_siblings().is_empty():
		var orbit_distance_to_nearest_sibling := body.get_distance_to_nearest_sibling_orbit_track()

		if !is_inf(orbit_distance_to_nearest_sibling):
			var _max_radius := (orbit_distance_to_nearest_sibling / 2.0) * 0.9

			if params.physical_body_minimum_size_radius > _max_radius:
				body.erase()
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
					body.erase() # Not enough space between orbit tracks to give the body a size
				else:
					radius_limiters.append(
						0.8 * ((p_cs_distance / 2.0) - body.orbit_radius) 
					)

	# Limit by distance to parent the body orbits around 
	if body.orbit_parent:
		var _max_radius_within_orbit = (body.orbit_radius / 2.0) * 0.9

		# Body orbits too close to parent to have a size. Erase it
		if _max_radius_within_orbit <= params.physical_body_minimum_size_radius:
			body.erase()
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


static func _generate_orbit_tracks(min_radius: float, max_radius: float) -> Array[float]:
	var tracks: Array[float] = []
	var accumulus := 0.0
	var step := min_radius * 3.0

	if min_radius >= max_radius:
		return tracks

	while true:
		var rad := accumulus + step
		
		if rad > max_radius:
			break
		
		accumulus = rad
		tracks.append(rad)

	return tracks


## Limits the orbit radius of bodies that will orbit this body to prevent colliding orbits
static func _body_limit_orbit_radius(
	body: OrbitalBody,
	_center_edge_distance: float,
	) -> float:

	var radius_limiters: Array[float] = []
	
	# Limit radius inside chunk bounds
	var distance_to_chunk_edge := _center_edge_distance - body.get_accumulated_orbit_radius() 
	radius_limiters.append((0.8) * distance_to_chunk_edge)

	# If parent has 3 or more siblings, ensure the radius doesnt extend over to its siblings area
	if (body.get_siblings().size() + 1) >= 3:
		radius_limiters.append(0.8 * body.orbit_parent.get_sibling_divider_distance())

	# Limit radius to 0.4 of parents orbit radius
	if (body.orbit_parent and body.orbit_parent.has_orbit_radius()):
		radius_limiters.append(0.4 * body.orbit_parent.orbit_radius)

	# Limit radius to 2/5 of distance to parents nearest sibling orbit track
	var sibling_orbit_tracks := body.get_other_sibling_orbits()

	if sibling_orbit_tracks and !sibling_orbit_tracks.is_empty():
		var orbit_track := body.orbit_radius

		var dist_to_nearest_track := INF
		for track_radius in sibling_orbit_tracks:
			if absf(orbit_track - track_radius) < dist_to_nearest_track:
				dist_to_nearest_track = absf(orbit_track - track_radius)
		
		radius_limiters.append((2.0 / 5.0) * dist_to_nearest_track)
		
	return radius_limiters.min()


## Generates an orbital structure (orbital bodies orbiting each other). Returns the root body other bodies orbit around. Does not generate orbit radiuses or body sizes.
static func generate_bodies(
		bodies_seed: int,
		bodies_min: int,
		bodies_max: int,
		params: generator_params = SpaceGlobals.get_chunk_generator_params()
	) -> Array[OrbitalBody]:

	var bodies: Array[OrbitalBody] = []

	# Ensure bodies stay consistent with seed
	var rng := RandomNumberGenerator.new()
	rng.seed = bodies_seed

	# Decide number of bodies
	var body_count_mean := (bodies_min + bodies_max) / 2.0
	var body_count_std_dev := (bodies_max - bodies_min) / (2.0 * 2.576)
	var num_bodies_to_generate := clampi(
		roundi(rng.randfn(body_count_mean, body_count_std_dev)),
		bodies_min,
		bodies_max
	)

	# No bodies
	if num_bodies_to_generate <= 0:
		return bodies

	# Decide if bodies orbit each other around an empty center, or if the center is a physical body 
	var empty_center := rng.randf() <= params.orbit_around_empty_center_odds

	var root: OrbitalBody

	# Create root
	if empty_center:
		root = OrbitalBody.new(
			_generate_random_name(rng)
		)
	else:
		root = PhysicalBody.new(
			_generate_random_name(rng)
		)
	bodies.append(root)

	# Generate rest of the bodies
	for body_idx: int in range(1, num_bodies_to_generate):
		# Create body
		## TODO - randomize body type here in future to introduce new types (stars, planets, gas giants etc.)
		var body := PhysicalBody.new(
			_generate_random_name(rng)
		)

		bodies.append(body)

	return bodies


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
