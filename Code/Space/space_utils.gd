class_name SpaceUtils
extends RefCounted


static func get_object_type_string(object: SpaceObject) -> String:

	if object is System:
		return "System"

	if object is Planet:
		return "Planet"

	return "Unknown"


static func get_galaxy_space_coords(chunk_coords) -> Vector2i:
	return Vector2i(
		floori(float(chunk_coords.x) / SpaceGlobals.galaxy_cell_size.x),
		floori(float(chunk_coords.y) / SpaceGlobals.galaxy_cell_size.y)
	)


static func wait_process_ticks(node: Node, ticks: int) -> void:
	for i in range(max(ticks, 0)):
		await node.get_tree().process_frame


## Returns instantiated BTInstance from a bt resource. blackboard is automatically populated from the trees blackboardplan
static func bt_instantiate(bt: BehaviorTree, agent: Node, instance_owner: Node) -> BTInstance:
	
	var bb_plan := bt.blackboard_plan

	var bb := bb_plan.create_blackboard(null)

	bb_plan.populate_blackboard(bb, true, null)

	var bt_ins := bt.instantiate(
		agent,
		bb,
		instance_owner,
		Engine.get_main_loop().current_scene
	)

	return bt_ins


## Returns vector pointing from point inside chunk a to point inside chunk b
static func get_interstellar_direction(
	chunk_a: Vector2i, 
	pos_a: Vector2, 
	chunk_b: Vector2i, 
	pos_b: Vector2
	) -> Vector2:
	return Vector2(chunk_b - chunk_a) * SpaceGlobals.chunk_size_pixels + pos_b - pos_a
