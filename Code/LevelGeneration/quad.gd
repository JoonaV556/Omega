class_name QuadTree
extends RefCounted

var children: Array[QuadTree] = []


func divide() -> Array[QuadTree]:

	children = []

	for c in range(4):
		var new_c: QuadTree = QuadTree.new()
		children.append(new_c)
	
	print_debug("divided QuadTree")
	return children


func divide_recursive(iterations : int = 1):
	if iterations <= 0:
		return
   
	print_debug("dividing QuadTree with "+str(iterations)+" iterations")
	var cn : Array[QuadTree] = self.divide()
	iterations -= 1

	for i in range(iterations):
	   
		var add : Array[QuadTree] = []
	   
		for c in cn:
			add.append_array(c.divide())

		cn = add


func is_leaf() -> bool:
	return children.is_empty()
