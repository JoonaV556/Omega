class_name QuadTree
extends RefCounted

var children: Array[QuadTree] = []

func divide() -> Array[QuadTree]:

	children = []

	for c in range(4):
		var new_c: QuadTree = QuadTree.new()
		children.append(new_c)
	
	# print_debug("divided QuadTree")
	return children


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
	print_debug("division finished. result is  "+str(leaves.size())+" leaf quads")


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


func is_leaf() -> bool:
	return children.is_empty()
