class_name OmegaUtils
extends Object

static func roll_percentage_odds(percentage : float = 100.0) -> bool:
	if percentage <	0.0001:
		return false
	if percentage > 99.99:
		return true

	var p_norm = percentage / 100.0
	var rand = randf()
	return rand <= p_norm


static func create_grid(w, h, fill_value = null) -> Array[Array]:
	var grid : Array[Array] = []
	for y in range(h):
		var row = []
		row.resize(w)
		if fill_value != null:
			row.fill(fill_value)
		grid.append(row)
	return grid


## Returns random int between two values using normal distribution. [br]
## result is inclusive between bounds, e.g. (0, 10) = 0 and (0, 10) = 10 [br]
## [warning]: will yield unexpected results If distance between min and max values is less than 6
static func randi_between_values_n(_min : int, _max : int, _deviations : int = 3) -> int:
	var dist = abs(_min - _max)
	var mean : int = _max - (dist / 2)
	var deviation = (dist / 2) / _deviations
	var rand = int(randfn(mean, deviation))
	return clampi(rand, _min, _max)


## Returns random array element, but more likely to pick members from middle of the array
static func pick_random_normalized(array) -> Variant:
	var r_index = randi_between_values_n(0, array.size() -1)
	return array[r_index] 


static func array_compare_replace_with(arr : Array, compare_arr : Array, if_val, replace_val, invert_compare : bool = false):
	for i in range(arr.size()):
		if invert_compare:
			if compare_arr[i] != if_val:
				arr[i] = replace_val
				continue
			continue
		if compare_arr[i] == if_val:
			arr[i] = replace_val
	return arr


static func array_compare_replace_with_2D(arr : Array[Array], compare_arr : Array[Array], if_val, replace_val, invert_compare = false):
	for i in range(arr.size()):
		var inner_arr = arr[i]
		var inner_compare_array = compare_arr[i]
		inner_arr = array_compare_replace_with(inner_arr, inner_compare_array, if_val, replace_val, invert_compare)
		arr[i] = inner_arr

	return arr


static func array_replace_with_2D(arr : Array[Array], replace_cells : Array[Vector2i], replace_val):
	for cell in replace_cells:
		arr[cell.y][cell.x] = replace_val

	return arr
