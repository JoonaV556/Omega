extends Node

@export var tmap: TileMapLayer

@export var cell_size_in_tiles : int = 10

@export var tree_iterations : int = 3

@export_group("Leaf trimming options")
@export
var trim_odds_percentage : Array[float] = [0.0]

@export_category("generation")
@export var iterations = 3
@export var w = 30
@export var h = 30
@export var gap = 1
@export var terrain_noise_freq = 0.0841

# river canals
@export var max_turns = 5
@export var min_walk_length = 3
@export var river_max_branches = 1

@export var remove_lakes_near_rivers_radius : int = 3
@export var ground_tile : Vector2i = Vector2i(1,7)
@export var river_tile = Vector2i(17,39)

# lakes
@export var lake_water_level_treshold = 0.7 
@export var lake_tile = Vector3i(17, 39, 4)

# mountains
@export var mountains_level_noise_tresholds : Array[float]
@export var mountain_level_tiles : Array[Vector3i]

# forest edge
@export var forest_edge_thickness = 1
@export var forest_edge_tile : Vector3i

# forest middle 
@export var forest_noise_freq = 0.0841
@export var forest_noise_treshold = 0.7


enum tunneler_dir {N, S, E, W}


func _ready():
	test.call_deferred()


func test():
	for i in range(iterations):

		var offset = (w*i) + (gap*i)

		# generate noise texture for terrain
		var n_gen = FastNoiseLite.new()
		n_gen.seed = randi()
		n_gen.noise_type = FastNoiseLite.TYPE_PERLIN
		n_gen.frequency = terrain_noise_freq
		var n_image : Image = n_gen.get_image(
			w,
			h
		)

		# generate lakes
		var lake_map = generate_lakes(n_image, lake_water_level_treshold)

		# generate rivers canals
		var river_canal_cells : Array[Vector2i] = Tunneler2D.random_walk(
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
		n_gen.seed = randi()
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

		# Render terrain on tilemap
		for y in range(h):
			for x in range(w):
				var c = Vector2i(x, y)
				
				# Ground
				tmap.set_cell(
					Vector2i(x + offset, y),
					4,
					ground_tile
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

		print("x offset: %s" % [offset])
		print("\n")


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

func generate_v2():
	for i in range(1):
		var offset = (i*32*cell_size_in_tiles)+(i*gap)

		# generate tree 
		var q : QuadTree2D = QuadTree2D.new()

		q.divide_recursive(tree_iterations)
		
		# fill with grass
		TilemapLayerExtensions.fill_area(
				tmap,
				Vector2i(offset, 0),
				q.size * cell_size_in_tiles,
				4,
				Vector2i(1,7)
			)

		# generate noise image for water areas 
		var n_gen = FastNoiseLite.new()
		n_gen.seed = randi()
		n_gen.noise_type = FastNoiseLite.TYPE_PERLIN
		var n_image : Image = n_gen.get_image(
			q.size.x * cell_size_in_tiles,
			q.size.y * cell_size_in_tiles,
		)
		
		# mark water cells on water grid & render
		var w_grid : Array[Array] = OmegaUtils.create_grid(n_image.get_size().x, n_image.get_size().y, false)
		var mark_water_treshold : float  = 0.7

		for y in range(n_image.get_size().y):
			for x in range(n_image.get_size().x):

				var pixel_color : Color = n_image.get_pixel(x,y)
				
				if pixel_color.v > mark_water_treshold:
					w_grid[y][x] = true

					tmap.set_cell(
						Vector2i(x+offset, y),
						4,
						Vector2i(11,57)
					)

		# generate road grid Array[Array[bool], where true=road, false=non-road
		var road_grid : Array[Array] = []

		for x in range(q.size.x):
			var row = []
			row.resize(q.size.x)
			row.fill(false)
			road_grid.append(row)

		# single road with tunneler 
		var tunneler = Tunneler2D.new()
		var ts : Tunneler2DSettings = Tunneler2DSettings.new()
		ts.start_cell = Vector2i(15, 31)
		ts.initial_direction = Tunneler2D.move_direction.N
		ts.bounds_max = Vector2i(q.size.x-1, q.size.y-1)
		ts.min_steps_between_turns = 6
		ts.max_turns = 2
		ts.turn_odds_percentage = 15.0
		ts.allow_turning_on_edges = false
		
		var road_cells = tunneler.simple_tunnel(ts)

		# mark road cells in road grid
		for c in road_cells:
			road_grid[c.y][c.x] = true

		# draw road grid on tilemap
		for y in range(road_grid.size()):
			for x in range(road_grid[0].size()):
				if road_grid[y][x] == true:
					TilemapLayerExtensions.fill_area(
						tmap,
						Vector2i((cell_size_in_tiles*x)+offset, cell_size_in_tiles*y),
						Vector2i(1,1)  * cell_size_in_tiles,
						4,
						Vector2i(27,9)
					)


func get_cell_in_direction():
	pass


func generate_v1():
	# generate tree 
	var q = QuadTree2D.new()

	q.divide_recursive(tree_iterations)

	# trim leaves to introduce size variance 
	for i in range(q.get_levels()-1):

		var trim_odds = trim_odds_percentage[i]
		var quads : Array[QuadTree] = q.get_level(i)
		var trimmed_count = 0
		
		if quads.is_empty():
			break

		for qd in quads:
			if OmegaUtils.roll_percentage_odds(trim_odds):
				qd.trim_leaves()
				trimmed_count += 1
		
		var s = "With odds of %s percent per quad, trimmed %s quads out of %s quads on tree level %s"
		print(s % [trim_odds, trimmed_count, quads.size(), i])

	# draw on tilemap
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()

	for qt : QuadTree in q.get_leaves():
		
		var qt2d : QuadTree2D = qt as QuadTree2D

		var atlas_coords : Vector2i = Vector2i(rng.randi_range(0, 28), rng.randi_range(0,26))

		var tmap_coords : Vector2i = Vector2i(qt2d.position.x * cell_size_in_tiles, qt2d.position.y * cell_size_in_tiles)
		
		# draw tile on quad coords
		TilemapLayerExtensions.fill_area(
			tmap,
			tmap_coords,
			qt2d.size * cell_size_in_tiles,
			2,
			atlas_coords
		)
