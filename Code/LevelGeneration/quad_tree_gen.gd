extends Node

@export var tmap: TileMapLayer

@export var cell_size : int

@export var tree_iterations : int = 3

@export_group("Leaf trimming options")
@export
var trim_odds_percentage : Array[float] = [0.0]

func _ready():
	generate.call_deferred()

func generate():
	# generate tree 
	var q = QuadTree2D.new()

	q.divide_recursive(4)

	# trim leaves to introduce size variance 
	for i in range(q.get_levels()-1):

		var trim_odds = trim_odds_percentage[i]
		var quads : Array[QuadTree] = q.get_level(i)
		var trimmed_count = 0
		
		if quads.is_empty():
			break

		for qd in quads:
			if roll_percentage_odds(trim_odds):
				qd.trim_leaves()
				trimmed_count += 1
		
		var s = "With odds of %s percent per quad, trimmed %s quads out of %s quads on tree level %s"
		print(s % [trim_odds, trimmed_count, quads.size(), i])

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

func roll_percentage_odds(percentage : float = 100.0) -> bool:
	if percentage <	0.0001:
		return false
	if percentage > 99.99:
		return true

	var p_norm = percentage / 100.0
	var rand = randf()
	return rand <= p_norm
	print("rolled percentage")
