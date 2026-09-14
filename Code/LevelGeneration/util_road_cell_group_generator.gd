class_name UtilRoadCellGroupGenerator
extends Node2D


@export var tilemap : TileMapLayer
@export var output_library : CellTemplateLibrary
@export var output_group_name : StringName


func _ready() -> void:
	if !output_library:
		return

	if !tilemap:
		return

	## Either arr type of RoadCellTemplate or RoadConnectorCellTemplate
	var generated_templates : Array = []

	for _n : Node in get_children():
		if (_n is UtilRoadCellGenerator) or (_n is UtilRoadConnectorCellGenerator):
			generated_templates.append(
				_n.generate(tilemap)
			)

		continue

	output_library.template_groups[output_group_name] = generated_templates

	print('Generated %s cell templates from generator nodes.' % [generated_templates.size()])
	push_warning("Overwrote template group in template library! This might not be ideal in release builds!")
	
