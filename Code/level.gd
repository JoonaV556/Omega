# Structure for storing level data for usage outside
extends RefCounted
class_name Level
var road_grid: Array[Array]
var node_grid: Array[Array]

func _init(_road_grid: Array[Array], _node_grid: Array[Array]):
	self.road_grid = _road_grid
	self.node_grid = _node_grid
