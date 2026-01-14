extends Node
class_name LevelGenerator

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
var g_ready_to_generate: bool = false

func _process(delta: float) -> void:
	if first_update:
		first_update = false
		g_ready_to_generate = true

## Tries to generate the level, returns the map data as a bsp tree 
func _draw_level() -> bool:
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
	
	return true
	
func _generate(_width: int, _height: int, _iterations: int) -> Array:
	# generate level data with a binary tree
	var l_tree: Array
	var iterations_done = 0
	for i in range(0, _iterations):
		var number_created = 0
		l_tree.append([] as Array[BspNode])
		
		# create root node 
		if i == 0:
			var root = BspNode.new(Vector2i(0,0), _width, _height)
			l_tree[i].append(root)
			number_created += 1
			
		# create child nodes for the parents on the upper level and add them on the current level
		else:
			for node: BspNode in l_tree[i-1]:
				var children = node._create_children()
				for child in children:
					l_tree[i].append(child)
				number_created += 2
		iterations_done += 1
		print("Created "+str(number_created)+" nodes on BSP tree level: "+str(i))
	print("Created a total of "+str(iterations_done)+" levels on BSP tree")
	return l_tree
