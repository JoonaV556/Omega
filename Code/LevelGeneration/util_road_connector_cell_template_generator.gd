@tool
class_name UtilRoadConnectorCellGenerator
extends Node2D

## Size in tilemap tiles (16x16px)
@export var size : Vector2i = Vector2i(4, 4):
	set(value):
		size = value
		queue_redraw()

@export var preview_outline_color : Color = Color.WHITE
@export var preview_outline_thickness : float = -1

@export_category("Highway Connections")
@export var highway_connection_north : bool = false
@export var highway_connection_south : bool = false
@export var highway_connection_east : bool = false
@export var highway_connection_west : bool = false

@export_category("Small Road Connections")
@export var small_road_connection_north : bool = false
@export var small_road_connection_south : bool = false
@export var small_road_connection_east : bool = false
@export var small_road_connection_west : bool = false

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


func generate(tmap : TileMapLayer) -> RoadConnectorCellTemplate:
	var _c = RoadConnectorCellTemplate.new()
	_c.size = size

	# Define highway connections
	_c.highway_connections = 0
	if highway_connection_north:
		_c.highway_connections = LevelGenerator.add_connection(
			_c.highway_connections,
			LevelGenerator.R_CONNECTION_N
		)
	if highway_connection_south:
		_c.highway_connections = LevelGenerator.add_connection(
			_c.highway_connections,
			LevelGenerator.R_CONNECTION_S
		)
	if highway_connection_east:
		_c.highway_connections = LevelGenerator.add_connection(
			_c.highway_connections,
			LevelGenerator.R_CONNECTION_E
		)
	if highway_connection_west:
		_c.highway_connections = LevelGenerator.add_connection(
			_c.highway_connections,
			LevelGenerator.R_CONNECTION_W
		)

	# Define small road connections
	_c.small_road_connections = 0
	if small_road_connection_north:
		_c.small_road_connections = LevelGenerator.add_connection(
			_c.small_road_connections,
			LevelGenerator.R_CONNECTION_N
		)
	if small_road_connection_south:
		_c.small_road_connections = LevelGenerator.add_connection(
			_c.small_road_connections,
			LevelGenerator.R_CONNECTION_S
		)
	if small_road_connection_east:
		_c.small_road_connections = LevelGenerator.add_connection(
			_c.small_road_connections,
			LevelGenerator.R_CONNECTION_E
		)
	if small_road_connection_west:
		_c.small_road_connections = LevelGenerator.add_connection(
			_c.small_road_connections,
			LevelGenerator.R_CONNECTION_W
		)

	# Define tilemap pattern
	if !tmap:
		return null

	var origin_cell = Vector2i(
		int(floor(position.x / 16.0)),
		int(floor(position.y / 16.0))
	)
	_c.tilemap_pattern = OmegaUtils.get_pattern_from_cell(
		tmap,
		origin_cell,
		size
	)

	# Define plots
	for child in get_children():
		if child is ColorRect:
			var c_rect = child as ColorRect
			var plot = BuildingPlot.new()
			plot.position = Vector2i(int(c_rect.position.x / 16), int(c_rect.position.y / 16))
			plot.dimensions = Vector2i(int(c_rect.size.x / 16), int(c_rect.size.y / 16))
			_c.building_plots.append(plot)

	return _c
