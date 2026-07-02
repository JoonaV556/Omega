extends Node

@export var tmap: TileMapLayer

func _ready():
	generate.call_deferred()

func generate():
	#generate 
	var q = QuadTree2D.new()

	q.divide_recursive(5)

	# draw on tilemap
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()

	for qt : QuadTree in q.get_leaves():
		
		var qt2d = qt as QuadTree2D

		var tile_coords : Vector2 = Vector2(rng.randi_range(0, 28), rng.randi_range(0,26))

		# get quad coords
		var q_coords = qt2d.position
		
		# draw tile on quad coords
		tmap.set_cell(q_coords, 2, tile_coords)
