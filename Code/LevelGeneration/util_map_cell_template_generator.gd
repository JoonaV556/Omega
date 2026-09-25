@tool
class_name UtilMapCellTemplateGenerator
extends Node2D

## Dimensions in tilemap cells
@export var template_dimensions : Vector2i = Vector2i(64, 64)

@export var template_name : String = "map_cell_template"

@export var debug_outline_color : Color = Color.WHITE

@export var tilemap : TileMapLayer


func _draw() -> void:
	OmegaUtils.draw_tilemap_preview_outline(
		template_dimensions,
		tilemap,
		self,
		debug_outline_color
	)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()


func generate(_tilemap : TileMapLayer) -> MapCellTemplate:
	var templ : MapCellTemplate = MapCellTemplate.new()
	

	if !_tilemap:
		_tilemap = tilemap

	templ.tilemap_pattern = OmegaUtils.get_pattern_from_cell(
		tilemap,
		Vector2i(self.global_position),
		template_dimensions
	)

	var nodes_parent = self.duplicate() as Node2D
	nodes_parent.name = StringName(template_name)
	templ.nodes_parent = nodes_parent

	templ.dimensions = template_dimensions

	return templ
