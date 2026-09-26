class_name MapGrid
extends RefCounted

var dimensions : Vector2i

var _grid : Array[MapGridCell]

func _init(grid_dimensions : Vector2i) -> void:
    dimensions = grid_dimensions

    _grid = []
    _grid.resize(dimensions.x * dimensions.y)
    for n in range(_grid.size()):
        _grid[n] = MapGridCell.new()


func get_cell(coordinates : Vector2i) -> MapGridCell:
    return OmegaUtils.array_1d_get_value_at_2d_coordinates(_grid, coordinates, dimensions)
    
