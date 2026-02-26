class_name ScoutingMapUI
extends Node

@export var grid_container: GridContainer
@export var scouting_map: ScoutingMap
@export var map_cell_prefab: PackedScene

func generate_ui():
	# generate grid from map size using cell prefabs
	var _map_size: Vector2i = scouting_map.get_map_grid_size()
	for i in range(_map_size.x * _map_size.y):
		var _cell_node = map_cell_prefab.instantiate()
		grid_container.add_child(_cell_node)
