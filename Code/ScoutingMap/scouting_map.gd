## Scouting map is a core part of the game progression. [br]
## It divides the island into a 2D-grid of cells, [br]
## which the player can choose to gradually explore / map out [br]
class_name ScoutingMap
extends Node

@export var grid_width_override: 	int = 20
@export var grid_height_override: 	int = 20

var map_grid: Array[Array]
var selected_cell: Vector2i = Vector2i(0, 0)

func _ready() -> void:
	# prepare grid
	init_map_grid(20, 20)
	# mark one cell as completed so we have somewhere to start exploring from
	mark_cell_complete(Vector2i(int(grid_width_override/2), 0))

func mark_cell_complete(_coords: Vector2i):
	get_cell_on_map(_coords).completed = true

func get_cell_on_map(_coords: Vector2i) -> ScoutingMapCell:
	return map_grid[_coords.y][_coords.x]

func init_map_grid(_width: int, _height: int):
	var _grid: Array[Array] = []
	_grid.resize(_height)
	for i in range(_grid.size()):
		var _new_row: Array[ScoutingMapCell] = []
		_new_row.resize(_width)
		for x in range(_new_row.size()):
			_new_row[x] = ScoutingMapCell.new()
		_grid[i] = _new_row
	self.map_grid = _grid

func select_cell(_cell_x: int, _cell_y: int) -> bool:
	if (_cell_x < 0) or (_cell_x >= map_grid[0].size()):
		push_error("selection is outside map grid bounds!")
		return false
	if (_cell_y < 0) or (_cell_y >= map_grid.size()):
		push_error("selection is outside map grid bounds!")
		return false
	if map_grid[_cell_y][_cell_x] == null:
		push_error("no cell in grid coordinates!")
		return false 
	selected_cell = Vector2i(_cell_x, _cell_y)
	return true

func enter_selected_cell() -> bool:
	if get_cell_on_map(selected_cell) == null:
		push_error("no cell selected!")
		return false
	if get_cell_on_map(selected_cell).completed == true:
		push_error("cannot explore already explored cells!")
		return false
	if not can_explore(selected_cell):
		return false
	return true

## returns true if given coordinates are valid cells inside the grid
func is_inside_map_bounds(_grid_x:int = 0, _grid_y: int = 0) -> bool:
	if (_grid_x < 0) or (_grid_x >= map_grid[0].size()):
		return false
	if (_grid_y < 0) or (_grid_y >= map_grid.size()):
		return false
	return true

## returns true if the map cell in given map coordinates is valid for exploration (i.e. if the cell is next to a completed cell)
func can_explore(_coords: Vector2i = Vector2i(0, 0)) -> bool:
	if not is_inside_map_bounds(_coords.x, _coords.y):
		return false
	var _cell: ScoutingMapCell = get_cell_on_map(_coords)
	if _cell.completed == true:
		return false
	# check if has completed cells touching
	# check left
	if (_coords.x > 0):
		var _cell_on_left: ScoutingMapCell = get_cell_on_map(Vector2i(_coords.x-1, _coords.y))
		if _cell_on_left.completed == true:
			return true
	# check right
	if (_coords.x < (map_grid[0].size()-1)):
		var _cell_on_right: ScoutingMapCell = get_cell_on_map(Vector2i(_coords.x+1, _coords.y))
		if _cell_on_right.completed == true:
			return true
	# check up
	if (_coords.y < (map_grid.size()-1)):
		var _cell_on_up: ScoutingMapCell = get_cell_on_map(Vector2i(_coords.x, _coords.y + 1))
		if _cell_on_up.completed == true:
			return true
	# check down
	if (_coords.y > 0):
		var _cell_on_down: ScoutingMapCell = get_cell_on_map(Vector2i(_coords.x, _coords.y - 1))
		if _cell_on_down.completed == true:
			return true
	return false

## Holds relevant data about individual map cells 
class ScoutingMapCell:
	var completed: bool = false
