extends Node

@export var tmap: TileMapLayer

@export var cell_size_in_tiles : int = 10

@export var tree_iterations : int = 3

@export_group("Leaf trimming options")
@export
var trim_odds_percentage : Array[float] = [0.0]

enum tunneler_dir {N, S, E, W}

func _ready():
	generate_v2.call_deferred()

func generate_v2():
	# generate tree 
	var q : QuadTree2D = QuadTree2D.new()

	q.divide_recursive(tree_iterations)
	
	# fill with grass
	TilemapLayerExtensions.fill_area(
			tmap,
			Vector2i(0, 0),
			q.size * cell_size_in_tiles,
			4,
			Vector2i(1,7)
		)

	# generate road grid Array[Array[bool], where true=road, false=non-road
	var road_grid : Array[Array] = []

	for i in range(q.size.x):
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
	ts.turn_odds_percentage = 20.0
	
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
					Vector2i(x, y),
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
