extends TileMapLayer


func _ready() -> void:
	gen.call_deferred()


func gen():
	
	# draw a square of cells with terrain autotiling
	var w = 5
	var h = 5

	var cells : Array[Vector2i] = []


	for y in range(h):
		for x in range(w):
			cells.append(Vector2i(x, y))
	
	set_cells_terrain_connect(
		cells,
		0,
		0,
	)
