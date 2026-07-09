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


static func create_grid(w, h, fill_value) -> Array[Array]:
	var grid : Array[Array] = []
	for y in range(h):
		var row = []
		row.resize(w)
		if fill_value:
			row.fill(fill_value)
		grid.append(row)
	return grid
