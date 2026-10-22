class_name SpaceChunkRenderer
extends Node


@export var chunk_nodes_parent: Node

@export var phyiscal_body_2d_scene: PackedScene

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

var _body_nodes: Dictionary[OrbitalBody, OrbitalBodyRoot2D]

var _debug_chunk_bounds: Dictionary[SpaceChunk, Node2D]


func init(player_initial_chunk_coords: Vector2i, player_initial_local_position: Vector2, player_initial_world_position: Vector2):
	_origin_chunk_coords = player_initial_chunk_coords
	_world_origin_global_position = player_initial_world_position
	_player_initial_local_position = player_initial_local_position


func update_render_origin(chunk_coords: Vector2, local_chunk_coords: Vector2, world_position: Vector2):
	_origin_chunk_coords = chunk_coords
	_player_initial_local_position = local_chunk_coords
	_world_origin_global_position = world_position


func draw_chunk(chunk: SpaceChunk):
	# Decide under which node objects are placed
	var chunk_parent := _get_chunks_parent()

	# Create root node for chunk
	var chunk_root := Node2D.new()
	chunk_root.name = String("Space chunk %s" % [chunk.coordinates])
	
	# add to tree
	chunk_parent.add_child(chunk_root)

	# Position chunk root node
	var chunk_offset := chunk.coordinates - _origin_chunk_coords
	var chunk_world_position := (_world_origin_global_position - _player_initial_local_position) + Vector2(
		chunk_offset.x * SpaceGlobals.chunk_size_pixels.x,
		chunk_offset.y * SpaceGlobals.chunk_size_pixels.y
	)
	chunk_root.global_position = chunk_world_position

	# If chunk is system, add name to chunk root's name as suffix
	if chunk.system and chunk.system is System:
		chunk_root.name = "%s - %s" % [chunk_root.name, chunk.system.name]

	# Draw bodies in the chunk
	if chunk.bodies_root:
		_draw_chunk_bodies(chunk, chunk_root, chunk.bodies_root)

	_draw_debug_visuals(chunk, chunk_root)

	_rendered_chunks[chunk] = chunk_root

	print('Rendered chunk %s' % [chunk.coordinates])


func render_chunk_old(chunk: SpaceChunk):
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
	if chunk.system and chunk.system is System:
		chunk_root.name = "%s - %s" % [chunk_root.name, chunk.system.name]

	# Render objects in the chunk 
	#for object in chunk.objects.keys():
		#draw_body(object, chunk_root, chunk.objects[object])

	_draw_debug_visuals(chunk, chunk_root)

	_rendered_chunks[chunk] = chunk_root

	print('Rendered chunk %s' % [chunk.coordinates])


func unrender_chunk(chunk: SpaceChunk):
	if !_rendered_chunks.has(chunk):
		return
		
	var chunk_parent_node := _rendered_chunks[chunk]
	_rendered_chunks.erase(chunk)

	_debug_chunk_bounds.erase(chunk)

	chunk_parent_node.queue_free()
	
	print('Unrendered chunk %s' % [chunk.coordinates])


func draw_body(body: OrbitalBody) -> Node2D:
	var drawn: Node2D
	
	if body is PhysicalBody:
		drawn = draw_physical_body(body as PhysicalBody)

	return drawn


func draw_physical_body(body: PhysicalBody) -> Node2D:
	var body_node := phyiscal_body_2d_scene.instantiate() as CollidableStellarObject2D

	body_node.set_radius_pixels(body.size_radius)

	body_node.name = "Physical Body 2D - %s" % [body.name]

	return body_node


func _draw_chunk_bodies(chunk: SpaceChunk, chunk_root: Node2D, bodies_root: OrbitalBody):
	var bodies: Array[OrbitalBody] = [bodies_root]
	while true:

		var found_children: Array[OrbitalBody] = []

		if bodies.is_empty():
			break

		for body in bodies:
			# Create orbital root for the body (handles spinning and orbital movement)
			var is_root = !body.orbit_parent

			var attach_parent: Node

			if is_root:
				attach_parent = chunk_root
			else:
				attach_parent = _body_nodes[body.orbit_parent].body_pivot

			var orbital_root := OrbitalBodyRoot2D.new()
			orbital_root.init(body)
			attach_parent.add_child(orbital_root)

			# Make sure orbital siblings spaced evenly apart from each other by applying an initial rotation offset to the orbital root node
			if body.orbit_parent:
				var siblings := body.orbit_parent.orbiting_children

				if siblings.size() > 1:
					var sibling_index := siblings.find(body)
					var spacing_degs := (360.0 / siblings.size()) * float(sibling_index)
					orbital_root.rotation_degrees += spacing_degs
					print('Added spacing of %s degrees for sibling at index %s' % [spacing_degs, sibling_index])

			# Draw the body 
			var body_node := draw_body(body)
			if body_node:
				orbital_root.body_spin_pivot.add_child(body_node)

			# Place root body in the center position
			if is_root:
				orbital_root.position = chunk.primary_object_position

			_body_nodes[body] = orbital_root

			found_children.append_array(body.orbiting_children)
		
		bodies.clear()
		bodies = found_children


func _draw_debug_visuals(chunk: SpaceChunk, chunk_root: Node2D) -> void:
	if !debug_draw_chunk_bounds:
		return

	var debug_visuals := Node2D.new()
	debug_visuals.name = "Debug visuals"
	debug_visuals.z_index = 100
	chunk_root.add_child(debug_visuals)

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
	debug_visuals.add_child(chunk_bounds)

	var chunk_coordinates := Label.new()
	chunk_coordinates.name = "Debug chunk coordinates"
	chunk_coordinates.position = Vector2(8.0, 8.0)
	chunk_coordinates.text = "%s" % [chunk.coordinates]
	chunk_coordinates.add_theme_color_override("font_color", Color.WHITE)
	chunk_coordinates.add_theme_color_override("font_outline_color", Color.BLACK)
	chunk_coordinates.add_theme_constant_override("outline_size", 2)
	debug_visuals.add_child(chunk_coordinates)

	_debug_chunk_bounds[chunk] = debug_visuals


func _get_chunks_parent() -> Node:
	var chunk_parent: Node
	if chunk_nodes_parent:
		chunk_parent = chunk_nodes_parent
	else:
		chunk_parent = get_tree().current_scene
	return chunk_parent
