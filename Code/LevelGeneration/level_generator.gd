extends Node
## Generates procedural terrains, cities, etc. and renders them on a [TileMapLayer] [br]
## See [method LevelGenerator.generate] for the monolithic generation and rendering function
class_name LevelGenerator

@export var tmap: TileMapLayer

@export_category("Generator parameters")
## Number of levels to generate side by side
@export var iterations = 3
## Level width in tilemap tiles
@export var w : int = 30
## Level height in tilemap tiles
@export var h : int = 30
## Number of empty tiles placed horizontally between each generated level iteration
@export var gap = 1
@export var randomize_generator_seed = true
@export var generator_seed = 12345
@export var terrain_noise_freq = 0.0841
@export var rwg_cell_template_library : CellTemplateLibrary

# Base terrain height
@export var base_terrain_height_noise_freq = 0.0841
@export var base_terrain_tiles : Array[Vector3i]
@export var ground_tile : Vector2i = Vector2i(1,7)

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
@export_group("Roads")
## Size of map road cells in tilemap tiles. 4x4 results in road cells sized 4x4 tiles, or 4x4 meters
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

# Zones 
@export_group("Zones")
@export var dominant_zone : ZONE
@export var zone_weights : Dictionary[ZONE, float]
@export var debug_enable_zone_color_overlay = false
@export var debug_zone_colors : Dictionary[ZONE, Color]


enum tunneler_dir {N, S, E, W}

enum ZONE {
	residential,
	commercial,
	industrial,
}

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

#region Generate Terrain
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

		# prevent forest edge over lake, river canal, and mountain cells
		forest_edge_cells = OmegaUtils.array_compare_replace_with_2D(forest_edge_cells, lake_map, true, false)
		forest_edge_cells = OmegaUtils.array_compare_replace_with_2D(forest_edge_cells, mountains_heightmap, 0, false, true)

		# prevent forest over mountains, lakes, rivers etc.
		forest_cells = forest_cells.filter(func(cell : Vector2i): return mountains_heightmap[cell.y][cell.x] == 0)
		forest_cells = forest_cells.filter(func(cell : Vector2i): return lake_map[cell.y][cell.x] == false)
#endregion

#region Generate Highways
		# Generate big roads
		var road_grid_dimensions : Vector2i = Vector2i(
			int(float(w) / road_cell_size.x),
			int(float(h) / road_cell_size.y)
		)

		## Coordinates of each highway cell
		var highway_cell_coordinates : Array[Vector2i] = Tunneler2D.branching_random_leap(
			Vector2i(road_grid_dimensions.x, road_grid_dimensions.y), 
			big_road_max_turns, 
			big_road_min_walk_length,
			big_road_max_branches
			)
		
		var highway_cell_connections : PackedByteArray = []
		highway_cell_connections.resize(road_grid_dimensions.x * road_grid_dimensions.y)
		highway_cell_connections.fill(0)

		# Save big roads to road grid
		for road_cell in highway_cell_coordinates:
			var connections = 0

			# Connect to neighboring road cells
			if highway_cell_coordinates.has(road_cell + Vector2i(0, -1)):
				connections += R_CONNECTION_N
			if highway_cell_coordinates.has(road_cell + Vector2i(0, 1)):
				connections += R_CONNECTION_S
			if highway_cell_coordinates.has(road_cell + Vector2i(1, 0)):
				connections += R_CONNECTION_E
			if highway_cell_coordinates.has(road_cell + Vector2i(-1, 0)):
				connections += R_CONNECTION_W

			# Connect to map edge
			var edge_connections = get_connections_to_map_edges(road_cell, road_grid_dimensions)
			for connection in edge_connections:
				connections = add_connection(connections, connection)
				
			highway_cell_connections[grid_get_index(Vector2i(road_grid_dimensions), road_cell)] = connections
#endregion

#region Generate Small Roads
		# Generate small roads
		## Unprocessed array of small road cell coordinates produced by a generation algorithm. May contain duplicate cells due to how Random Walk and similar algorithms work.
		var small_road_cell_coords_raw : Array[Vector2i]= generate_small_roads(
			highway_cell_coordinates, 
			road_grid_dimensions, 
			small_road_random_walk_length,
			small_road_random_walk_turn_odds
			)
		
		# Erase small road cells overlapping big roads
		small_road_cell_coords_raw = small_road_cell_coords_raw.filter(
			func doesnt_overlap_big_road(cell): return !highway_cell_coordinates.has(cell)
			)

		# Create 1D array for small road cells 
		var small_road_connections : PackedByteArray = []
		small_road_connections.resize(road_grid_dimensions.x * road_grid_dimensions.y)
		small_road_connections.fill(0)

		# Randomize directional connections for small roads
		for sr_cell in small_road_cell_coords_raw:
			# Skip if cell already has connections (random walk produces duplicate cells)
			var connections = small_road_connections[grid_get_index(road_grid_dimensions, sr_cell)]
			var cell_index = grid_get_index(road_grid_dimensions, sr_cell)
			if connections != 0:
				continue

			# Ensure at least 1 onnection
			var ensured_connection = possible_connections.pick_random()
			small_road_connections[cell_index] = add_connection(connections, ensured_connection)

			# Add each connection with 50/50 odds
			for c in possible_connections:
				if OmegaUtils.roll_percentage_odds(50.0):
					connections = small_road_connections[cell_index]
					small_road_connections[cell_index] = add_connection(connections, c)
			
		# Convert 1D connections to an array of small road 2D coordinates (removes duplicate coords caused by random walk)
		## 2D road grid coordinates containing small roads / urban cells. Can be considered "clean" as no duplicate coordinates should exist.
		var small_road_cell_coords : Array[Vector2i] = []
		for n in range(small_road_connections.size()):
			var sr_connections = small_road_connections[n]
			if sr_connections != 0:
				small_road_cell_coords.append(
					index_to_coordinates(n, road_grid_dimensions)
				)
		
		print('Generated %s small road cells' % [small_road_cell_coords.size()])

		# Ensure no isolated small road sections remain
		var passes = 0
		while true:
			print('\n Grouping small road cells, pass: %s' % [passes])
			var cellgroups = get_connected_cellgroups(
				small_road_cell_coords,
				small_road_connections,
				road_grid_dimensions
			)

			print('Found %s connected groups of small road cells' % [cellgroups.size()])
			
			# Stop connecting if all cellgroups are connected to highways
			var cellgroups_not_connected_to_highways = 0
			for cg in cellgroups:
				if !is_next_to_highway(cg, highway_cell_coordinates, road_grid_dimensions):
					cellgroups_not_connected_to_highways += 1
			if cellgroups_not_connected_to_highways == 0:
				break
			
			print('Found %s isolated small road cellgroups' % [cellgroups_not_connected_to_highways])

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
				small_road_connections[c_idx] = add_connection(
					small_road_connections[c_idx],
					dir
					)
				n += 2

			print('Made %s new connections' % [int(new_connections.size() / 2.0)])

			cellgroups = get_connected_cellgroups(
				small_road_cell_coords,
				small_road_connections,
				road_grid_dimensions
			)

			print('Found %s cellsgroups after merging groups' % [cellgroups.size()])
				
			passes += 1

		print('Connected all small road cells to highways after %s connection passes' % [passes])

		# Remove dead-end small road connections 
		for cell : Vector2i in small_road_cell_coords:
			var cell_index = grid_get_index(road_grid_dimensions, cell)
			var connections : int = small_road_connections[cell_index]

			for direction : int in possible_connections:
				if !has_connection(connections, direction):
					continue

				# Erase connections to neighbours roads which don't return the connection (Connections pointing one way only)
				var neighbour = get_cell_in_direction(cell, direction)
				var neighbour_index = grid_get_index(road_grid_dimensions, neighbour)
				var opposite_direction = opposite_connections[direction]
				var neighbour_has_connection = (
					small_road_cell_coords.has(neighbour)
					and has_connection(small_road_connections[neighbour_index], opposite_direction)
				)
				if !neighbour_has_connection:
					connections -= direction

			small_road_connections[cell_index] = connections
#endregion

#region Connect small roads to highways
		# Gather islands of connected small road sections
		var small_road_islands = get_connected_cellgroups(
			small_road_cell_coords,
			small_road_connections,
			road_grid_dimensions
		)
		print("\nConnecting small roads to highways")
		print('Found %s separate islands of connected small road cells' % [small_road_islands.size()])
		print("Small road cell count in each island:")
		var i_idx = 1
		for island in small_road_islands:
			print('\t%s. %s' % [i_idx, island.size()])
			i_idx += 1
		
		# Pick 1 highway connection cell for each island
		## highway connection cells coordinates for each small road grouping
		print("Picking highway-small-road connection cells")
		var connection_cell_coordinates : Array[Vector2i] = []

		for island in small_road_islands:
			## All possible connection cells for this specific island
			var connection_cell_candidates = []
			for _cell in island:
				var neighbours = get_neighbor_coordinates(
					_cell,
					road_grid_dimensions
				)
				connection_cell_candidates.append_array(
					neighbours.filter(
						func(_nc : Vector2i): return highway_cell_coordinates.has(_nc)
					)
				)
			connection_cell_coordinates.append(connection_cell_candidates.pick_random())
		
		print('Picked %s connection cells at the following coordinates:' % [connection_cell_coordinates.size()])
		for _c in connection_cell_coordinates:
			print('\t%s' % [_c])

		# Connect neighboring roads and connector cells together
		print("Connecting small road cells to highway connector cells.")
		var connector_cells : Array[RoadConnectorCell] = []
		var connection_count = 0
		for _c in connection_cell_coordinates:
			var connector_cell = RoadConnectorCell.new()
			connector_cell.coordinate = _c
			
			var neighbour_cell_directions : Dictionary[Vector2i, int] = get_neighboring_cells_directions(_c, road_grid_dimensions)
			for _neighbour_cell : Vector2i in neighbour_cell_directions.keys():
				
				# Check if neighbour cell is a small road
				if small_road_cell_coords.has(_neighbour_cell):
					
					# Connect small road to the connector
					var connections = small_road_connections[grid_get_index(road_grid_dimensions, _neighbour_cell)]
					small_road_connections[grid_get_index(road_grid_dimensions, _neighbour_cell)] = add_connection(
						connections, 
						opposite_connections[neighbour_cell_directions[_neighbour_cell]] # Get direction pointing from the small road cell towards us (the connector cell)
						)
					connection_count+=1

					# Connect connector cell to the small road 
					connector_cell.small_road_connections = add_connection(
						connector_cell.small_road_connections,
						neighbour_cell_directions[_neighbour_cell]
					)

			# Connect connector to highway
			connector_cell.highway_connections = highway_cell_connections[grid_get_index(road_grid_dimensions, _c)]
			
			connector_cells.append(connector_cell)
		print('Connected %s small road cells to highway connectors.' % [connection_count])
		for _connector : RoadConnectorCell in connector_cells:
			print('\nConnections for connector cell at coordinates %s:' % [_connector.coordinate])
			print('\tSmall road connections: %s' % [get_connections_readable(_connector.small_road_connections)])
			print('\tHighway connections: %s' % [get_connections_readable(_connector.highway_connections)])
#endregion

#region Pick cell templates for road cells

		var small_road_cell_templates : Dictionary[Vector2i, RoadCellTemplate]
		var road_connector_cell_templates : Dictionary[Vector2i, RoadConnectorCellTemplate]
		var highway_cell_templates : Dictionary[Vector2i, RoadCellTemplate]

		for _c : Vector2i in small_road_cell_coords:
			var templ = rwg_cell_template_library.get_random_small_road_template(
				get_value_at_2d_coordinates(
					small_road_connections,
					_c,
					road_grid_dimensions
				)
			)
			if templ:
				small_road_cell_templates[_c] = templ

		for _c : RoadConnectorCell in connector_cells:
			var templ = rwg_cell_template_library.get_random_connector_template(
				_c.small_road_connections,
				_c.highway_connections
			)
			if templ:
				road_connector_cell_templates[_c.coordinate] = templ

		for _c : Vector2i in highway_cell_coordinates:
			var templ = rwg_cell_template_library.get_random_highway_template(
				get_value_at_2d_coordinates(
					highway_cell_connections,
					_c,
					road_grid_dimensions
				)
			)
			if templ:
				highway_cell_templates[_c] = templ
		
		print('Succesfully picked %s cell templates for %s small road cells.' % [small_road_cell_templates.keys().size(), small_road_cell_coords.size()])
		print('Succesfully picked %s cell templates for %s highway cells.' % [highway_cell_templates.keys().size(), highway_cell_coordinates.size()])
		print('Succesfully picked %s cell templates for %s road connector cells.' % [road_connector_cell_templates.keys().size(), connector_cells.size()])

#endregion

#region Generate Zones
		# Calculate number of cells to allocate for each zone type
		var cells_per_zone : Dictionary[ZONE, int] = {}
		var cells_per_cluster : Dictionary[ZONE, Array] = {}
		var clusters_per_zone : Dictionary[ZONE, int] = {}
		var zone_cells_total : int = small_road_cell_coords.size()
		var zones : Array[ZONE] = zone_weights.keys()
		var active_zones : Array[ZONE] = []
		var zone_weights_sum : float = 0.0

		# Ignore zero-weighted zones and guard against invalid weights.
		for _z : ZONE in zones:
			if zone_weights.has(_z) and zone_weights[_z] > 0.0:
				active_zones.append(_z)
				zone_weights_sum += zone_weights[_z]

		if active_zones.is_empty():
			active_zones = [dominant_zone]
			zone_weights_sum = 1.0

		# Allocate the exact total number of road cells across all zones.
		var zone_fractional_remainders : Dictionary[ZONE, float] = {}
		var cells_left_to_allocate : int = zone_cells_total
		for _z : ZONE in active_zones:
			var raw_allocation : float = (zone_weights[_z] / zone_weights_sum) * float(zone_cells_total)
			var allocation : int = int(raw_allocation)
			cells_per_zone[_z] = allocation
			zone_fractional_remainders[_z] = raw_allocation - float(allocation)
			cells_left_to_allocate -= allocation

		while cells_left_to_allocate > 0:
			var best_zone : ZONE = active_zones[0]
			var best_remainder : float = -1.0
			for _z : ZONE in active_zones:
				var remainder : float = zone_fractional_remainders.get(_z, 0.0)
				if remainder > best_remainder:
					best_remainder = remainder
					best_zone = _z
			cells_per_zone[best_zone] += 1
			zone_fractional_remainders[best_zone] = 0.0
			cells_left_to_allocate -= 1

		# Distribute the allocated cells into cluster sizes while keeping each cluster valid.
		var cells_allocated_for_zones_total : int = 0
		for _z : ZONE in active_zones:
			var zone_cell_count : int = cells_per_zone.get(_z, 0)
			if zone_cell_count <= 0:
				clusters_per_zone[_z] = 0
				cells_per_cluster[_z] = []
				continue

			var cluster_count_target : float = float(zone_cell_count) / 3.0
			var cluster_count_spread : float = max(1.0, cluster_count_target * 0.5)
			var cluster_count_randomized : int = int(round(randfn(cluster_count_target, cluster_count_spread)))
			var cluster_count : int = clampi(cluster_count_randomized, 1, max(1, zone_cell_count))
			clusters_per_zone[_z] = cluster_count

			var cluster_cell_sizes : Array = []
			var remaining_cells : int = zone_cell_count
			var remaining_clusters : int = cluster_count
			for _cluster in range(cluster_count):
				remaining_clusters -= 1
				var target_cluster_size : float = float(remaining_cells) / float(remaining_clusters + 1)
				var spread : float = max(1.0, target_cluster_size * 0.5)
				var min_for_this_cluster : int = 1
				var max_for_this_cluster : int = remaining_cells - remaining_clusters
				if max_for_this_cluster < min_for_this_cluster:
					max_for_this_cluster = min_for_this_cluster
				var gaussian_cluster_size : int = int(round(randfn(target_cluster_size, spread)))
				var cluster_size : int = clampi(gaussian_cluster_size, min_for_this_cluster, max_for_this_cluster)
				cluster_cell_sizes.append(cluster_size)
				remaining_cells -= cluster_size
				cells_allocated_for_zones_total += cluster_size

			# Ensure the sum of cluster sizes matches the exact zone total.
			var cluster_total : int = 0
			for cluster_size : int in cluster_cell_sizes:
				cluster_total += cluster_size
			if cluster_total != zone_cell_count:
				cluster_cell_sizes[-1] += zone_cell_count - cluster_total
			cells_per_cluster[_z] = cluster_cell_sizes

		# Also keep the zone summary readable if some zones are not used.
		for _z : ZONE in zones:
			if !cells_per_zone.has(_z):
				cells_per_zone[_z] = 0
			if !clusters_per_zone.has(_z):
				clusters_per_zone[_z] = 0
			if !cells_per_cluster.has(_z):
				cells_per_cluster[_z] = []

		# Print results readable
		print('\nAllocated zones for %s small road cells in total' % [small_road_cell_coords.size()])
		print('Cells allocated for zones: %s' % [cells_allocated_for_zones_total])
		print("Zone allocation summary:")
		for _z : ZONE in zones:
			var zone_name : String = ZONE.keys()[int(_z)]
			print(
				"- %s | cells=%s | clusters=%s | cells_per_cluster=%s" % [
					zone_name,
					cells_per_zone[_z],
					clusters_per_zone[_z],
					cells_per_cluster[_z]
				]
			)

		# Distribute zones on map
		## -1 == no zoned / no road 
		var zone_cells : PackedByteArray = []
		zone_cells.resize(road_grid_dimensions.x * road_grid_dimensions.y)
		zone_cells.fill(-1)

		# pre-step - fill all urban cells with dominant zone 
		for coord in small_road_cell_coords:
			grid_1d_set_value(
					coord,
					dominant_zone,
					zone_cells,
					road_grid_dimensions
			)

		var free_cells : Array[Vector2i] = small_road_cell_coords.duplicate()

		for _z : ZONE in zones:
			var z_cluster_sizes : Array = cells_per_cluster[_z]
			
			for cluster_size : int in z_cluster_sizes:
				# set first cell in cluster
				var cells_remaining : int = cluster_size
				var start_cell : Vector2i= free_cells.pick_random()
				grid_1d_set_value(
					start_cell,
					_z,
					zone_cells,
					road_grid_dimensions
				)
				free_cells.erase(start_cell)
				cells_remaining -= 1

				var current_cell = start_cell
				while cells_remaining > 0:
					# pick next cell from neighboring small road cells
					var neighboring_coordinates = get_neighbor_coordinates(start_cell, road_grid_dimensions)
					neighboring_coordinates.filter(
						func(coord : Vector2i): # filter only cells which are urban and dont already have this zone
							var is_urban = small_road_cell_coords.has(coord)
							var not_this_zone = get_value_at_2d_coordinates(zone_cells, coord, road_grid_dimensions) != _z
							return  is_urban and not_this_zone
					)

					if neighboring_coordinates.is_empty():# no neighboring urban cells left, create new cluster at a new coordinate
						current_cell = free_cells.pick_random()
						continue 
				
					current_cell = neighboring_coordinates.pick_random()
					grid_1d_set_value(
						current_cell,
						_z,
						zone_cells,
						road_grid_dimensions
					)
					free_cells.erase(current_cell)
					cells_remaining -= 1
		
		# preview zones placed on road grid with semi-transparent colored ColorRect nodes
		if debug_enable_zone_color_overlay:
			if tmap != null:
				for child in tmap.get_children():
					if child is ColorRect and child.name.begins_with("zone_preview_"):
						child.queue_free()

			for idx in range(zone_cells.size()):
				var zone_value : int = zone_cells[idx]
				if zone_value < 0:
					continue

				var zone_key : int = zone_value
				if !debug_zone_colors.keys().has(zone_key):
					continue

				var zone_coord : Vector2i = index_to_coordinates(idx, road_grid_dimensions)
				var preview_rect : ColorRect = ColorRect.new()
				preview_rect.name = "zone_preview_%s" % [ZONE.keys()[zone_key]]
				preview_rect.color = debug_zone_colors[zone_key]
				preview_rect.size = Vector2(road_cell_size) * 16.0
				preview_rect.position = (Vector2(zone_coord * road_cell_size) + Vector2(offset, 0)) * 16.0
				preview_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
				tmap.add_child(preview_rect)

#endregion

#region Generate buildings
		# Pick buildings for each building plot on map, and save it with its position on the tilemap
		## [Position on tilemap] [Building]
		var buildings : Dictionary[Vector2i, BuildingTemplate]
		var building_template_groups : Array[Dictionary] = [small_road_cell_templates, road_connector_cell_templates, highway_cell_templates]
		var building_plot_count = 0
		var buildings_placed_count = 0
		for template_group in building_template_groups:
			for coord in template_group.keys():
				var template = template_group[coord]
				if template == null:
					continue
				for bp : BuildingPlot in template.building_plots:
					building_plot_count += 1
					var matching_buildings = rwg_cell_template_library.get_matching_buildings(bp.dimensions)
					if matching_buildings.is_empty():
						continue
					var building_position_on_tilemap = (coord * road_cell_size) + bp.position + Vector2i(offset, 0)
					buildings[building_position_on_tilemap] = matching_buildings.pick_random()
					buildings_placed_count += 1
		print('Picked %s buildings for %s building plots found on road cells.' % [buildings_placed_count, building_plot_count])
#endregion

#region Render
#region Render Terrain
		# Render terrain on tilemap
		for y in range(h):
			for x in range(w):
				var source_id : int = 4
				var atlas_coords : Vector2i = ground_tile

				# Base terrain
				var base_terrain_height : int = base_terrain_heightmap[y][x]
				if base_terrain_height < base_terrain_tiles.size():
					var base_terrain_tile : Vector3i = base_terrain_tiles[base_terrain_height]
					source_id = base_terrain_tile.z
					atlas_coords = Vector2i(base_terrain_tile.x, base_terrain_tile.y)
				
				# Lake
				if lake_map[y][x] == true:
					source_id = lake_tile.z
					atlas_coords = Vector2i(lake_tile.x, lake_tile.y)
				
				# Mountains
				var mount_height : int = mountains_heightmap[y][x]
				if mount_height > 0 and mount_height <= mountain_level_tiles.size():
					var mountain_tile : Vector3i = mountain_level_tiles[mount_height - 1]
					source_id = mountain_tile.z
					atlas_coords = Vector2i(mountain_tile.x, mountain_tile.y)
				
				# Forest edge
				if forest_edge_cells[y][x] == true:
					source_id = forest_edge_tile.z
					atlas_coords = Vector2i(forest_edge_tile.x, forest_edge_tile.y)

				tmap.set_cell(Vector2i(x + offset, y), source_id, atlas_coords)

		# Forest overrides the terrain cell, matching the previous render order.
		for coord in forest_cells:
			tmap.set_cell(
				Vector2i(coord.x + offset, coord.y),
				forest_edge_tile.z,
				Vector2i(forest_edge_tile.x, forest_edge_tile.y)
			)
#endregion

#region Render Urban
		# Render highways
		for coord in highway_cell_coordinates:
			var coordindate_on_tilemap : Vector2i = coord * road_cell_size

			# Retrieve a tile pattern with matching the connections
			var r_pattern : TileMapPattern = highway_cell_templates[coord].tilemap_pattern

			# Paint on tilemap
			set_pattern_ignore_empty_tiles(tmap, coordindate_on_tilemap + Vector2i(offset, 0), r_pattern)

		# Render small roads
		for coord in small_road_cell_coords:
			var coordindate_on_tilemap : Vector2i = coord * road_cell_size

			# Retrieve a tile pattern with matching the connections
			var r_pattern : TileMapPattern = small_road_cell_templates[coord].tilemap_pattern

			# Paint on tilemap
			set_pattern_ignore_empty_tiles(tmap, coordindate_on_tilemap + Vector2i(offset, 0), r_pattern)

		# Render road connectors 
		for connector_cell in connector_cells:  
			var coordindate_on_tilemap : Vector2i = connector_cell.coordinate * road_cell_size

			# Retrieve a tile pattern with matching the connections
			var r_pattern : TileMapPattern = road_connector_cell_templates[connector_cell.coordinate].tilemap_pattern

			# Paint on tilemap
			set_pattern_ignore_empty_tiles(tmap, coordindate_on_tilemap + Vector2i(offset, 0), r_pattern)

		# Render buildings 
		for tilemap_coord : Vector2i in buildings.keys():
			var b_template : BuildingTemplate = buildings[tilemap_coord]

			var sprite : Sprite2D = Sprite2D.new()
			sprite.centered = false
			sprite.texture = b_template.texture
			sprite.name = str("building - " + b_template.name)
			tmap.add_sibling(sprite)
			sprite.global_position = Vector2(tilemap_coord) * Vector2(16.0, 16.0)

#endregion
#endregion
		print("x offset: %s" % [offset])
		print("\n")


func set_pattern_ignore_empty_tiles(tilemap: TileMapLayer, tilemap_coord: Vector2i, pattern: TileMapPattern) -> void:
	if tilemap == null or pattern == null:
		return

	var pattern_size : Vector2i = pattern.get_size()
	for y in range(pattern_size.y):
		for x in range(pattern_size.x):
			var local_cell_coord : Vector2i = Vector2i(x, y)
			var source_id : int = pattern.get_cell_source_id(local_cell_coord)
			var atlas_coords : Vector2i = pattern.get_cell_atlas_coords(local_cell_coord)

			if source_id < 0 or atlas_coords.x < 0 or atlas_coords.y < 0:
				continue

			tilemap.set_cell(tilemap_coord + local_cell_coord, source_id, atlas_coords)


class RoadConnectorCell:
	var coordinate : Vector2i
	var small_road_connections : int
	var highway_connections : int


## returns 1d array member at index mapped from 2d coordinates.
func get_value_at_2d_coordinates(array_1d, coord: Vector2i, dimensions: Vector2i) -> Variant:
	return array_1d[grid_get_index(dimensions, coord)]


## sets a 1d array member at the index mapped from 2d coordinates.
func grid_1d_set_value(coord: Vector2i, value: Variant, array_1d, array_dimensions: Vector2i) -> void:
	array_1d[grid_get_index(array_dimensions, coord)] = value


func is_next_to_highway(cellgroup : Array[Vector2i], highway_cells, grid_dimensions) -> bool:
	for cell in cellgroup:
		for c in get_neighbor_coordinates(cell, grid_dimensions):
			if highway_cells.has(c):
				return true

	return false


## Returns all connected cells in cleanly separated groupings / islands
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
	var neighbors = get_neighbor_coordinates(cell, map_dimensions)
	
	var connected = neighbors.filter(
		func(_c): return are_connected(cell, _c, connections_grid, map_dimensions)
	)

	return connected


## Returns cells in NSEW directions. Filters cells outside map bounds if map_dimensions are given
func get_neighbor_coordinates(cell, map_dimensions : Vector2i = Vector2i(-1, -1)) -> Array[Vector2i]:
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
	var a_neighbours = get_neighbor_coordinates(cell_a)
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
static func add_connection(connections : int, connection : int) -> int:
	if !has_connection(connections, connection):
		return connections + connection
	return connections


static func has_connection(connections : int, direction: int) -> bool:
	return (connections & direction) != 0


## Returns each directional road connection represented by the bitmask.
func get_connections(connections : int) -> Array[int]:
	var separate_connections : Array[int] = []

	for direction : int in possible_connections:
		if has_connection(connections, direction):
			separate_connections.append(direction)

	return separate_connections


## Returns each directional road connection represented by the bitmask as a readable string.
func get_connections_readable(connections : int) -> Array[String]:
	var readable_connections : Array[String] = []

	for direction : int in possible_connections:
		if !has_connection(connections, direction):
			continue

		match direction:
			R_CONNECTION_N:
				readable_connections.append("North")
			R_CONNECTION_S:
				readable_connections.append("South")
			R_CONNECTION_E:
				readable_connections.append("East")
			R_CONNECTION_W:
				readable_connections.append("West")

	return readable_connections


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
