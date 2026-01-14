## Helper script for drawing levelgenerators levels without tilemaps, useful for visualizing procedural level data
extends Node2D
class_name RectDraw

@export
var g_generator: LevelGenerator 
@export
var g_tile_size_in_pixels: int = 16
@export 
var g_level_width: int = 25
@export
var g_level_height: int = 25
@export
var g_iterations: int = 4

@export_group("Bulk generation")
@export var bulk_generate: bool = false
@export_range(2, 999) var bulk_generate_count: int = 2

var g_drawn: bool = false

# wait for generator to be ready
func _process(delta: float) -> void:
	if g_generator.g_ready_to_generate and (g_drawn == false):
		g_drawn = true
		# _draw_level()
		
		if bulk_generate:
			var count = 0
			for i in range(bulk_generate_count):
				var world = g_generator._generate(g_level_width, g_level_height, g_iterations)
				count += 1
			print("Generated "+str(count)+" worlds in bulk!")
	
func _draw_level() -> void:
	var level = g_generator._generate(g_level_width, g_level_height, g_iterations)
	var l_target_layer: Array[BspNode] = level[level.size() - 1]
	
	for l_node in l_target_layer:
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
		print("shit")
		# place the rect in correct position
		l_rect.set_position(Vector2(l_node.position.x * 16, l_node.position.y * 16))
		print()
