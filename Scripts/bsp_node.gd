class_name BspNode

var position: 	Vector2i
var width: 		int
var height: 	int
var parent: 	BspNode
var children: 	Array

func _init(_position, _width, _height):
	self.position 	= _position
	self.width 		= _width
	self.height 	= _height
	
## Creates a pair of children for this node and returns them in an array
## Returns an empty array if the parent is too small to be split in half in the first place
func _create_children() -> Array[BspNode]:
	# prevent generating if we are a too small to be split in half
	var new_children: Array[BspNode] 
	if (self.width < 2) or (self.height < 2):
		push_error("BSP parent too small to be split into children!")
		return new_children
	
	# pick cut angle 0 = hor, 1 = vertical
	var cut_ang: int
	var rng = RandomNumberGenerator.new()
	# always cut longer side if shorter side is 1
	var other_taller = (width <= 1 and height > 1)
	var other_wider = (height <= 1 and width > 1)
	if other_taller or other_wider:
		if other_taller:
			cut_ang = 0
		else:
			cut_ang = 1
	else:
		cut_ang = rng.randi_range(0,1)
	
	# pick cut position and size children based on cut
	var cut_pos
	# first kid
	var c1_position
	var c1_width
	var c1_height
	# 2nd kid
	var c2_position
	var c2_width
	var c2_height
	# pick cut position and size children based on cut
	if cut_ang == 0:	# cut on y-axis (horizontal cut)
		cut_pos = rng.randi_range(self.position.y + 1, self.position.y + self.height - 2) # weird range is to prevent cuts too close to parents edges
		c1_position = 	self.position
		c1_width  = 	self.width
		c1_height = 	cut_pos - self.position.y
		c2_position = 	Vector2i(self.position.x, cut_pos)
		c2_width = 		self.width
		c2_height = 	self.height - c1_height
	else:				# cut on x-axis (vertical cut)
		cut_pos = rng.randi_range(self.position.x + 1, self.position.x + self.width - 2)
		c1_position = 	self.position
		c1_width = 		cut_pos - self.position.x
		c1_height = 	self.height
		c2_position = 	Vector2i(cut_pos, self.position.y)
		c2_width = 		self.width - c1_width
		c2_height = 	self.height	
	
	if (c1_height <= 0) or (c1_width <= 0) or (c2_height <= 0) or (c2_width <= 0):
		print("alert")
	
	var node_1 = BspNode.new(c1_position, c1_width, c1_height)
	node_1.parent = self
	var node_2 = BspNode.new(c2_position, c2_width, c2_height)
	node_2.parent = self
	
	new_children.append(node_1)
	new_children.append(node_2)
	self.children.append(new_children)
	return new_children
