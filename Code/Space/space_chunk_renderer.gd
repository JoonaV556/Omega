class_name SpaceChunkRenderer
extends Node


@export var chunk_nodes_parent: Node

@export var planet_2d_scene: PackedScene

@export_category("Debug")
@export var debug_draw_chunk_bounds: bool = false:
	set(value):
		debug_draw_chunk_bounds = value
		for bounds in _debug_chunk_bounds.values():
			bounds.visible = value


var _origin_chunk_coords: Vector2i

var _world_origin_global_position: Vector2

var _player_initial_local_position: Vector2

var _rendered_chunks: Dictionary[SpaceChunk, Node2D]

var _debug_chunk_bounds: Dictionary[SpaceChunk, Line2D]


func init(player_initial_chunk_coords: Vector2i, player_initial_local_position: Vector2, player_initial_world_position: Vector2):
	_origin_chunk_coords = player_initial_chunk_coords
	_world_origin_global_position = player_initial_world_position
	_player_initial_local_position = player_initial_local_position


func render_chunk(chunk: SpaceChunk):
	# Decide under which node objects are placed
	var chunk_parent: Node
	if chunk_nodes_parent:
		chunk_parent = chunk_nodes_parent
	else:
		chunk_parent = get_tree().current_scene

	# Create root node for chunk
	var chunk_root := Node2D.new()
	chunk_root.name = String("Space chunk %s" % [chunk.coordinates])
	
	# add to tree
	chunk_parent.add_child(chunk_root)

	# Position chunk
	var chunk_offset := chunk.coordinates - _origin_chunk_coords
	var chunk_world_position := (_world_origin_global_position - _player_initial_local_position) + Vector2(
		chunk_offset.x * SpaceGlobals.chunk_size_pixels.x,
		chunk_offset.y * SpaceGlobals.chunk_size_pixels.y
	)
	chunk_root.global_position = chunk_world_position

	# If chunk is system, add name to chunk root's name as suffix
	if chunk.stellar_type and chunk.stellar_type is System:
		chunk_root.name = "%s - %s" % [chunk_root.name, chunk.stellar_type.name]


	# Render objects in the chunk 
	for object in chunk.stellar_objects.keys():
		render_stellar_object(object, chunk_root, chunk.stellar_objects[object])

	_draw_debug_visuals(chunk, chunk_root)

	_rendered_chunks[chunk] = chunk_root

	print('Rendered chunk %s' % [chunk.coordinates])


func unrender_chunk(chunk: SpaceChunk):
	var node := _rendered_chunks[chunk]
	_rendered_chunks.erase(chunk)

	# erase debug visuals
	if debug_draw_chunk_bounds:
		_debug_chunk_bounds.erase(chunk)

	node.queue_free()
	
	print('Unrendered chunk %s' % [chunk.coordinates])
	

func render_stellar_object(object, parent, local_position) -> Node2D:
	var rendered: Node2D
	
	if object is Planet:
		rendered = render_planet(object)


	parent.add_child(rendered)
	rendered.position = local_position

	return rendered


func render_planet(planet) -> Node2D:
	var _planet := planet as Planet

	var radius = _planet.radius_pixels

	var planet_node := planet_2d_scene.instantiate() as CollidableStellarObject2D

	planet_node.set_radius_pixels(radius)

	return planet_node

func _draw_debug_visuals(chunk: SpaceChunk, chunk_root: Node2D) -> void:
	if !debug_draw_chunk_bounds:
		return

	var chunk_bounds := Line2D.new()
	chunk_bounds.name = "Debug chunk bounds"
	chunk_bounds.points = PackedVector2Array([
		Vector2.ZERO,
		Vector2(SpaceGlobals.chunk_size_pixels.x, 0.0),
		SpaceGlobals.chunk_size_pixels,
		Vector2(0.0, SpaceGlobals.chunk_size_pixels.y)
	])
	chunk_bounds.closed = true
	chunk_bounds.width = 2.0
	chunk_bounds.default_color = Color.GREEN
	chunk_root.add_child(chunk_bounds)
	_debug_chunk_bounds[chunk] = chunk_bounds
