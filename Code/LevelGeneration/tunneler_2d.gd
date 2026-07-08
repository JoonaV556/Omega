class_name Tunneler2D
extends RefCounted

enum move_direction {N, S, E, W}

var _bounds_min : Vector2i
var _bounds_max : Vector2i

var position : Vector2i

var directions : Dictionary[move_direction, Vector2i] = {
	move_direction.N: Vector2i(0, -1),
	move_direction.S: Vector2i(0, 1),
	move_direction.E: Vector2i(1, 0),
	move_direction.W: Vector2i(-1, 0),
}


## bounds.x = min & bounds.y = max
func run(start_cell : Vector2i, max_steps : int, start_dir : move_direction, bounds_min : Vector2i, bounds_max : Vector2i) -> Array[Vector2i]:
	_bounds_min = bounds_min
	_bounds_max = bounds_max

	var tunneled : Array[Vector2i] = []

	position = start_cell
	tunneled.append(position)
	
	var rng = RandomNumberGenerator.new()

	for i in range(max_steps):
		# prevent going in directions which lead out of bounds
		var cell_n = position + Vector2i(0, -1)
		var cell_s = position + Vector2i(0, 1)
		var cell_e = position + Vector2i(1, 0)
		var cell_w = position + Vector2i(-1, 0)
		var cells_in_directions = [cell_n, cell_s, cell_e, cell_w]

		var possible_directions = [
			move_direction.N,
			move_direction.S,
			move_direction.E,
			move_direction.W,
		]

		var inaccessible_directions = []
		for dir : move_direction in possible_directions:
			var offset : Vector2i = directions[dir]
			var cell_in_dir = position + offset
			if not inside_bounds(cell_in_dir):
				inaccessible_directions.append(dir)
				continue
			# prevent walking over the same path twice - ? ? optional ? 
			if tunneled.has(cell_in_dir):
				inaccessible_directions.append(dir)
				continue

		for dir in inaccessible_directions:
			possible_directions.erase(dir)

		# nowhere to go anymore
		if possible_directions.is_empty():
			print_debug("tunneling ended prematurely")
			break
		
		# move
		var move_dir : move_direction

		if i == 0: # first step  -> try to move in user-requested direction
			var cell_in_requested_start_direction = position + directions[start_dir]
			if inside_bounds(cell_in_requested_start_direction):
				move_dir = start_dir
			else: 
				print_debug("cell in requested start direction is inaccessible")
				print_debug("tunneling ended prematurely")
				break
		else:
			move_dir = possible_directions.pick_random()			
		
		position = position + directions[move_dir]
		tunneled.append(position)
		print("Tunneled in direction: %s" % [move_direction.keys()[move_dir]])
	
	print("tunneler  tunneled %s steps out of %s requested." % [tunneled.size()-1, max_steps])
	return tunneled

func get_cell_in_dir(direction : move_direction) -> Vector2i:
	match direction:
		0: # N 
			return position + Vector2i(0, -1)
		1: # S
			return position + Vector2i(0, 1)
		2: # E 
			return position + Vector2i(1, 0)
		3: # W
			return position +Vector2i(-1, 0)
	
	return Vector2i.ZERO

func inside_bounds(cell : Vector2i) -> bool:
	if cell.x < _bounds_min.x or cell.y < _bounds_min.y:
		return false
	if cell.x > _bounds_max.x or cell.y > _bounds_max.y:
		return false
	return true