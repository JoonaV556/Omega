@tool
class_name UtilBuildingTemplateGenerator
extends Sprite2D

@export var building_dimensions = Vector2i(2,2)
@export var template_name = "building_template_default":
	set(name):
		template_name = name
		self.name = name

func generate() -> BuildingTemplate:
	var templ = BuildingTemplate.new()
	templ.dimensions = building_dimensions
	var atlas = texture as AtlasTexture
	if !atlas:
		return null
	templ.texture = atlas
	templ.name = template_name
	return templ
