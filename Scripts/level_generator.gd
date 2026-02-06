extends Node
class_name LevelGenerator

@export 
var draw_on_first_update: bool = true
@export 
var scene_root: 	Node2D
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

func _process(_delta: float) -> void:
	if first_update:
		first_update = false
		g_ready_to_generate = true
		if draw_on_first_update:
			_draw_level()

func _draw_level() -> bool:
	# create tilemap under root node
	assert(scene_root != null, "Cannot continue, root is not set")
	if scene_root == null:
		return false
	tmap = TileMapLayer.new()
	tmap.name = "TilemapLayer_Generated"
	if tiles != null:
		tmap.tile_set = tiles;
	scene_root.add_child(tmap)
	
	# Move player in front of tilemap
	if player != null:
		player.move_to_front()
	
	# testing - draw a square of tiles
	#print_debug("Generating map with the following width and height: "+str(width)+", "+str(height))
	#var generated_tiles = 0
	#for i: int in range(-1, -(height+1), -1):
		#for j: int in range(width):
			#tmap.set_cell(Vector2i(j, i), 0, groundcoords)
			#generated_tiles += 1
			#if print_each_generated_cell_coord:
				#print_debug("Set cell " + str(j) + ", " + str(i))
	#print_debug("Generated "+str(generated_tiles)+" tiles!")
	
	# Generate level 
	var _level: Array 			= _generate(self.width, self.height, self.bsp_tree_iterations)
	var _roads: Array[Array] 	= generate_road_grid(_level)
	var _nodes: Array[Array] 	= generate_node_grid(_level)
	
	push_error("zzz - still buggy")
	# Draw level on tilemap
	for _y in range(self.height):
		for _x in range(self.width):
			# draw road
			if _roads[_x][_y] == true:
				tmap.set_cell(Vector2i(_y, _x), 0, roadcoords)
			# draw node
			if _nodes[_x][_y] != 0:
				tmap.set_cell(Vector2i(_y, _x), 0, groundcoords)
	
	return true
	
## Tries to generate the level, returns the map data as a bsp tree 
func _generate(_width: int, _height: int, _iterations: int) -> Array:
	# generate level data with a binary tree
	var l_tree: Array
	var iterations_done = 0
	for i:int in range(_iterations):
		var number_created = 0
		l_tree.append([] as Array[BspNode])
		
		# create root node 
		if i == 0:
			var root = BspNode.new(Vector2i(0,0), _width, _height)
			l_tree[i].append(root)
			number_created += 1
			
		# create child nodes for the parents on the upper level and add them on the current level
		else:
			var children: Array
			for node: BspNode in l_tree[i-1]:
				var child_candidates = node._create_children()
				# skip bad children
				if (child_candidates == null) or (child_candidates.size() == 0) :
					push_error("Failed generating children for 1 parent. Skipping...")
					continue
				children.append_array(child_candidates)
				number_created += 2
			l_tree[i].append_array(children)
		iterations_done += 1
		print_debug("Created "+str(number_created)+" nodes on BSP tree level: "+str(i))
	print_debug("Created a total of "+str(iterations_done)+" levels on BSP tree")
	
	# Shrink sides of each bsp node to introduce roads in between
	for _node: BspNode in l_tree[l_tree.size()-1]:
		# prevent cutting from sides on map edges
		var can_cut_left = (_node.position.x > 0) 
		var can_cut_right = (_node.position.x + _node.width) < _width
		var can_cut_up = (_node.position.y + _node.height) < _height
		var can_cut_down = (_node.position.y > 0)
		if can_cut_left:
			_node.cut_side(BspNode.side.Left, 1)
		if can_cut_right:
			_node.cut_side(BspNode.side.Right, 1)
		if can_cut_up:
			_node.cut_side(BspNode.side.Up, 1)
		if can_cut_down:
			_node.cut_side(BspNode.side.Down, 1)
	return l_tree

## Generates a road grid from a level grid [br]
## Format: Array[Array[bool]], where arrays represent grid positions and booleans represent roads. True == road
func generate_road_grid(_level_tree: Array) -> Array[Array]:
	var _road_grid: Array[Array] = []
	# figure out size of the level - bsp tree root node tells us that info
	var _level_root_node: BspNode = _level_tree[0][0]
	var _level_width: int = _level_root_node.width
	var _level_height: int = _level_root_node.height
	# prepare grid with all tiles as road
	var _row_template: Array[bool] = []
	_row_template.resize(_level_width)
	_row_template.fill(true)
	_road_grid.resize(_level_height)
	for i in range(_level_height):
		_road_grid[i] = _row_template.duplicate(true)
	# unmark tiles with bsp nodes as roads, so only roads are left true
	for _nd: BspNode in _level_tree[(_level_tree.size()-1)]:
		for _y in range(_nd.position.y, (_nd.position.y + _nd.height)):
			for _x in range(_nd.position.x, (_nd.position.x + _nd.width)):
				_road_grid[_y][_x] = false
	return _road_grid

## Generates a grid representing all bsp nodes in the level. [br]
## Format: Array[Array[int]], where arrays represent grid positions and integers represent index of each node. [br]
## 0 == NO NODE		[br]
## 1 == node n.1	[br]
## 2 == node n.2	[br]
## Check out example below: [br]
## 1 1 2 2			[br]
## 1 1 2 2			[br]
## 3 3 2 2			[br]
## 3 3 0 0
func generate_node_grid(_level_tree: Array) -> Array[Array]:
	var _node_grid: Array[Array] = []
	# figure out size of the level - bsp tree root node tells us that info
	var _level_root_node: BspNode = _level_tree[0][0]
	var _level_width: int = _level_root_node.width
	var _level_height: int = _level_root_node.height
	# prepare grid with all tiles marked as non-nodes, i.e. 0
	var _row_template: Array[int] = []
	_row_template.resize(_level_width)
	_row_template.fill(0)
	_node_grid.resize(_level_height)
	for y in range(_level_height): 
		_node_grid[y] = _row_template.duplicate(true)
	# mark tiles with bsp nodes - 1, 2, 3, etc...
	var _node_index: int = 1
	for _nd: BspNode in _level_tree[(_level_tree.size()-1)]:
		for _y in range(_nd.position.y, (_nd.position.y + _nd.height)):
			for _x in range(_nd.position.x, (_nd.position.x + _nd.width)):
				_node_grid[_y][_x] = _node_index
		_node_index += 1
	return _node_grid
