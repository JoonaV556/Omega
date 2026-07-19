class_name Tunneler2D
extends RefCounted

enum move_direction {none, N, S, E, W}

var _bounds_min : Vector2i
var _bounds_max : Vector2i

var position : Vector2i

var tunneled_cells : Array[Vector2i]


const directions : Dictionary[move_direction, Vector2i] = {
	move_direction.N: Vector2i(0, -1),
	move_direction.S: Vector2i(0, 1),
	move_direction.E: Vector2i(1, 0),
	move_direction.W: Vector2i(-1, 0),
}


static var possible_directions : Array[move_direction] = [
	move_direction.N,
	move_direction.S,
	move_direction.E,
	move_direction.W,
]


static var directions_perpendicular : Dictionary[move_direction, Array] = {
	move_direction.N: [move_direction.E, move_direction.W],
	move_direction.S: [move_direction.E, move_direction.W],
	move_direction.E: [move_direction.N, move_direction.S],
	move_direction.W: [move_direction.N, move_direction.S],
}


static func branching_river(st : BranchingRiver2DSettings) -> Array[Vector2i]:
	var river_cells : Array[Vector2i] = []

	# pick direction of river flow
	var _direction : move_direction = st.direction
	if st.direction == move_direction.none:
		var p_dirs : Array[move_direction] = [
			move_direction.N,
			move_direction.S,
			move_direction.E,
			move_direction.W, 
		]
		_direction = p_dirs.pick_random()
	
	# pick river start cell from along the correct starting edge
	var start_cell : Vector2i = Vector2i(0,0)
	match _direction:
		move_direction.N: # starting from south
			var x = OmegaUtils.randi_between_values_n(st.bounds_min.x, st.bounds_max.x)
			start_cell = Vector2i(x, st.bounds_max.y)
		move_direction.S: # starting from north
			var x = OmegaUtils.randi_between_values_n(st.bounds_min.x, st.bounds_max.x)
			start_cell = Vector2i(x, st.bounds_min.y)
		move_direction.E: # starting from west
			var y = OmegaUtils.randi_between_values_n(st.bounds_min.y, st.bounds_max.y)
			start_cell = Vector2i(st.bounds_min.x, y)
		move_direction.W: # starting from east
			var y = OmegaUtils.randi_between_values_n(st.bounds_min.y, st.bounds_max.y)
			start_cell = Vector2i(st.bounds_max.x, y)

	river_cells.append(start_cell)

	var last_branch_length : int 

	# carve the river branches
	for i in range(st.max_branches + 1):
		# carve first branch as straight line
		if i == 0:
			var length = abs(st.bounds_min.x - st.bounds_max.x) + 1
			river_cells.append_array(
				Tunneler2D.draw_line(
					start_cell,
					_direction,
					length
				)
			)
			last_branch_length = length
			print("river root start cell: %s " % [start_cell])
			print("root branch length: %s " % [length])
			continue

		# ----> carve branch
		# pick branch starting point 
		var _s_cells : Array[Vector2i] = river_cells.slice(
			-last_branch_length,
			river_cells.size(),
		)
		var s_point : Vector2i= OmegaUtils.pick_random_normalized(_s_cells)

		# pick branch split direction
		var s_dir = directions_perpendicular[_direction].pick_random()

		# Carve l-shaped branch
		var bounds : Array = [3, st.bounds_max.x / 2]
		var split_segment_length = randi_range(bounds.min(), bounds.max())

		var back_length
		match _direction:
			move_direction.N:
				back_length = s_point.y + 1
			move_direction.S:
				back_length = (st.bounds_max.y + 1) - s_point.y
			move_direction.E:
				back_length = (st.bounds_max.x + 1) - s_point.x
			move_direction.W:
				back_length = s_point.x + 1

		river_cells.append_array(
			draw_l(
				s_point,
				s_dir,
				_direction,
				split_segment_length,
				back_length
			)
		)

		print("branch start cell: %s " % [s_point])
		print("branch root length: %s \nbranch back length: %s " % [split_segment_length, back_length])

	print("river direction: %s " % [move_direction.keys()[_direction]])

	return river_cells


static func draw_l(start_cell : Vector2i, first_line_dir : move_direction, second_line_dir : move_direction, root_length : int, back_length : int) -> Array[Vector2i]:
	# choose dir, randomize if no directions given
	var f_dir = first_line_dir
	if first_line_dir == move_direction.none:
		f_dir = possible_directions.pick_random()
	var s_dir = second_line_dir
	if second_line_dir == move_direction.none:
		s_dir = possible_directions.pick_random()
		pass

	# draw first line (root)
	var cells : Array[Vector2i] = draw_line(start_cell, f_dir, root_length)

	# draw second line (back)
	var s_line_f_cell = cells[-1] + directions[second_line_dir]
	cells.append_array(draw_line(s_line_f_cell, s_dir, back_length-1))
	
	return cells


static func draw_line(start_cell : Vector2i, _direction : move_direction, length) -> Array[Vector2i]:
	var _cells : Array[Vector2i] = []
	var cell = start_cell

	for i in range(length):	
		_cells.append(cell)
		cell = cell + directions[_direction]

	return _cells
	

func simple_tunnel(st : Tunneler2DSettings) -> Array[Vector2i]:
	var steps_after_last_turn = 0
	var turned_count = 0

	tunneled_cells = []

	if not _inside_bounds(st.start_cell, st.bounds_min, st.bounds_max):
		return tunneled_cells
	
	tunneled_cells.append(st.start_cell)
	position = st.start_cell

	var last_move_dir : move_direction = st.initial_direction

	for i in range(st.max_steps):
		var move_dir : move_direction = last_move_dir

		# prevent turning while on edge
		var on_edge : bool = false

		if !st.allow_turning_on_edges:
			on_edge = (position.x == st.bounds_min.x) or (position.y == st.bounds_min.y) or (position.x == st.bounds_max.x) or (position.y == st.bounds_max.y)

		var can_turn = (steps_after_last_turn >= st.min_steps_between_turns) and (turned_count < st.max_turns) and (not on_edge)

		if can_turn:

			var turn : bool = OmegaUtils.roll_percentage_odds(st.turn_odds_percentage)

			if turn:
				steps_after_last_turn = 0
				move_dir = directions_perpendicular[last_move_dir].pick_random()
				turned_count += 1

		# stop if next cell is out of bounds
		var new_pos = position + directions[move_dir]
		if not _inside_bounds(new_pos, st.bounds_min, st.bounds_max):
			break

		position = new_pos
		steps_after_last_turn += 1
		last_move_dir = move_dir
		tunneled_cells.append(position)

		# print("Tunneled in direction: %s" % [move_direction.keys()[move_dir]])

	print("tunneler  tunneled %s steps out of %s requested." % [tunneled_cells.size(), st.max_steps])
	return tunneled_cells

## this is poo, pretty much a true random walk. use simple_tunnel instead
func run(start_cell : Vector2i, max_steps : int, start_dir : move_direction, bounds_min : Vector2i, bounds_max : Vector2i, prevent_out_of_bounds : bool = true, change_direction_odds_percentage : float = 100.0) -> Array[Vector2i]:
	_bounds_min = bounds_min
	_bounds_max = bounds_max

	tunneled_cells = []

	position = start_cell
	tunneled_cells.append(position)

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
				print("tunneling ended prematurely")
				break

			move_dir = accessible.pick_random()
			print("changed move direction")
		else:
			move_dir = last_move_dir

		if i == 0: # first step  -> try to move in user-requested direction
			var cell_in_requested_start_direction = position + directions[start_dir]
			if _inside_bounds(cell_in_requested_start_direction, bounds_min, bounds_max):
				move_dir = start_dir
			else: 
				print_debug("cell in requested start direction is inaccessible")
				print("tunneling ended prematurely")
				break

		# stop before going out of bounds 
		var new_pos = position + directions[move_dir]
		if not _inside_bounds(new_pos, bounds_min, bounds_max):
			print_debug("tunneling ended prematurely to prevent going out of bounds")
			break

		position = new_pos
		tunneled_cells.append(position)
		print("Tunneled in direction: %s" % [move_direction.keys()[move_dir]])
		last_move_dir = move_dir
	
	print("tunneler  tunneled_cells %s steps out of %s requested." % [tunneled_cells.size(), max_steps])
	return tunneled_cells

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
	var _possible_directions : Array[move_direction] = [
		move_direction.N,
		move_direction.S,
		move_direction.E,
		move_direction.W,
	]

	var inaccessible_directions = []
	for dir : move_direction in _possible_directions:
		var offset : Vector2i = directions[dir]
		var cell_in_dir = position + offset

		# prevent walking over the same path twice - ? ? optional ? 
		if tunneled_cells.has(cell_in_dir):
			inaccessible_directions.append(dir)
			continue

	for dir in inaccessible_directions:
		_possible_directions.erase(dir)

	return _possible_directions

## bounds inclusive [br]
## min = 0, max = 10, values 0 and 10 are considered inside, but -1 and 11 outside
func _inside_bounds(cell : Vector2i, bounds_min, bounds_max) -> bool:
	if cell.x < bounds_min.x or cell.y < bounds_min.y:
		return false
	if cell.x > bounds_max.x or cell.y > bounds_max.y:
		return false
	return true
