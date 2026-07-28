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
@export var max_turns = 5
@export var min_walk_length = 3
@export var river_max_branches = 1
@export var mark_water_treshold = 0.7
@export var water_noise_frequency = 0.0326
@export var remove_lakes_near_rivers_radius : int = 4
@export var ground_tile : Vector2i = Vector2i(1,7)
@export var river_tile = Vector2i(17,39)

@export var mountain_noise_freq : float = 0.0841
@export var mountains_height_max_l : int  = 4
@export var mountains_level_noise_tresholds : Array[float]
@export var mountain_level_1_tile : Vector3i
@export var mountain_level_2_tile : Vector3i

enum tunneler_dir {N, S, E, W}


func _ready():
	test.call_deferred()


func test():
	for i in range(iterations):

		var offset = (w*i) + (gap*i)

		# paint ground
		for y in range(h):
			for x in range(w):
				tmap.set_cell(
					Vector2i(x + offset, y),
					4,
					ground_tile
				)

		# generate lakes with noise
		var n_gen = FastNoiseLite.new()
		n_gen.seed = randi()
		n_gen.noise_type = FastNoiseLite.TYPE_PERLIN
		n_gen.frequency = water_noise_frequency
		var n_image : Image = n_gen.get_image(
			w,
			h
		)
		# render water 
		for y in range(h):
			for x in range(w):
				
				var pixel_color : Color = n_image.get_pixel(x,y)
				if pixel_color.v > mark_water_treshold:
					tmap.set_cell(
						Vector2i(x+offset, y),
						4,
						Vector2i(11,57)
					)

		# generate rivers canals
		var r_cells : Array[Vector2i] = Tunneler2D.random_walk(
			Vector2i(w, h), 
			max_turns, 
			min_walk_length,
			river_max_branches
			)
		# render rivers canals
		for c : Vector2i in r_cells:
			tmap.set_cell(
					c + Vector2i(offset, 0),
					4,
					Vector2i(17,39)
				)

		# remove lakes near river canals (get all cells in square area around river cell and check if they are within distance of river)
		var to_unmark_as_lakes : Array[Vector2i] = []
		for r_cell : Vector2i in r_cells:
			var x = r_cell.x - remove_lakes_near_rivers_radius
			var y = r_cell.y - remove_lakes_near_rivers_radius
			for y_off in range(remove_lakes_near_rivers_radius*2):
				for x_off in range(remove_lakes_near_rivers_radius*2):

					# ignore cells outside map bounds
					var map_cell = Vector2i(x+x_off, y+y_off)
					if (map_cell.x < 0) or (map_cell.x >= w) or (map_cell.y < 0) or (map_cell.y >= h):
						continue

					# ignore river cells
					if map_cell == r_cell: # ignore the rivel cell itself
						continue

					# check distance
					var distance = r_cell.distance_to(map_cell)

					if distance <= remove_lakes_near_rivers_radius:
						
						# unmark as lake 
						to_unmark_as_lakes.append(map_cell)
						
		# return lake cells back to ground around rivers
		for cell : Vector2i in to_unmark_as_lakes:
			if r_cells.has(cell): # skip river cells
				continue
			tmap.set_cell(
				cell  + Vector2i(offset, 0),
				4,
				ground_tile
			)
	
		# generate mountains 
		var mountains : Array[Array] = generate_mountains(Vector2i(w,h), mountain_noise_freq, mountains_level_noise_tresholds)

		# render mountains LEFT TODO

		print("x offset: %s" % [offset])
		print("\n")


func generate_mountains(grid_size, _noise_frequency, level_noise_tresholds : Array[float] = []) -> Array[Array]:
	var mountain_heightmap : Array[Array] = OmegaUtils.create_grid(grid_size.x, grid_size.y, 0)

	if level_noise_tresholds.is_empty():
		return []

	# generate noise
	var n_gen = FastNoiseLite.new()
	n_gen.seed = randi()
	n_gen.noise_type = FastNoiseLite.TYPE_PERLIN
	n_gen.frequency = _noise_frequency
	var n_image : Image = n_gen.get_image(
		grid_size.x,
		grid_size.y
	)

	# mark mountain levels in grid
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var tresh_idx = 1
			var pixel_color : Color = n_image.get_pixel(x,y)
			for tresh : float in level_noise_tresholds:
				if pixel_color.v >= tresh:
					mountain_heightmap[y][x] = tresh_idx
					tresh_idx += 1

	for y in range(h):
		for x in range(w):
			var pixel_color : Color = n_image.get_pixel(x,y)
			print('pixel v: %s' % [pixel_color.v])

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
