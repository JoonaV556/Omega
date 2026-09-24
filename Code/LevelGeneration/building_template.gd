class_name BuildingTemplate
extends RefCounted

## Size in tilemap tiles
var name : String = "building_template_default"
var dimensions : Vector2i
var texture : AtlasTexture
var compatible_zones : Array[LevelGenerator.ZONE]