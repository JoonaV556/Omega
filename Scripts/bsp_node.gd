class_name BspNode

var position: 	Vector2i
var width: 		int
var height: 	int
var parent: 	BspNode
var children: 	Array

enum side {Left, Right, Up, Down}

func _init(_position, _width, _height):
	self.position 	= _position
	self.width 		= _width
	self.height 	= _height

## Cuts off specified amount of tiles from specified side of node
func cut_side(_side: side, cut_amount: int = 0):
	match _side:
		side.Left:
			if (self.width - cut_amount) > 2:
				self.width -= cut_amount
				self.position = Vector2i(self.position.x + 1, self.position.y)
		side.Right:
			if (self.width - cut_amount) > 2:
				self.width -= cut_amount
		side.Up:
			if (self.height - cut_amount) > 2:
				self.height -= cut_amount
		side.Down:
			if (self.height - cut_amount) > 2:
				self.height -= cut_amount
				self.position = Vector2i(self.position.x, self.position.y + 1)
	
## Creates a pair of children for this node and returns them in an array
## Returns an empty array if the parent is too small to be split in half in the first place
func _create_children() -> Array[BspNode]:
	# prevent generating if we are a too small to be split in half
	var new_children: Array[BspNode] 
	if (self.width < 2) and (self.height < 2):
		push_error("BSP parent too small to be split into children!")
		return new_children
	
	# pick cut angle 0 = hor, 1 = vertical
	var cut_ang: int
	var rng = RandomNumberGenerator.new()
	# pick cut angle
	if self.width == self.height:
		cut_ang = rng.randi_range(0,1)
	elif self.width > self.height:
		cut_ang = 1
	else: 
		cut_ang = 0
	
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
		if self.height <= 2:
			# always cut from center if height is only 2
			cut_pos = self.position.y + 1
		else:
			# choose cut pos with normal distribution to prevent crazy results
			var n_mean: 		float = float(self.position.y) + float(self.height / 2.0)
			var n_deviation: 	float = float((self.height / 2.0) / 3.0) # 99% of values are within 3 standard deviations. So 1/3 of 1/2 of our height gives an appropriate deviation
			# clamp the random in acceptable range
			# weird range is to prevent cuts too close to parents edges
			cut_pos = int(clampf(
				rng.randfn(n_mean, n_deviation),
				self.position.y + 1,
				self.position.y + self.height - 2
				))
		c1_position = 	self.position
		c1_width  = 	self.width
		c1_height = 	cut_pos - self.position.y
		c2_position = 	Vector2i(self.position.x, cut_pos)
		c2_width = 		self.width
		c2_height = 	self.height - c1_height
	else:				# cut on x-axis (vertical cut)
		if self.width <= 2:
			# always cut from middle if width is only 2
			cut_pos = self.position.x + 1 
		else:
			# choose cut pos with normal distribution to prevent crazy results
			var n_mean: 		float = float(self.position.x) + float(self.width / 2.0)
			var n_deviation: 	float = float((self.width / 2.0) / 3.0) # 99% of values are within 3 standard deviations. So 1/3 of 1/2 of our height gives an appropriate deviation
			# clamp the random in acceptable range
			# weird range is to prevent cuts too close to parents edges
			cut_pos = int(clampf(
				rng.randfn(n_mean, n_deviation),
				self.position.x + 1,
				self.position.x + self.width - 2
				))
		c1_position = 	self.position
		c1_width = 		cut_pos - self.position.x
		c1_height = 	self.height
		c2_position = 	Vector2i(cut_pos, self.position.y)
		c2_width = 		self.width - c1_width
		c2_height = 	self.height	
	
	if (c1_height <= 0) or (c1_width <= 0) or (c2_height <= 0) or (c2_width <= 0):
		print_debug("alert")
	
	var node_1 = BspNode.new(c1_position, c1_width, c1_height)
	node_1.parent = self
	var node_2 = BspNode.new(c2_position, c2_width, c2_height)
	node_2.parent = self
	
	new_children.append(node_1)
	new_children.append(node_2)
	self.children.append(new_children)
	return new_children
