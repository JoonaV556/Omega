extends Node

@export 
var root	: Node2D
@export
var player	: Node2D
@export 
var tiles	: TileSet

@export_range(10,9999) 
var width	: int = 100
@export_range(10,9999) 
var height	: int = 100

var tmap		: TileMapLayer
var first_update: bool = true
var print_ind_coords = true

func _process(delta: float) -> void:
	if first_update:
		first_update = false
		_generate()

## Tries to generate the level, returns false if generation fails
func _generate() -> bool:
	# create tilemap under root node
	assert(root != null, "Cannot continue, root is not set")
	if root == null:
		return false
	tmap = TileMapLayer.new()
	tmap.name = "TilemapLayer_Generated"
	if tiles != null:
		tmap.tile_set = tiles;
	root.add_child(tmap)
	
	# Move player in front of tilemap
	if player != null:
		player.move_to_front()
	
	# draw a square of random tiles 
	print("Generating map with the following width and height: "+str(width)+", "+str(height))
	var generated_tiles = 0
	for i in range(-1, -(height+1), -1):
		for j in range(width):
			tmap.set_cell(Vector2i(j, i), 0, Vector2i(11,57))
			generated_tiles += 1
			if print_ind_coords:
				print("Set cell " + str(j) + ", " + str(i))
	print("Generated "+str(generated_tiles)+" tiles!")
	
	return true
