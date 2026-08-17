class_name QuadTree2D
extends QuadTree 

## Size in tilemap tiles
var size_in_tiles : Vector2i = Vector2i.ZERO

## Position of the quad cell relative to its tree parent. If this quad is the tree origin, position is 0,0
var position : Vector2i = Vector2i.ZERO

var _div_iterations : int

func divide() -> Array[QuadTree]:

	children = []

	for c in range(4):
		var new_c: QuadTree2D = QuadTree2D.new()
		new_c.parent = self
		children.append(new_c)

	# assign sizes and positions to child quads
	var c : QuadTree2D

	c = children[0]
	c.size_in_tiles = size_in_tiles / 2
	c.position = self.position

	c = children[1]
	c.size_in_tiles = size_in_tiles / 2
	c.position = self.position + Vector2i(c.size_in_tiles.x, 0)

	c = children[2]
	c.size_in_tiles = size_in_tiles / 2
	c.position = self.position + Vector2i(0, c.size_in_tiles.y)

	c = children[3]
	c.size_in_tiles = size_in_tiles / 2
	c.position = self.position + Vector2i(c.size_in_tiles.x, c.size_in_tiles.y)

	# print_debug("divided QuadTree")
	return children

## Recursively divides the quadtree into smaller quads. 1 Iteration results in 4 leaf quads
func divide_recursive(iterations : int = 1):
	_div_iterations = iterations
	var width = 2 ** iterations
	size_in_tiles = Vector2i(width, width)
	position = Vector2i.ZERO
	super(iterations)


func get_quad_side_size_on_tree_level(level : int) -> Vector2i:
	var qs : Array[QuadTree] = get_level(level)
	var q = qs[0] as QuadTree2D
	return q.size_in_tiles


func get_level_width_in_cells(level : int) -> int:
	var cell_count : int = int(pow(4, _div_iterations))
	return int(sqrt(cell_count))
