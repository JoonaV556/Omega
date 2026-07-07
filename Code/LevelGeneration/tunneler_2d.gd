class_name Tunneler2D
extends RefCounted

enum move_direction {N, S, E, W}

var _bounds_min : Vector2i
var _bounds_max : Vector2i

var position

## bounds.x = min & bounds.y = max
func run(start_cell : Vector2i, max_steps : int, start_dir : move_direction, bounds_min : Vector2i, bounds_max : Vector2i) -> Array[Vector2i]:
	_bounds_min = bounds_min
	_bounds_max = bounds_max

	var walked : Array[Vector2i] = []

	position = start_cell
	walked.append(position)
	
	var rng = RandomNumberGenerator.new()

	for i in range(max_steps):
		# prevent going in directions which lead out of bounds
		var cell_n = position + Vector2i(0, -1)
		var cell_s = position + Vector2i(0, 1)
		var cell_e = position + Vector2i(1, 0)
		var cell_w = position + Vector2i(-1, 0)
		var cells_in_directions = [cell_n, cell_s, cell_e, cell_w]

		var inaccessible = []
		for cell : Vector2i in cells_in_directions:
			if not inside_bounds(cell):
				inaccessible.append(cell)
				continue

		for c in inaccessible:
			cells_in_directions.erase(c)

		# nowhere to go anymore
		if cells_in_directions.is_empty():
			return walked
		
		# move
		var new_pos

		if i == 0: # first step  -> try to move in user-requested direction
			var cell_in_requested_start_direction = get_cell_in_dir(start_dir)
			if inside_bounds(cell_in_requested_start_direction):
				new_pos = cell_in_requested_start_direction
			else: 
				return []
		else:
			new_pos = cells_in_directions.pick_random()
		
		position = new_pos
		walked.append(position)
	
	return walked

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