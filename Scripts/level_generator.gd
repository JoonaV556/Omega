extends Node

@export 
var root: 	Node2D
@export
var player: Node2D
@export 
var tiles: 	TileSet
@export
var print_each_generated_cell_coord: bool = true

@export_range(10,9999) 
var width: 	int = 100
@export_range(10,9999) 
var height: int = 100

@export_range(1,999)
var bsp_tree_iterations: int = 4

@export
var groundcoords: Vector2i = Vector2i(17,56)
@export
var roadcoords: Vector2i = Vector2i(1,7) 

var tmap		: TileMapLayer
var first_update = true
var level		: Array 		= [[]] # two dim array

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
	
	# testing draw a square of tiles
	print("Generating map with the following width and height: "+str(width)+", "+str(height))
	var generated_tiles = 0
	for i in range(-1, -(height+1), -1):
		for j in range(width):
			tmap.set_cell(Vector2i(j, i), 0, groundcoords)
			generated_tiles += 1
			if print_each_generated_cell_coord:
				print("Set cell " + str(j) + ", " + str(i))
	print("Generated "+str(generated_tiles)+" tiles!")
	
	# generate level data with a binary tree
	var tree: Array
	var done_iterations = 0
	for i in range(0, bsp_tree_iterations):
		var number_created = 0
		tree.append([] as Array[BspNode])
		# create root node 
		if i == 0:
			
			var root = BspNode.new(Vector2i(0,0), width, height)
			tree[i].append(root)
			number_created += 1
		# create child nodes for the parents on the upper level and add them on the current level
		else:
			for node: BspNode in tree[i-1]:
				var children = node._create_children()
				for child in children:
					tree[i].append(child)
				number_created += 2
		done_iterations += 1
		print("Created "+str(number_created)+" nodes on BSP tree level: "+str(i))
	print("Created a total of "+str(done_iterations)+" levels on BSP tree")
	
	
	
	return true
