class_name Tunneler2D
extends RefCounted

enum move_direction {N, S, E, W}

var _bounds_min : Vector2i
var _bounds_max : Vector2i

var position : Vector2i

var tunneled : Array[Vector2i]

static var directions : Dictionary[move_direction, Vector2i] = {
	move_direction.N: Vector2i(0, -1),
	move_direction.S: Vector2i(0, 1),
	move_direction.E: Vector2i(1, 0),
	move_direction.W: Vector2i(-1, 0),
}

## bounds.x = min & bounds.y = max
func run(start_cell : Vector2i, max_steps : int, start_dir : move_direction, bounds_min : Vector2i, bounds_max : Vector2i, prevent_out_of_bounds : bool = true, change_direction_odds_percentage : float = 100.0) -> Array[Vector2i]:
	_bounds_min = bounds_min
	_bounds_max = bounds_max

	tunneled = []

	position = start_cell
	tunneled.append(position)

	var last_move_dir : move_direction = start_dir

	for i in range(max_steps):
		# decide whether to pick new direction or stay on same course
		var pick_new_direction = false
		if change_direction_odds_percentage > 0.0:
			pick_new_direction = OmegaUtils.roll_percentage_odds(change_direction_odds_percentage)

		var move_dir : move_direction

		if pick_new_direction:
			var accessible : Array[move_direction] = _get_accessible_directions(prevent_out_of_bounds)
			
			if accessible.is_empty():
				print_debug("all directions inaccessible")
				print_debug("tunneling ended prematurely")
				break

			move_dir = accessible.pick_random()
			print_debug("changed move direction")
		else:
			move_dir = last_move_dir

		if i == 0: # first step  -> try to move in user-requested direction
			var cell_in_requested_start_direction = position + directions[start_dir]
			if _inside_bounds(cell_in_requested_start_direction):
				move_dir = start_dir
			else: 
				print_debug("cell in requested start direction is inaccessible")
				print_debug("tunneling ended prematurely")
				break

		# stop before going out of bounds 
		var new_pos = position + directions[move_dir]
		if not _inside_bounds(new_pos):
			print_debug("tunneling ended prematurely to prevent going out of bounds")
			break

		position = new_pos
		tunneled.append(position)
		print("Tunneled in direction: %s" % [move_direction.keys()[move_dir]])
		last_move_dir = move_dir
	
	print("tunneler  tunneled %s steps out of %s requested." % [tunneled.size(), max_steps])
	return tunneled

func _get_cell_in_dir(direction : move_direction) -> Vector2i:
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

func _get_accessible_directions(_prevent_out_of_bounds = true) -> Array[move_direction]:
	# prevent going in certain directions - inaccessible etc.
	var possible_directions : Array[move_direction] = [
		move_direction.N,
		move_direction.S,
		move_direction.E,
		move_direction.W,
	]

	var inaccessible_directions = []
	for dir : move_direction in possible_directions:
		var offset : Vector2i = directions[dir]
		var cell_in_dir = position + offset

		# prevent going out of bounds
		if _prevent_out_of_bounds:
			if not _inside_bounds(cell_in_dir):
				inaccessible_directions.append(dir)
				continue

		# prevent walking over the same path twice - ? ? optional ? 
		if tunneled.has(cell_in_dir):
			inaccessible_directions.append(dir)
			continue

	for dir in inaccessible_directions:
		possible_directions.erase(dir)

	return possible_directions

func _inside_bounds(cell : Vector2i) -> bool:
	if cell.x < _bounds_min.x or cell.y < _bounds_min.y:
		return false
	if cell.x > _bounds_max.x or cell.y > _bounds_max.y:
		return false
	return true
