class_name QuadTree2D
extends QuadTree 

## Size in individual cells, i.e. the smallest leaf quads in the tree [br]
## example: If tree is divided uniformly by 3 iterations, the result is an 8x8 sized array of cells.  
var size : Vector2i = Vector2i.ZERO

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
	c.size = size / 2
	c.position = self.position

	c = children[1]
	c.size = size / 2
	c.position = self.position + Vector2i(c.size.x, 0)

	c = children[2]
	c.size = size / 2
	c.position = self.position + Vector2i(0, c.size.y)

	c = children[3]
	c.size = size / 2
	c.position = self.position + Vector2i(c.size.x, c.size.y)

	# print_debug("divided QuadTree")
	return children


func divide_recursive(iterations : int = 1):
	_div_iterations = iterations
	var width = 2 ** iterations
	size = Vector2i(width, width)
	position = Vector2i.ZERO
	super(iterations)


func get_quad_side_size_on_tree_level(level : int) -> Vector2i:
	var qs : Array[QuadTree] = get_level(level)
	var q = qs[0] as QuadTree2D
	return q.size


func get_level_width_in_cells(level : int) -> int:
	var cell_count : int = int(pow(4, _div_iterations))
	return int(sqrt(cell_count))
