extends Node

@export var tmap: TileMapLayer
@export var cell_size : int

func _ready():
	generate.call_deferred()

func generate():
	#generate 
	var q = QuadTree2D.new()

	q.divide_recursive(3)

	# draw on tilemap
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()

	for qt : QuadTree in q.get_leaves():
		
		var qt2d = qt as QuadTree2D

		var atlas_coords : Vector2i = Vector2i(rng.randi_range(0, 28), rng.randi_range(0,26))

		var tmap_coords : Vector2i = Vector2i(qt2d.position.x * cell_size, qt2d.position.y * cell_size)
		
		# draw tile on quad coords
		TilemapLayerExtensions.fill_area(
			tmap,
			tmap_coords,
			qt2d.size * cell_size,
			2,
			atlas_coords
		)
