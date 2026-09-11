@tool
class_name UtilRoadCellGenerator
extends Node2D

## Size in tilemap tiles (16x16px)
@export var size : Vector2i = Vector2i(4, 4):
	set(value):
		size = value
		queue_redraw()

@export var preview_outline_color : Color = Color.WHITE
@export var preview_outline_thickness : float = -1

@export_category("Connections")
@export var connection_north : bool = false
@export var connection_south : bool = false
@export var connection_east : bool = false
@export var connection_west : bool = false

@export_category("Building Plots")
@export_tool_button("Add plot") var add_plot_action = add_plot_rect
@export var plot_preview_color : Color = Color(1.0, 0.0, 0.984, 0.506)


const TILE_SIZE_PIXELS : int = 16


func _draw() -> void:
	draw_preview_outline()


func add_plot_rect():
	var c_rect = ColorRect.new()
	c_rect.name = "Building plot placer"
	c_rect.color = plot_preview_color
	c_rect.size = Vector2(16, 16)
	self.add_child(c_rect)
	c_rect.position = Vector2.ZERO

	c_rect.owner = get_tree().edited_scene_root

	print("added color rect")


func draw_preview_outline():
	if size == Vector2i.ZERO:
		return

	var pixels := Vector2(size.x, size.y) * TILE_SIZE_PIXELS
	draw_rect(
		Rect2(Vector2.ZERO, pixels),
		preview_outline_color,
		false,
		preview_outline_thickness
	)


func generate(tmap : TileMapLayer) -> RoadCell:
	var _c = RoadCell.new()
	_c.size = size

	# Define connections
	var connections = 0
	if connection_north:
		connections = LevelGenerator.add_connection(
			connections, 
			LevelGenerator.R_CONNECTION_N
			)
	if connection_south:
		connections = LevelGenerator.add_connection(
			connections, 
			LevelGenerator.R_CONNECTION_S
			)
	if connection_east:
		connections = LevelGenerator.add_connection(
			connections, 
			LevelGenerator.R_CONNECTION_E
			)
	if connection_west:
		connections = LevelGenerator.add_connection(
			connections, 
			LevelGenerator.R_CONNECTION_W
			)

	# Define tilemap pattern
	if !tmap: 
		return null

	var origin_cell = Vector2i(int(position.x) / 16, int(position.y) / 16)
	_c.tilemap_pattern = OmegaUtils.get_pattern_from_cell(
		tmap,
		origin_cell,
		size
	)

	# Define plots 
	_c. building_plots = []
	for child in get_children():
		if child is ColorRect:
			var c_rect = child as ColorRect
			var plot = BuildingPlot.new()
			plot.position = Vector2i(int(c_rect.position.x / 16), int(c_rect.position.y / 16))
			plot.size = Vector2i(int(c_rect.size.x / 16), int(c_rect.size.y / 16))
			_c.building_plots.append(plot)

	return _c
