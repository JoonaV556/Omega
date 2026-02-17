extends Node
## Provides functions for generating and drawing procedural levels on tilemaps
class_name LevelGenerator

@export 
var enable_automatic_bulk_generation: bool = true # if true, level is generated and drawn on first update
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

@export_subgroup("Debug")
@export_range(2, 99)
var bulk_generate_count: int = 0

var tmap		: TileMapLayer
var first_update = true
var level		: Array 		= [[]] # two dim array
var g_ready_to_generate: bool = false

func _process(_delta: float) -> void:
	if first_update:
		first_update = false
		g_ready_to_generate = true
		if enable_automatic_bulk_generation:
			bulk_generate_and_draw()

## draws a level on a new tilemap
func draw_level(_level: Level):
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
	
	# Draw level on tilemap
	for _y in range(-1, -(self.height-1), -1):
		for _x in range(self.width):
			# draw road
			if _level.road_grid[_y][_x] == true:
				
				tmap.set_cell(Vector2i(_x, _y), 0, roadcoords)
			# draw node
			if _level.node_grid[_y][_x] != 0:
				tmap.set_cell(Vector2i(_x, _y), 0, groundcoords)

func bulk_generate_and_draw() -> bool:
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
	
	# generate and draw levels in bulk
	var num_generated: int = 0
	for i in range(bulk_generate_count):
		# generate level
		var _level: Level = generate_level(self.width, self.height, self.bsp_tree_iterations)
		# Draw level on tilemap
		for _y in range(-1, -(self.height-1), -1):
			for _x in range(self.width):
				# draw road
				if _level.road_grid[_y][_x] == true:
					tmap.set_cell(Vector2i(_x + (num_generated * self.width), _y), 0, roadcoords)
				# draw node
				if _level.node_grid[_y][_x] != 0:
					tmap.set_cell(Vector2i(_x + (num_generated * self.width), _y), 0, groundcoords)
		num_generated += 1
	return true

## generates a level
func generate_level(_width: int = 100, _height: int = 200, _bsp_divide_iterations: int = 6) ->  Level:
	var _level = _generate(_width, _height, _bsp_divide_iterations)
	var _roads: Array[Array] = generate_road_grid(_level)
	var _nodes: Array[Array] = generate_node_grid(_level)
	return Level.new(_roads, _nodes)

## Makes a level vertically traversible from south->north by cutting a way through
func make_vertically_traversable(_level: Array[Array]):
	var _bad_nodes: Array[BspNode] 	= []
	# check if the level is traversible
	for _node: BspNode in _level[-1]:
		var _level_root_width: int = _level[0][0].width
		if _node.width >= _level_root_width:
			push_warning("non-vertically traversable node detected!")
			_bad_nodes.append(_node)
	# cut through non-traversible parts by splitting bad nodes
	for _bad_node: BspNode in _bad_nodes:
		_level[-1].erase(_bad_node)
		_level[-1].append_array(_bad_node._create_children())

## Tries to generate the level, returns the map data as a bsp tree 
func _generate(_width: int, _height: int, _iterations: int, _make_vertically_traversible: bool = true) -> Array:
	# generate level data with a binary tree
	var l_tree: Array[Array]
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
	
	# ensure the level has at least one way through vertically (south->north)
	if _make_vertically_traversible:
		make_vertically_traversable(l_tree)
	
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
func generate_road_grid(_level_tree: Array) -> Array:
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
