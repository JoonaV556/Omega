## OBSOLETE - Provides functions for rendering level data - mainly for debugging
extends Node2D
class_name LevelRenderer

@export
var g_generator: LevelGeneratorOld 
@export
var g_tile_size_in_pixels: int = 16
@export 
var g_level_width: int = 25
@export
var g_level_height: int = 25
@export
var g_iterations: int = 4

@export_group("Bulk generation - Debug feature")
@export var enable_bulk_generation: 						bool = false
@export_range(2, 999) var bulk_generate_count: 	int = 4
## Whether to draw bulk levels in a grid for analysis purposes
@export var enable_bulk_draw: 					bool = false
@export_range(2, 999) var draw_bulk_columns: 	int = 4
@export_range(2, 999) var draw_bulk_rows: 		int = 99
## Extra gap placed between drawn levels
@export_range(0, 999) var draw_bulk_gap: 		int = 2

var g_rendered_once: bool = false

# wait for generator to be ready
func _process(_delta: float) -> void:
	if g_generator.g_ready_to_generate and (g_rendered_once == false):
		g_rendered_once = true
	
		if enable_bulk_generation:
			bulk_generate()

func bulk_generate() -> void:
	print_debug("Generating levels in bulk...")
	var count = 0
	var _levels: Array = []
	var _throwaway_world
	if (enable_bulk_draw):
		for i: int in range(bulk_generate_count):
			_levels.append(
				g_generator._generate(g_level_width, g_level_height, g_iterations)
			) 
			count += 1
		self.render_levels_rect(_levels)
	else:
		for i: int in range(bulk_generate_count):
			_throwaway_world = g_generator._generate(g_level_width, g_level_height, g_iterations)
			count += 1
	print_debug("Generated "+str(count)+" levels in bulk!")

func render_levels_rect(worlds: Array):
	print_debug("asd")
	var x_offset: 				int = 0
	var y_offset: 				int = 0
	var x_delta:					= g_level_width
	var y_delta: 					= g_level_height
	var num_placed_on_column: 	int = 0
	var num_placed_on_row: 		int = 0
	var extra_x = 0
	var extra_y = 0
	
	for i in range(bulk_generate_count):
		if num_placed_on_column >= draw_bulk_rows:
			push_warning("Cannot draw rest of bulk generated worlds, reached max number of rows")
			return
		if num_placed_on_row >= draw_bulk_columns:
			num_placed_on_row 	= 0
			x_offset 			= 0
			y_offset			+= y_delta
			num_placed_on_column+= 1
			extra_x 			= 0
			extra_y 			+= draw_bulk_gap
			
		render_level_rect(worlds[i], Vector2i(x_offset + extra_x, y_offset + extra_y))
		extra_x += draw_bulk_gap
		num_placed_on_row 		+= 1
		x_offset += x_delta

func render_level_rect(level, _position_offset := Vector2i(0, 0)) -> void:
	var l_target_layer: Array[BspNode] = level[level.size() - 1]
	
	for l_node: BspNode in l_target_layer:
		# create a color rectangle 
		var l_rect = ColorRect.new()
		# make it a child of this node 
		self.add_child(l_rect)
		# assign random color to the rect 
		var l_rng_gen = RandomNumberGenerator.new()
		l_rect.color = Color(
			l_rng_gen.randf_range(0.0, 1.0),
			l_rng_gen.randf_range(0.0, 1.0),
			l_rng_gen.randf_range(0.0, 1.0),
			1.0 # always opaque
		)
		# give the rect a correct size 
		var new_size = Vector2(l_node.width * g_tile_size_in_pixels, l_node.height * g_tile_size_in_pixels)
		l_rect.set_size(new_size)
		# place the rect in correct position
		l_rect.set_position(
			Vector2(
				(l_node.position.x + _position_offset.x) * 16, 
				(l_node.position.y + _position_offset.y) * 16
				)
			)
