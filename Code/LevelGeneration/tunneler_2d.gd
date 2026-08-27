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


static var direction_opposite: Dictionary[move_direction, move_direction] = {
	move_direction.N: move_direction.S,
	move_direction.S: move_direction.N,
	move_direction.E: move_direction.W,
	move_direction.W: move_direction.E
}

const t_ground : Vector3i = Vector3i(0, 0, 0)
const t_water : Vector3i = Vector3i(0, 0, 0)


static func random_walk(grid_size : Vector2i, max_turns : int = 3, min_walk_length : int = 3, max_branches : int = 0) -> Array[Vector2i]:
	var cells : Array[Vector2i] = []

	# pick start direction
	var s_dir : move_direction = possible_directions.pick_random()
	var _p_dirs = possible_directions.duplicate()
	_p_dirs.erase(direction_opposite[s_dir]) # prevent going backwards the starting dir

	# pick start cell
	var cell = Vector2i.ZERO
	match s_dir:
		move_direction.N: # starting from south
			cell.x = OmegaUtils.randi_between_values_n(0, grid_size.x - 1)
			cell.y = grid_size.y - 1
		move_direction.S: # starting from north
			cell.x = OmegaUtils.randi_between_values_n(0, grid_size.x - 1)
			cell.y = 0
		move_direction.E: # starting from west
			cell.x = 0
			cell.y = OmegaUtils.randi_between_values_n(0, grid_size.y - 1)
		move_direction.W: # starting from east
			cell.x = grid_size.x - 1
			cell.y = OmegaUtils.randi_between_values_n(0, grid_size.y - 1)
	cells.append(cell)
	
	print('start dir: %s, start cell: %s' % [move_direction.keys()[s_dir], cell])

	var last_direction : move_direction = s_dir

	var branch_candidates : Dictionary[Vector2i, move_direction]

	var cease = false

	for i in range(max_turns):
		# Prevent turning along map edges
		var prevent_turning = (i != 0) and (OmegaUtils.is_on_map_edge(cells[-1], grid_size))

		# pick direction
		var dir : move_direction = last_direction
		if i != 0 and !prevent_turning: # Pick new random direction
			var _dirs : Array[move_direction] = _p_dirs.duplicate()
			_dirs.erase(last_direction) # prevent same dir twice in row
			_dirs.erase(direction_opposite[last_direction]) # prevent opposite dirs back to back
			
			dir = _dirs.pick_random() as move_direction
			print('picked new direction: %s' % [move_direction.keys()[dir]])

		# pick walk length
		var length_max = int(0.8 * grid_size.x)
		var w_length : int = randi_range(min_walk_length, length_max)
		if i == (max_turns - 1):
			w_length = 999999999999  # After last turn, keep walking until map edge is reached 

		# walk cells
		for n in range(w_length):
			cell = _get_cell_in_direction(cell, dir)

			# prevent walking outside grid
			if (cell.x < 0) or (cell.x >= grid_size.x) or (cell.y < 0) or (cell.y >= grid_size.y):
				cease = true
				break

			# Mark every other cell as branch starting candidate
			if (max_branches > 0) and ((n%2) != 0):
				branch_candidates[cell] = directions_perpendicular[dir].pick_random()

			cells.append(cell)

		if cease:
			break

		last_direction = dir

	var b_count = 0
	# carve branches
	for i in range(max_branches):
		# pick branch start cell
		var branch_start_cell = OmegaUtils.pick_random_normalized(
			branch_candidates.keys()
		)
		var b_dir = branch_candidates[branch_start_cell]
		branch_candidates.erase(branch_start_cell) # prevent picking same start cell twice
		
		cell = branch_start_cell
		cells.append(branch_start_cell)
		
		# carve branch
		while true:
			cell = _get_cell_in_direction(cell, b_dir)

			# prevent walking outside grid
			if (cell.x < 0) or (cell.x >= grid_size.x) or (cell.y < 0) or (cell.y >= grid_size.y):
				break

			# Carve	
			cells.append(cell)
		b_count += 1
	print('carved %s branches' % [b_count])
	
	print('walk has total: %s cells' % [cells.size()])
	return cells

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
		var rand = clampi(
			int(
				randfn(
					st.bounds_max.x / 2.0,
					(st.bounds_max.x / 2.0) / 3.0
				)
			),
			3, 
			st.bounds_max.x
		)
		# var split_segment_length = randi_range(bounds.min(), bounds.max())
		var split_segment_length = rand

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

		var branch_cells = draw_l(
				s_point,
				s_dir,
				_direction,
				split_segment_length,
				back_length
			)

		# trim any cells outside bounds
		var rm = []
		for cell : Vector2i in branch_cells:
			if (cell.x < st.bounds_min.x) or (cell.x > st.bounds_max.x):
				rm.append(cell)
				continue
			if (cell.y < st.bounds_min.y) or (cell.y > st.bounds_max.y):
				rm.append(cell)
				continue
		for cell in rm:
			branch_cells.erase(cell)
		rm.clear()

		river_cells.append_array(branch_cells)

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

static func _get_cell_in_direction(cell, direction : move_direction) -> Vector2i:
	match direction:
		move_direction.N: # N 
			return cell + Vector2i(0, -1)
		move_direction.S: # S
			return cell + Vector2i(0, 1)
		move_direction.E: # E 
			return cell + Vector2i(1, 0)
		move_direction.W: # W
			return cell +Vector2i(-1, 0)
	
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
