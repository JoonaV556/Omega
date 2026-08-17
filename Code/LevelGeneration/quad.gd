class_name QuadTree
extends RefCounted

var children: Array[QuadTree] = []

var parent : QuadTree

func divide() -> Array[QuadTree]:

	children = []

	for c in range(4):
		var new_c: QuadTree = QuadTree.new()
		new_c.parent = self
		children.append(new_c)
	
	# print_debug("divided QuadTree")
	return children

## Recursively divides the quadtree into smaller quads. 1 Iteration results in 4 leaf quads
func divide_recursive(iterations : int = 1):
	if iterations <= 0:
		return

	print_debug("dividing QuadTree with "+str(iterations)+" iterations")
	var cn : Array[QuadTree] = self.divide()

	for i in range(iterations - 1):
	   
		var add : Array[QuadTree] = []
	   
		for c in cn:
			add.append_array(c.divide())

		cn = add

	var leaves = self.get_leaves()
	print_debug("division finished. result is  "+str(leaves.size())+" leaf quads on "+str(self.get_levels())+" levels.")


func get_leaves() -> Array[QuadTree]:
	var leaves: Array[QuadTree] = []
	if self.is_leaf():
		leaves.append(self)
		return leaves

	var _children: Array[QuadTree] = self.children
	
	while true:
		var nxt_children : Array[QuadTree] =  []
		
		for c : QuadTree in _children:
			if c.is_leaf():
				leaves.append(c)
			else:
				nxt_children.append_array(c.children)
		
		if nxt_children.is_empty():
			break
		else:
			_children = nxt_children
			
	return leaves

## Returns Quadtree quads at requested tree level. Return empty array if no quads at requested level, [br]
## get_level(0) = [self]								[br]
## get_level(1) = [self.children]						[br]
## get_level(2) = [children of self.children] 			[br]
## get_level(3) = [etc...]								[br]
func get_level(level : int = 0) -> Array[QuadTree]:
	if level == 0:
		return [self]

	var parents : Array[QuadTree] = [self]

	for i in range(1, level + 1):

		var _children : Array[QuadTree] = []	
		for p in parents:
			_children.append_array(p.children)

		if _children.is_empty():
			break
		
		if i == level:
			return _children

		parents = _children
	
	return []


func get_levels() -> int:
	var levels = 1

	var parents : Array[QuadTree] = [self]

	while true:
		var _children : Array[QuadTree] = []
		for p in parents:
			_children.append_array(p.children)
		
		if _children.is_empty():
			return levels

		parents = _children
		levels += 1

	return -1


func trim_leaves():
	for c in children:
		c.parent = null
	children.clear()


func is_leaf() -> bool:
	return children.is_empty()
