## Draws loaded chunks and ships in game world.
class_name SpaceChunkRenderer
extends ThrottledNode

## Chunk drawing is done using signals. Connect chunk_loaded to draw_chunk and chunk_unloaded to undraw_chunk
## Spaceship loading is done continously in _throttled_process, which polls for virtualized ship positions and loads/unloads them once they enter and leave loaded chunk area.


@export var chunk_nodes_parent: Node

@export var phyiscal_body_2d_scene: PackedScene

@export_category("Ship Loading")
@export var spaceship_scene: PackedScene
@export var ship_nodes_parent: Node:
	set(value):
		if !value:
			ship_nodes_parent = self
		else:
			ship_nodes_parent = value

@export_category("Debug")
@export var debug_draw_chunk_bounds: bool = false:
	set(value):
		debug_draw_chunk_bounds = value
		for bounds in _debug_chunk_bounds.values():
			bounds.visible = value
@export_range(0.5, 10.0, 0.5) var debug_chunk_bounds_width_pixels: float = 2.0


var _origin_chunk_coords: Vector2i

var _world_origin_global_position: Vector2

var _player_initial_local_position: Vector2

var _rendered_chunks: Dictionary[SpaceChunk, Node2D]

var _body_nodes: Dictionary[OrbitalBody, OrbitalBodyRoot2D]

var _debug_chunk_bounds: Dictionary[SpaceChunk, Line2D]

var _loaded_chunks: Array[Vector2i] = []

static var  _loaded_ships: Dictionary[SpaceShip, SpaceShipController] = {}



func _process(delta: float) -> void:
	super._process(delta)
	# Ensure chunk bound line thickness stays consistent regardless of camera zoom
	_update_debug_chunk_bounds_width()


func _throttled_process(_delta: float):
	
	# Load unloaded ships in loaded area
	var ships: Array[SpaceShip] # get ships in loaded chunks
	for chunk in _loaded_chunks:
		ships.append_array(SpaceshipManager.get_ships_in_chunk(chunk))

	for ship: SpaceShip in ships:
		if _loaded_ships.has(ship):
			continue
			
		var chunk_node := get_chunk_node(ship.get_chunk())
		
		if !chunk_node: # Chunk node might not be created yet, since chunk loading is not done synchronously with ship loading. In this case, ship will be loaded later once chunk is ready.
			continue

		var ship_id = SpaceshipManager.get_ship_id(ship)
		var ship_ctr := spaceship_scene.instantiate() as SpaceShipController

		ship_ctr.ship_id = ship_id

		ship_nodes_parent.add_child(ship_ctr)

		# Place ship in correct position
		var ship_local_pos := ship.get_local_position()

		ship_ctr.global_position = chunk_node.global_position + ship_local_pos

		_loaded_ships[ship] = ship_ctr

		print("loaded ship")


	# Unload loaded ships outside loaded area
	for ship in _loaded_ships.keys():
		var ship_chunk: Vector2i = ship.get_chunk()

		if !_loaded_chunks.has(ship_chunk):
			_loaded_ships[ship].queue_free()
			_loaded_ships.erase(ship)
			print("unloaded ship")


func _update_debug_chunk_bounds_width() -> void:
	if _debug_chunk_bounds.is_empty():
		return

	var canvas_transform := get_viewport().get_canvas_transform()
	var horizontal_scale := canvas_transform.basis_xform(Vector2.RIGHT).length()
	var vertical_scale := canvas_transform.basis_xform(Vector2.DOWN).length()

	var pixels_per_world_unit := maxf(
		minf(horizontal_scale, vertical_scale),
		0.001
	)
	var world_width := debug_chunk_bounds_width_pixels / pixels_per_world_unit
	for bounds: Line2D in _debug_chunk_bounds.values():
		if is_instance_valid(bounds):
			bounds.width = world_width


func _bake_nav_polygon(
	nav_poly: NavigationPolygon,
	source_geometry_data: NavigationMeshSourceGeometryData2D,
	nav_reg: NavigationRegion2D
) -> void:
	if !is_instance_valid(nav_reg):
		return

	NavigationServer2D.bake_from_source_geometry_data(
		nav_poly,
		source_geometry_data,
		func():
			if is_instance_valid(nav_reg):
				nav_reg.navigation_polygon = nav_poly
	)


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
				orbital_root.position = chunk.orbital_center_position

			_body_nodes[body] = orbital_root

			found_children.append_array(body.orbiting_children)
		
		bodies.clear()
		bodies = found_children


func _draw_debug_visuals(chunk: SpaceChunk, chunk_root: Node2D) -> void:
	if !debug_draw_chunk_bounds:
		return

	# Build a dedicated debug layer for the chunk overlay.
	var debug_visuals := Node2D.new()
	debug_visuals.name = "Debug visuals"
	debug_visuals.z_index = 100
	chunk_root.add_child(debug_visuals)

	# Draw the chunk bounds so the generated region is visible in the world.
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

	# Label the chunk itself so its coordinates are readable while debugging.
	var chunk_coordinates := Label.new()
	chunk_coordinates.name = "Debug chunk coordinates"
	chunk_coordinates.position = Vector2(8.0, 8.0)
	chunk_coordinates.text = "%s" % [chunk.coordinates]
	chunk_coordinates.add_theme_color_override("font_color", Color.WHITE)
	chunk_coordinates.add_theme_color_override("font_outline_color", Color.BLACK)
	chunk_coordinates.add_theme_constant_override("outline_size", 2)
	debug_visuals.add_child(chunk_coordinates)

	# Draw orbital rings for the current chunk only so stale node data doesn't leak between chunks.
	if chunk.bodies_root:
		var chunk_bodies := chunk.bodies_root.get_bodies_in_hierarchy()
		for body in chunk_bodies:
			if !body.orbit_parent or body.orbit_radius <= 0.0:
				continue

			var parent_orbital_root = _body_nodes.get(body.orbit_parent)
			if parent_orbital_root == null:
				continue

			var orbit_center := debug_visuals.to_local(parent_orbital_root.body_pivot.global_position)

			var orbit_circle := Line2D.new()
			orbit_circle.name = "Orbit debug - %s" % [body.name]
			orbit_circle.width = 1.0
			orbit_circle.default_color = Color(0.2, 1.0, 0.2, 0.8)
			orbit_circle.closed = true

			var circle_points := PackedVector2Array()
			for i in range(97):
				var angle := TAU * float(i) / 96.0
				circle_points.append(
					orbit_center + Vector2(
						cos(angle) * body.orbit_radius,
						sin(angle) * body.orbit_radius
					)
				)
			orbit_circle.points = circle_points
			debug_visuals.add_child(orbit_circle)

	_debug_chunk_bounds[chunk] = chunk_bounds


func _get_chunks_parent() -> Node:
	var chunk_parent: Node
	if chunk_nodes_parent:
		chunk_parent = chunk_nodes_parent
	else:
		chunk_parent = get_tree().current_scene
	return chunk_parent


static func mark_loaded(ship: SpaceShip, ship_controller: SpaceShipController):
	_loaded_ships[ship] = ship_controller


static func is_loaded(ship: SpaceShip) -> bool:
	return _loaded_ships.has(ship)


func get_chunk_node(chunk_coords) -> Node2D:
	var cn: Node2D = null

	for chunk in _rendered_chunks.keys():
		if chunk.coordinates == chunk_coords:
			cn = _rendered_chunks[chunk]
			break

	return cn


func draw_chunk(chunk: SpaceChunk):
	# Decide under which node objects are placed
	var chunk_parent := _get_chunks_parent()

	# Create root node for chunk
	var chunk_root := Node2D.new()
	chunk_root.name = String("Space chunk %s - Bodies %s" % [chunk.coordinates, 0 if !chunk.bodies_root else chunk.bodies_root.get_bodies_num_in_hierarchy()])
	
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

	# Create nav region for chunk
	var nav_reg := NavigationRegion2D.new()
	var nav_poly := NavigationPolygon.new()

	nav_poly.agent_radius = 0.0 # Ensure there are no gaps between chunk nav regions

	nav_reg.use_edge_connections = true

	nav_poly.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	nav_poly.source_geometry_group_name = 'navigation'

	var bounding_outline = PackedVector2Array(
		[Vector2(0, 0), 
		Vector2(0, SpaceGlobals.chunk_size_pixels.y), 
		Vector2(SpaceGlobals.chunk_size_pixels.x, SpaceGlobals.chunk_size_pixels.y), 
		Vector2(SpaceGlobals.chunk_size_pixels.x, 0)]
		)

	nav_poly.add_outline(bounding_outline)
	nav_reg.navigation_polygon = nav_poly
	chunk_root.add_child(nav_reg)

	var source_geometry_data := NavigationMeshSourceGeometryData2D.new() # Parse grouped chunk obstacles before baking them into the navigation polygon.
	NavigationServer2D.parse_source_geometry_data(
		nav_poly,
		source_geometry_data,
		chunk_root,
		func(): _bake_nav_polygon(nav_poly, source_geometry_data, nav_reg)
	)

	# Update rendered chunks
	_rendered_chunks[chunk] = chunk_root

	_draw_debug_visuals(chunk, chunk_root)

	print('Rendered chunk %s' % [chunk.coordinates])


func undraw_chunk(chunk: SpaceChunk):
	if !_rendered_chunks.has(chunk):
		return
		
	var chunk_parent_node := _rendered_chunks[chunk]
	_rendered_chunks.erase(chunk)

	_debug_chunk_bounds.erase(chunk)

	chunk_parent_node.queue_free()

	# Update body node references
	if chunk.bodies_root:
		var chunk_bodies := chunk.bodies_root.get_bodies_in_hierarchy()
		for _body in chunk_bodies:
			_body_nodes.erase(_body)
	
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


func init(player_initial_chunk_coords: Vector2i, player_initial_local_position: Vector2, player_initial_world_position: Vector2):
	_origin_chunk_coords = player_initial_chunk_coords
	_world_origin_global_position = player_initial_world_position
	_player_initial_local_position = player_initial_local_position


func update_render_origin(chunk_coords: Vector2, local_chunk_coords: Vector2, world_position: Vector2):
	_origin_chunk_coords = chunk_coords
	_player_initial_local_position = local_chunk_coords
	_world_origin_global_position = world_position


func update_loaded_chunks(loaded_chunks: Array[Vector2i]):
	_loaded_chunks = loaded_chunks
