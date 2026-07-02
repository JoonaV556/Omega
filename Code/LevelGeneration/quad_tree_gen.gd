extends Node

@export var tmap: TileMapLayer

func _ready():
	generate.call_deferred()

func generate():
	#generate 
	var q = QuadTree.new()

	q.divide_recursive(5)

	# draw on tilemap
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()

	for qt : QuadTree in q.get_leaves():
		
		var tile_coords : Vector2 = Vector2(rng.randi_range(0, 28), rng.randi_range(0,28))

		# get quad coords

		# draw tile on quad coords

		pass 
