class_name Tunneler2D
extends RefCounted

enum move_direction {N, S, E, W}

## bounds.x = min & bounds.y = max
func run(start_cell : Vector2i, max_steps : int, start_dir : move_direction, bounds_x : Vector2i, bounds_y : Vector2i) -> Array[Vector2i]:
	var walked : Array[Vector2i] = []

	var position = start_cell
	walked.append(position)
	
	var rng = RandomNumberGenerator.new()

	for i in range(max_steps):
		var r_dir : int 
		var move_offset : Vector2i
		
		if i == 0:
			r_dir = start_dir
		else:
			r_dir = rng.randi_range(0, 3)
		
		match r_dir:
			0: # N 
				move_offset = Vector2i(0, -1)
			1: # S
				move_offset = Vector2i(0, 1)
			2: # E 
				move_offset = Vector2i(1, 0)
			3: # W
				move_offset = Vector2i(-1, 0)

		position = position + move_offset

		walked.append(position)
	
	return walked
