extends Node

@export var tmap: TileMapLayer

@export_category("Generator parameters")
@export var iterations = 3
@export var w : int = 30
@export var h : int = 30
@export var gap = 1
@export var randomize_generator_seed = true
@export var generator_seed = 12345
@export var terrain_noise_freq = 0.0841

# Base terrain height
@export var base_terrain_height_noise_freq = 0.0841
@export var base_terrain_tiles : Array[Vector3i]

# river canals
@export_group("River Canals")
@export var max_turns = 5
@export var min_walk_length = 3
@export var river_max_branches = 1

@export var remove_lakes_near_rivers_radius : int = 3
@export var ground_tile : Vector2i = Vector2i(1,7)
@export var river_tile = Vector2i(17,39)

# lakes
@export_group("Lakes")
@export var lake_water_level_treshold = 0.7 
@export var lake_tile = Vector3i(17, 39, 4)

# mountains
@export_group("Mountains")
@export var mountains_level_noise_tresholds : Array[float]
@export var mountain_level_tiles : Array[Vector3i]

# forest edge
@export_group("Forest Edges")
@export var forest_edge_thickness = 1
@export var forest_edge_tile : Vector3i

# forest middle 
@export_group("Middle Forests")
@export var forest_noise_freq = 0.0841
@export var forest_noise_treshold = 0.7

# Roads
@export var road_cell_size : Vector2i = Vector2i(4, 4)

# Big roads
@export_group("Big roads")
@export var big_road_max_turns = 5
@export var big_road_min_walk_length = 3
@export var big_road_max_branches = 1
@export var big_road_tile = Vector3i(12, 28, 5)

# Small roads
@export_group("Small roads")
@export var min_small_road_start_cells : int = 1
@export var max_small_road_start_cells : int = 4
@export var small_road_random_walk_length = 50
@export var small_road_random_walk_turn_odds = 60.0
@export var small_road_preview_tile : Vector3i = Vector3i(0,0,0)
@export var highway_connection_passes = 1

@export var pattern_generator_highways : TileMapPatternGenerator
@export var pattern_generator_small_roads : TileMapPatternGenerator


enum tunneler_dir {N, S, E, W}

const R_CONNECTION_N = 1
const R_CONNECTION_S = 2
const R_CONNECTION_E = 4
const R_CONNECTION_W = 8

## Helper array for picking connections at random
const possible_connections : Array[int] = [
	R_CONNECTION_N,
	R_CONNECTION_S,
	R_CONNECTION_E,
	R_CONNECTION_W
]

const opposite_connections : Dictionary[int, int] = {
	R_CONNECTION_N : R_CONNECTION_S,
	R_CONNECTION_S : R_CONNECTION_N,
	R_CONNECTION_E : R_CONNECTION_W,
	R_CONNECTION_W : R_CONNECTION_E
}


func _ready():
	generate.call_deferred()

func generate():
	for i in range(iterations):
		# calc x offset between each generator iteration
		var offset = (w*i) + (gap*i)

		# set seed
		var g_seed = generator_seed
		if randomize_generator_seed:
			g_seed = randi_range(-99999, 99999)
		seed(g_seed)
		print('Generating world with seed %s' % [g_seed])

#region Generate Terrains
		# generate base terrain with height ranging from 1-3 
		# (noise pixel values genrate in range of 0.0 - 1.0)
		var base_terrain_height_levels_count : int = randi_range(1,3)
		var n_gen = FastNoiseLite.new()
		n_gen.seed = g_seed
		n_gen.noise_type = FastNoiseLite.TYPE_PERLIN
		n_gen.frequency  = base_terrain_height_noise_freq
		var base_terrain_noise : Image = n_gen.get_image(
			w,
			h
		)
		
		var base_terrain_heightmap : Array[Array] = OmegaUtils.create_grid(w, h, 0)
		for y in range(h):
			for x in range(w):
				var p_v = base_terrain_noise.get_pixel(x, y).v
				var step_size : float = 1.0 / base_terrain_height_levels_count
				base_terrain_heightmap[y][x] = floori(p_v / step_size)

		# generate noise texture for Lakes and hills
		n_gen.seed = g_seed
		n_gen.noise_type = FastNoiseLite.TYPE_PERLIN
		n_gen.frequency = terrain_noise_freq
		var n_image : Image = n_gen.get_image(
			w,
			h
		)

		# generate lakes
		var lake_map = generate_lakes(n_image, lake_water_level_treshold)

		# generate rivers canals
		var river_canal_cells : Array[Vector2i] = Tunneler2D.branching_random_leap(
			Vector2i(w, h), 
			max_turns, 
			min_walk_length,
			river_max_branches
			)

		# remove lakes and mountains near river canals (get all cells in square area around river cell and check if they are within distance of river)
		var to_unmark_as_lakes : Array[Vector2i] = []
		for r_cell : Vector2i in river_canal_cells:
			var x = r_cell.x - remove_lakes_near_rivers_radius
			var y = r_cell.y - remove_lakes_near_rivers_radius
			for y_off in range(remove_lakes_near_rivers_radius*2):
				for x_off in range(remove_lakes_near_rivers_radius*2):

					# ignore cells outside map bounds
					var cell_coords : Vector2i = Vector2i(x+x_off, y+y_off)
					if (cell_coords.x < 0) or (cell_coords.x >= w) or (cell_coords.y < 0) or (cell_coords.y >= h):
						continue

					# ignore river cells
					if cell_coords == r_cell: # ignore the rivel cell itself
						continue

					# check distance
					var distance = r_cell.distance_to(cell_coords)

					if distance <= remove_lakes_near_rivers_radius:
						
						# unmark as lake 
						to_unmark_as_lakes.append(cell_coords)
	
		# generate mountains 
		var mountains_heightmap : Array[Array] = generate_mountains(n_image, mountains_level_noise_tresholds)
		
		# generate forest edge [[bool]]
		var forest_edge_cells : Array[Array] = generate_forest_edge(Vector2i(w, h), forest_edge_thickness)

		# create noise for forest centre areas
		n_gen.seed = g_seed
		n_gen.frequency = forest_noise_freq
		var f_n_image : Image = n_gen.get_image(
			w,
			h
		)

		# generate forest
		var forest_cells : Array[Vector2i] = generate_forest(f_n_image, forest_noise_treshold)

		# clear area around rivers
		var cells_around_rivers = []
		for cell in river_canal_cells:
			var cells = OmegaUtils.get_coords_within_radius(cell, remove_lakes_near_rivers_radius)
			cells_around_rivers.append_array(cells)

			for c : Vector2i in cells:
				if OmegaUtils.within_bounds_2d(c.x, c.y, lake_map):
					lake_map[c.y][c.x] = false
					mountains_heightmap[c.y][c.x] = 0

		# prevent forest edge over lake, river canal, and mountain cells
		forest_edge_cells = OmegaUtils.array_compare_replace_with_2D(forest_edge_cells, lake_map, true, false)
		forest_edge_cells = OmegaUtils.array_replace_with_2D(forest_edge_cells, river_canal_cells, false)
		forest_edge_cells = OmegaUtils.array_compare_replace_with_2D(forest_edge_cells, mountains_heightmap, 0, false, true)

		# prevent forest over mountains, lakes, rivers etc.
		forest_cells = forest_cells.filter(func(cell : Vector2i): return mountains_heightmap[cell.y][cell.x] == 0)
		forest_cells = forest_cells.filter(func(cell : Vector2i): return lake_map[cell.y][cell.x] == false)
		forest_cells = forest_cells.filter(func(cell : Vector2i): return !river_canal_cells.has(cell))
#endregion

#region Generate Highways
		# Generate big roads
		var road_grid_dimensions : Vector2i = Vector2i(w / road_cell_size.x, h / road_cell_size.y)

		var big_road_cells : Array[Vector2i] = Tunneler2D.branching_random_leap(
			Vector2i(road_grid_dimensions.x, road_grid_dimensions.y), 
			big_road_max_turns, 
			big_road_min_walk_length,
			big_road_max_branches
			)
		
		var big_road_grid : PackedByteArray = []
		big_road_grid.resize(road_grid_dimensions.x * road_grid_dimensions.y)
		big_road_grid.fill(0)

		# Save big roads to road grid
		for road_cell in big_road_cells:
			var connections = 0

			# Connect to neighboring road cells
			if big_road_cells.has(road_cell + Vector2i(0, -1)):
				connections += R_CONNECTION_N
			if big_road_cells.has(road_cell + Vector2i(0, 1)):
				connections += R_CONNECTION_S
			if big_road_cells.has(road_cell + Vector2i(1, 0)):
				connections += R_CONNECTION_E
			if big_road_cells.has(road_cell + Vector2i(-1, 0)):
				connections += R_CONNECTION_W

			# Connect to map edge
			var edge_connections = get_connections_to_map_edges(road_cell, road_grid_dimensions)
			for connection in edge_connections:
				connections = add_connection(connections, connection)
				
			big_road_grid[grid_get_index(Vector2i(road_grid_dimensions), road_cell)] = connections
#endregion

#region Generate Small Roads
		# Generate small roads
		var small_road_cells = generate_small_roads(
			big_road_cells, 
			road_grid_dimensions, 
			small_road_random_walk_length,
			small_road_random_walk_turn_odds
			)
		
		# Erase small road cells overlapping big roads
		small_road_cells = small_road_cells.filter(
			func doesnt_overlap_big_road(cell): return !big_road_cells.has(cell)
			)

		# Create 1D array for small road cells 
		var small_road_grid : PackedByteArray = []
		small_road_grid.resize(road_grid_dimensions.x * road_grid_dimensions.y)
		small_road_grid.fill(0)

		# Randomize directional connections for small roads
		for sr_cell in small_road_cells:
			# Skip if cell already has connections (random walk produces duplicate cells)
			var connections = small_road_grid[grid_get_index(road_grid_dimensions, sr_cell)]
			var cell_index = grid_get_index(road_grid_dimensions, sr_cell)
			if connections != 0:
				continue

			# Ensure at least 1 onnection
			var ensured_connection = possible_connections.pick_random()
			small_road_grid[cell_index] = add_connection(connections, ensured_connection)

			# Add each connection with 50/50 odds
			for c in possible_connections:
				if OmegaUtils.roll_percentage_odds(50.0):
					connections = small_road_grid[cell_index]
					small_road_grid[cell_index] = add_connection(connections, c)
			
		# Convert 1D connections to an array of small road 2D coordinates (removes duplicate coords caused by random walk)
		var small_road_cell_coords: Array[Vector2i] = []
		for n in range(small_road_grid.size()):
			var sr_connections = small_road_grid[n]
			if sr_connections != 0:
				small_road_cell_coords.append(
					index_to_coordinates(n, road_grid_dimensions)
				)
		
		print('Generated %s small road cells' % [small_road_cell_coords.size()])

		# Connect all small road cells to highways
		var passes = 0
		var connect_highways = highway_connection_passes > 0
		if connect_highways:
			while true:
				print('\n Connecting small road cells to highways, pass: %s' % [passes])
				var cellgroups = get_connected_cellgroups(
					small_road_cell_coords,
					small_road_grid,
					road_grid_dimensions
				)

				print('Found %s connected groups of small road cells' % [cellgroups.size()])
				
				# Stop connecting if all cellgroups are connected to highways
				var cellgroups_not_connected_to_highways = 0
				for cg in cellgroups:
					if !is_next_to_highway(cg, big_road_cells, road_grid_dimensions):
						cellgroups_not_connected_to_highways += 1
				if cellgroups_not_connected_to_highways == 0:
					break
				
				print('Found %s cellgroups not connected to highways' % [cellgroups_not_connected_to_highways])

				var new_connections : Array = []

				# Connect each cellgroup to random unconnected neighbour
				for cg : Array[Vector2i] in cellgroups:
					## start_cell, connection direction
					var connectable_neighbours : Array[Array] = []

					# get each neighbor (group cell, direction)
					for c in cg:
						# Get neighboring cells
						var neighbours : Dictionary[Vector2i, int] = get_neighboring_cells_directions(c, road_grid_dimensions)

						# Pick cells with small roads, which are not connected to this group
						for _c in neighbours.keys():
							var add = (small_road_cell_coords.has(_c)) and (!cg.has(_c)) # Check if cell is a small road and doesn't belong to this cellgroup
							if add:
								connectable_neighbours.append([c, neighbours[_c]])

					if connectable_neighbours.is_empty():
						continue

					# TODO : refactor into connect_cells func ? 
					var connection: Array = connectable_neighbours.pick_random()
					var connect_cell: Vector2i = connection[0]
					var dir: int = connection[1]
					var other_cell = get_cell_in_direction(connect_cell, dir)

					new_connections.append(connect_cell)
					new_connections.append(dir)
					new_connections.append(other_cell)
					new_connections.append(opposite_connections[dir])
				
				if new_connections.is_empty():
					print('No more new possible connections found, highway connections complete.' % [])
					break

				# Make connections
				var n = 0
				while n < new_connections.size():
					var cell = new_connections[n]
					var dir = new_connections[n+1]
					var c_idx = grid_get_index(road_grid_dimensions, cell)
					small_road_grid[c_idx] = add_connection(
						small_road_grid[c_idx],
						dir
						)
					n += 2

				print('Made %s new connections' % [new_connections.size()/2])

				cellgroups = get_connected_cellgroups(
					small_road_cell_coords,
					small_road_grid,
					road_grid_dimensions
				)

				print('Found %s cellsgroups after merging groups' % [cellgroups.size()])
					
				passes += 1

			print('Connected all small road cells to highways after %s connection passes' % [passes])
			
		
		
#endregion
		# Generate buildings

#region Render Terrain
		# Render terrain on tilemap
		for y in range(h):
			for x in range(w):
				var c : Vector2i = Vector2i(x, y)
				
				# Ground
				tmap.set_cell(
					Vector2i(x + offset, y),
					4,
					ground_tile
				)

				# Base terrain
				for n in base_terrain_tiles.size():
					if base_terrain_heightmap[y][x] == n:
						tmap.set_cell(
						Vector2i(x+offset, y),
						base_terrain_tiles[n].z,
						Vector2i(base_terrain_tiles[n].x, base_terrain_tiles[n].y)
					)
				
				# Lake
				if lake_map[y][x] == true:
					tmap.set_cell(
						Vector2i(x+offset, y),
						lake_tile.z,
						Vector2i(lake_tile.x, lake_tile.y)
					)
				
				# River 
				if river_canal_cells.has(c):
					tmap.set_cell(
						c + Vector2i(offset, 0),
						4,
						Vector2i(17,39)
					)
				
				# Mountains
				var mount_height : int = mountains_heightmap[y][x]
				
				for n in range(mountain_level_tiles.size()):
					var mountain_tile : Vector3i = mountain_level_tiles[n]

					if (n+1) == mount_height:
						# paint mountain
						tmap.set_cell(
							Vector2i(x + offset, y),
							mountain_tile.z,
							Vector2i(mountain_tile.x, mountain_tile.y)
						)
				
				# Forest edge
				if forest_edge_cells[y][x] == true:
					tmap.set_cell(
							Vector2i(x + offset, y),
							forest_edge_tile.z,
							Vector2i(forest_edge_tile.x, forest_edge_tile.y)
						)

				# Forest 
				if forest_cells.has(c):
					tmap.set_cell(
						Vector2i(c.x + offset, c.y),
						forest_edge_tile.z,
						Vector2i(forest_edge_tile.x, forest_edge_tile.y)
					)
#endregion

#region Render Urban
			# Render highways
			for road_cell_coord in big_road_cells:
				var coordindate_on_tilemap : Vector2i = road_cell_coord * road_cell_size

				# Check directional connections for the cell
				var cell_connections_idx = grid_get_index(road_grid_dimensions, road_cell_coord) # get cell index in 1D road grid array
				var cell_connections = big_road_grid[cell_connections_idx] # get connections from array (N S E W)

				# Retrieve a tile pattern with matching the connections
				var r_pattern : TileMapPattern = pattern_generator_highways.get_pattern_with_connections(cell_connections)

				# Paint on tilemap
				tmap.set_pattern(coordindate_on_tilemap + Vector2i(offset, 0), r_pattern)

			# Preview render small roads
			# for sr_cell in small_road_cells:
			# 	var coordindate_on_tilemap : Vector2i = sr_cell * road_cell_size
			# 	TilemapLayerExtensions.fill_area(
			# 		tmap,
			# 		coordindate_on_tilemap + Vector2i(offset, 0),
			# 		road_cell_size,
			# 		small_road_preview_tile.z,
			# 		Vector2i(small_road_preview_tile.x, small_road_preview_tile.y)
			# 	)

			# Render small roads
			for road_cell_coord in small_road_cells:  
				var coordindate_on_tilemap : Vector2i = road_cell_coord * road_cell_size

				# Check directional connections for the cell
				var cell_connections_idx = grid_get_index(road_grid_dimensions, road_cell_coord) # get cell index in 1D road grid array
				var cell_connections = small_road_grid[cell_connections_idx] # get connections from array (N S E W)

				# Retrieve a tile pattern with matching the connections
				var r_pattern : TileMapPattern = pattern_generator_small_roads.get_pattern_with_connections(cell_connections)

				# Paint on tilemap
				tmap.set_pattern(coordindate_on_tilemap + Vector2i(offset, 0), r_pattern)

#endregion
		print("x offset: %s" % [offset])
		print("\n")


func is_next_to_highway(cellgroup : Array[Vector2i], highway_cells, grid_dimensions) -> bool:
	for cell in cellgroup:
		for c in get_neighboring_cells(cell, grid_dimensions):
			if highway_cells.has(c):
				return true

	return false


func get_connected_cellgroups(cells : Array[Vector2i], grid_connections, grid_dimensions) -> Array[Array]:
	var unchecked_cells = cells.duplicate()
			 
	var cellgroups : Array[Array]

	# Assemble cellgroups
	while true:
		if unchecked_cells.is_empty():
			break

		var start_cell = unchecked_cells[0]
		var group = get_connected_cells(
			start_cell,
			grid_dimensions,
			grid_connections
		)

		for c in group:
			unchecked_cells.erase(c)
		cellgroups.append(group)
	
	return cellgroups


func generate_small_roads(big_road_cells : Array[Vector2i], map_dimensions, random_walk_length, random_walk_turn_odds) -> Array[Vector2i]:
	var cells : Array[Vector2i] = []
	var small_road_start_cell_count : int = randi_range(min_small_road_start_cells, max_small_road_start_cells)
	var possible_cells = big_road_cells.duplicate()
	var sr_start_cells = []

	# Pick road starting cells
	for n in range(small_road_start_cell_count):
		var cell = possible_cells.pick_random()
		possible_cells.erase(cell)
		sr_start_cells.append(cell)

	# Generate roads with random walk
	for sc in sr_start_cells:
		var _sr_cells = Tunneler2D.random_walk(sc, random_walk_length, map_dimensions, random_walk_turn_odds)
		cells.append_array(_sr_cells)

	return cells


func get_connected_cells(cell, map_dimensions, connections_grid) -> Array[Vector2i]:
	var cc : Array[Vector2i] = [cell]

	while true:
		var found = []
		
		for c in cc:
			var cn = get_connected_neighbors(c, connections_grid, map_dimensions)

			cn = cn.filter( # Filter alredy found cells
				func(_c): return (!cc.has(_c)) and (!found.has(_c))
			)
			
			found.append_array(cn)
			
		if found.is_empty():
			break
		
		cc.append_array(found)
			
	return cc


func get_connected_neighbors(cell, connections_grid, map_dimensions) -> Array[Vector2i]:
	var neighbors = get_neighboring_cells(cell, map_dimensions)
	
	var connected = neighbors.filter(
		func(_c): return are_connected(cell, _c, connections_grid, map_dimensions)
	)

	return connected

## Returns cells in NSEW directions. Filters cells outside map bounds if map_dimensions are given
func get_neighboring_cells(cell, map_dimensions : Vector2i = Vector2i(-1, -1)) -> Array[Vector2i]:
	var ncs : Array[Vector2i] = [
				cell + Vector2i(0, -1), # N
				cell + Vector2i(0, 1), # S
				cell + Vector2i(1, 0), # E 
				cell + Vector2i(-1, 0), # W
			]

	# filter out cells outside map bounds
	var filter = (map_dimensions.x > 0) and (map_dimensions.y > 0)
	if filter:
		ncs = ncs.filter(
			func(_cell): return OmegaUtils.is_inside_bounds(_cell, map_dimensions)
		)

	return ncs


func get_neighboring_cells_directions(cell, map_dimensions : Vector2i = Vector2i(-1, -1)) -> Dictionary[Vector2i, int]:
	var ret : Dictionary[Vector2i, int] = {
		cell + Vector2i(0, -1): R_CONNECTION_N,
		cell + Vector2i(0, 1): R_CONNECTION_S,
		cell + Vector2i(1, 0): R_CONNECTION_E,
		cell + Vector2i(-1, 0): R_CONNECTION_W,
	}
		
	# filter out cells outside map bounds
	var filter = (map_dimensions.x > 0) and (map_dimensions.y > 0)
	if filter:
		var to_erase = []
		for n in range(ret.keys().size()):
			if !OmegaUtils.is_inside_bounds(ret.keys()[n], map_dimensions):
				to_erase.append(ret.keys()[n])
		for coord in to_erase:
			ret.erase(coord)

	return ret


## Returns true if cell_a and cell_b are connected in the given connections grid
func are_connected(cell_a : Vector2i, cell_b : Vector2i, connections_grid : PackedByteArray, connections_grid_dimensions : Vector2i) -> bool:
	var a_neighbours = get_neighboring_cells(cell_a)
	var are_neighbours = a_neighbours.has(cell_b)
	
	if !are_neighbours:
		return false

	var b_idx = a_neighbours.find(cell_b)

	var dir_to_b : int
	match b_idx:
		0:
			dir_to_b = R_CONNECTION_N	
		1:
			dir_to_b = R_CONNECTION_S
		2:
			dir_to_b = R_CONNECTION_E
		3:
			dir_to_b = R_CONNECTION_W

	var ais = has_connection(
		connections_grid[grid_get_index(connections_grid_dimensions, cell_a)], 
		dir_to_b
		)
	var bis = has_connection(
		connections_grid[grid_get_index(connections_grid_dimensions, cell_b)], 
		opposite_connections[dir_to_b]
		)

	if ais and bis:
		return true

	return false


func grid_get_index(_grid_size : Vector2i, coords : Vector2i) -> int:
	return _grid_size.x * coords.y + coords.x


## Converts a flat 1D array index to an 2D grid coordinate
func index_to_coordinates(index, grid_dimensions) -> Vector2i:
	var y : int = int(index / grid_dimensions.x)
	var x : int = index - (y * grid_dimensions.x)
	return Vector2i(x, y)


func get_connections_to_map_edges(coord : Vector2i, map_dimensions : Vector2i, ) -> Array[int]:
	var edges : Array[int] = []

	if coord.x == 0:
		edges.append(R_CONNECTION_W)
	if coord.x == map_dimensions.x - 1:
		edges.append(R_CONNECTION_E) 
	if coord.y == 0:
		edges.append(R_CONNECTION_N)
	if  coord.y == map_dimensions.y - 1:
		edges.append(R_CONNECTION_S)
	
	return edges


func get_cell_in_direction(source_cell, direction) -> Vector2i:
	var cell = source_cell
	match direction:
		R_CONNECTION_N:
			cell = source_cell + Vector2i(0, -1)
		R_CONNECTION_S:
			cell = source_cell + Vector2i(0, 1)
		R_CONNECTION_E:
			cell = source_cell + Vector2i(1, 0)
		R_CONNECTION_W:
			cell = source_cell + Vector2i(-1, 0)

	return cell


## Returns connections with the added connection if it does not have it already
func add_connection(connections : int, connection : int) -> int:
	if !has_connection(connections, connection):
		return connections + connection
	return connections


func has_connection(connections : int, direction: int) -> bool:
	return (connections & direction) != 0


func generate_forest(_noise_image : Image, forest_treshold : float) -> Array[Vector2i]:
	var cells : Array[Vector2i] = []
	var size = _noise_image.get_size()

	for y in range(size.y):
		for x in range(size.x):
			var pixel_v = _noise_image.get_pixel(x, y).v
			if pixel_v >= forest_treshold:
				cells.append(Vector2i(x, y))

	return cells


func generate_forest_edge(map_size : Vector2i, thickness : int) -> Array[Array]:
	var cells : Array[Array] = OmegaUtils.create_grid(map_size.x, map_size.y, false)
	
	for y in range(map_size.y):
		for x in range(map_size.x):
			if (x < thickness) or (x > (map_size.x - 1 - thickness)) or (y < thickness) or (y > (map_size.y - 1 - thickness)):
				cells[y][x] = true

	return cells


## returns Array[ Array[ bool ] ]	where false = no lake, true = lake
func generate_lakes(_noise_img : Image, _water_level_treshold : float) -> Array[Array]:
	var lake_map = OmegaUtils.create_grid(_noise_img.get_size().x, _noise_img.get_size().y, false)
	var size = _noise_img.get_size()
	for y in range(size.y):
		for x in range(size.x):
			var pixel_color_v : float = _noise_img.get_pixel(x, y).v
			if pixel_color_v <= _water_level_treshold:
				lake_map[y][x] = true

	return lake_map


func generate_mountains(_noise_image : Image, level_noise_tresholds : Array[float] = []) -> Array[Array]:
	var map_size = _noise_image.get_size()
	var mountain_heightmap : Array[Array] = OmegaUtils.create_grid(map_size.x, map_size.y, 0)

	if level_noise_tresholds.is_empty():
		return []

	# mark mountain cells in map
	for y in range(map_size.y):
		for x in range(map_size.x):

			var mountain_level_index = 1
			var pixel_color : Color = _noise_image.get_pixel(x, y)
			
			for tresh : float in level_noise_tresholds:
				if pixel_color.v >= tresh:
					mountain_heightmap[y][x] = mountain_level_index
					mountain_level_index += 1

	return mountain_heightmap
