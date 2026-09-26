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

	var pattern = OmegaUtils.get_pattern_from_cell(
		tilemap,
		Vector2i(self.global_position / Vector2(16.0, 16.0)), # get self position on tilemap
		template_dimensions
	)
	templ.tilemap_pattern = pattern

	# Create new clean Node2D parent for children sprites etc.
	var children = get_children()
	var nodes_parent = Node2D.new()
	add_child(nodes_parent)
	for c in children:
		c.reparent(nodes_parent, true)
	nodes_parent.name = StringName(template_name)

	templ.nodes_parent = nodes_parent

	templ.dimensions = template_dimensions

	return templ
