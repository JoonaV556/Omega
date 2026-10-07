extends Node

@export var galaxies_min = 5
@export var galaxies_max = 30
@export var gal_coords_min = Vector2(-50.0, -50.0)
@export var gal_coords_max = Vector2(50.0, 50.0)
@export var systems_per_galaxy_min = 1
@export var systems_per_galaxy_max = 10
@export var system_coords_min = Vector2(-50.0, -50.0)
@export var system_coords_max = Vector2(50.0, 50.0)

@export var omega_ui : OmegaUI

@export var open_map_auto = true

signal on_generated(object)

func _ready() -> void:
	# Generate cluster of galaxies
	var params = HSpaceGenerator.universe_params.new()
	params.galaxies_min = galaxies_min
	params.galaxies_max = galaxies_max
	params.gal_coords_min = gal_coords_min
	params.gal_coords_max = gal_coords_max
	params.systems_per_galaxy_min = systems_per_galaxy_min
	params.systems_per_galaxy_max = systems_per_galaxy_max
	params.system_coords_min = system_coords_min
	params.system_coords_max = system_coords_max

	var root : HStellarObject = HSpaceGenerator.generate_universe(params)

	var _char = Character.new()
	_char.name = "Clarius Merck"
	_char.location_object = root.objects[0].objects[0]

	var map_ui : OldMapUI = omega_ui.map_ui
	map_ui.set_character_location_info(_char)
	map_ui.open_map_for_object(root, open_map_auto)
