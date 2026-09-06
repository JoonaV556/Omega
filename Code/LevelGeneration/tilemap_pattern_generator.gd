extends Node
## Utility node for generating TileMapPattern(s) out of shapes drawn on a TileMapLayer
class_name TileMapPatternGenerator

@export var pattern_dimensions: Vector2i = Vector2i(4, 4)

@export var pattern_count: int = 1

@export var start_cell: Vector2i = Vector2i(0, 0)

@export var tilemap_layer: TileMapLayer

var patterns: Array[TileMapPattern] = []


func _ready() -> void:
	_generate_patterns()


func _generate_patterns():
	var tilemap_coord: Vector2i = start_cell

	for _pattern_index in range(pattern_count):
		var pattern_cells: Array[Vector2i] = []

		for y in range(pattern_dimensions.y):
			for x in range(pattern_dimensions.x):
				pattern_cells.append(tilemap_coord + Vector2i(x, y))

		patterns.append(tilemap_layer.get_pattern(pattern_cells))
		tilemap_coord += Vector2i(pattern_dimensions.x, 0)


func get_patterns() -> Array[TileMapPattern]:
	return patterns


func get_pattern(index: int) -> TileMapPattern:
	if index < 0 or index >= patterns.size():
		return null

	return patterns[index]
