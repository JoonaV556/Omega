class_name BspNode

var position: 	Vector2i
var width: 		int
var height: 	int
var parent: 	BspNode
var children: 	Array

func _init(_position, _width, _height):
	self.position 	= position
	self.width 		= width
	self.height 	= height
	
## Creates a pair of children for this node and returns them in an array
func _create_children() -> Array[BspNode]:
	var node_1 = BspNode.new(Vector2i(0,0), 0,0)
	node_1.parent = self
	var node_2 = BspNode.new(Vector2i(0,0), 0,0)
	node_2.parent = self
	var new_children: Array[BspNode] = [node_1, node_2]
	self.children.append(new_children)
	return new_children
