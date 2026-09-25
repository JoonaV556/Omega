class_name UtilMapCellTemplateGroupGenerator
extends Node2D

@export var tilemap : TileMapLayer

func generate() -> Array[MapCellTemplate]:
	var templates : Array[MapCellTemplate] = []
	for c in get_children():
		if c is UtilMapCellTemplateGenerator:
			templates.append(c.generate(tilemap))
	print('Succesfully generated %s map cell templates' % [templates.size()])
	return templates
