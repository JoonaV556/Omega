# Structure for storing level data for usage outside
extends RefCounted
class_name ProceduralLevelData
var road_grid: Array[Array]
var node_grid: Array[Array]
var city_block_type_grid: Array[Array]

func _init(_road_grid: Array[Array], _node_grid: Array[Array], _city_block_grid: Array[Array]):
	self.road_grid = _road_grid
	self.node_grid = _node_grid
	self.city_block_type_grid = _city_block_grid
	
func get_width():
	return road_grid[0].size()

func get_height():
	return road_grid.size()
