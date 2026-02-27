class_name ScoutingMapUI
extends Node

@export var scouting_map: ScoutingMap
@export var map_cell_prefab: PackedScene
@export var map_root_control: Control
@export var map_cell_pixel_separation: int = 1

func _ready() -> void:
	map_root_control.set_visible(false)

func _process(_delta: float) -> void:
	if Input.is_action_just_released("ToggleScoutingMap"):
		if map_root_control.visible == true:
			map_root_control.set_visible(false)
		else:
			map_root_control.set_visible(true)

func generate_ui():
	var _map_size: Vector2i = scouting_map.get_map_grid_size()
	# create and fill map ui grid with map cells
	var _map_vbox:VBoxContainer = VBoxContainer.new()
	_map_vbox.name = "Map VBox (generated)"
	map_root_control.add_child(_map_vbox)
	_map_vbox.add_theme_constant_override("separation", map_cell_pixel_separation)
	for i in range(_map_size.y):
		var _map_hbox:HBoxContainer = HBoxContainer.new()
		_map_hbox.name = "Map HBox (generated)"
		_map_hbox.add_theme_constant_override("separation", map_cell_pixel_separation)
		_map_vbox.add_child(_map_hbox)
		for x in range(_map_size.x):
			var _cell_node = map_cell_prefab.instantiate()
			_cell_node.name = "Map Cell (generated)" 
			_map_hbox.add_child(_cell_node)
