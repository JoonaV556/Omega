class_name SpaceChunkRenderer
extends Node


@export var chunk_nodes_parent: Node

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
