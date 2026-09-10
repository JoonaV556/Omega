class_name UtilBuildingTemplateGenerator
extends Sprite2D

@export var building_dimensions = Vector2i(2,2)
@export var template_name = "building_template_default"

func generate() -> BuildingTemplate:
    var templ = BuildingTemplate.new()
    templ.dimensions = building_dimensions
    var atlas = texture as AtlasTexture
    if !atlas:
        return null
    templ.texture = atlas
    return templ