extends Node
## Utility node for generating TileMapPattern(s) out of shapes drawn on a TileMapLayer
class_name TileMapPatternGenerator

@export var pattern_dimensions : Vector2i = Vector2i(4, 4)

@export var start_cell : Vector2i = Vector2i(0, 0)

@export var tilemap_layer : TileMapLayer

var connection_pick_order : PackedInt32Array = [
	0,
	1+2,
	4+8,
	1+2+4+8,
	1,
	2,
	8,
	4,
	1+2+4,
	1+2+8,
	1+4+8,
	2+4+8,
	1+8,
	8+2,
	1+4,
	4+2
]


var connected_patterns : Array[connected_pattern]


func _ready() -> void:
	var tilemap_coord : Vector2i = start_cell

	for n in range(connection_pick_order.size()):
		# Create pattern
		var _connected_pattern = connected_pattern.new()
		_connected_pattern.connections = connection_pick_order[n]
		var pattern_cells : Array[Vector2i] = []

		# Add tiles on tilemap to pattern
		for y in range(pattern_dimensions.y):
			for x in range(pattern_dimensions.x):
				var cell_coord_on_tilemap = tilemap_coord + Vector2i(x, y)
				var atlas_coords = tilemap_layer.get_cell_atlas_coords(cell_coord_on_tilemap)
				var source_id = tilemap_layer.get_cell_source_id(cell_coord_on_tilemap)

				pattern_cells.append(cell_coord_on_tilemap)

		_connected_pattern.pattern = tilemap_layer.get_pattern(pattern_cells)
		connected_patterns.append(_connected_pattern)

		tilemap_coord += Vector2i(pattern_dimensions.x, 0)


func get_pattern_with_connections(_connections : int) -> TileMapPattern:
	var idx = get_pattern_with_connections_index(_connections)

	if idx<0:
		return null

	return connected_patterns[idx].pattern



func get_pattern_with_connections_index(_connections : int) -> int:
	for n in range(connected_patterns.size()):
		if connected_patterns[n].connections == _connections:
			return n
	return -1


class connected_pattern:
	var pattern : TileMapPattern
	var connections : int
