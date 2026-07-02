class_name QuadTree2D
extends QuadTree 

## Size in individual cells, i.e. the smallest leaf quads in the tree [br]
## example: If tree is divided uniformly by 3 iterations, the result is an 8x8 array of cells.  
var size : Vector2i = Vector2i.ZERO

## Position of the quad cell relative to its tree parent. If this quad is the tree origin, position is 0,0
var position : Vector2i

func divide() -> Array[QuadTree]:

	children = []

	for c in range(4):
		var new_c: QuadTree2D = QuadTree2D.new()
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
	var width = 2 ** iterations
	size = Vector2i(width, width)
	position = Vector2i.ZERO
	super(iterations)
