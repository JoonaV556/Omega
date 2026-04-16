class_name VisualObserver
extends Observer

# each frame:
#   get observables in radius
#       if no obstacles between observer and observable
#           detect observable
#

# # raycast from new position to last position
# 	var vector: Vector2 = prev_pos + ((next_pos-prev_pos)*cast_ahead_distance)
# 	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
# 	var query = PhysicsRayQueryParameters2D.create(prev_pos, vector, raycast_mask)
# 	query.collide_with_areas = true
# 	query.collide_with_bodies = true
# 	query.hit_from_inside = true
# 	var result: Dictionary = space_state.intersect_ray(query)

## layers which block sight raycasts
@export_flags_2d_physics var sight_raycast_layers
@export_flags_2d_physics var sight_blocking_layers

@export var sight_distance: float = 5.0*16.0

var shape_query: PhysicsShapeQueryParameters2D
var ray_query: PhysicsRayQueryParameters2D

func _ready() -> void:
	# preconfig physics queries
	shape_query = PhysicsShapeQueryParameters2D.new()
	shape_query.collision_mask = sight_raycast_layers	
	shape_query.collide_with_bodies = true
	# sight ray query
	ray_query = PhysicsRayQueryParameters2D.create(
		self.global_position, 
		self.global_position, 
		sight_blocking_layers
		)

func get_detection_candidates() -> Array[Observable]:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	
	# create circle shape for the query 
	var shape_rid = PhysicsServer2D.circle_shape_create()
	var radius = sight_distance
	PhysicsServer2D.shape_set_data(shape_rid, radius)
	shape_query.shape_rid = shape_rid
	shape_query.transform.origin = self.global_position # spawn point

	# Execute physics queries here...
	var result: Array[Dictionary] = space_state.intersect_shape(shape_query)

	var to_return: Array[Observable] = []
	for dict in result:
		var collider: Node2D = dict["collider"]
		for child in collider.get_children(): ## TODO Optimize
			if child is VisualObservable:
				to_return.append(child)

	# Release the shape when done with physics queries.
	PhysicsServer2D.free_rid(shape_rid)
	return to_return

func can_detect(observable: Observable) -> bool:
	# Cant see if observable is too far away
	var distance_between: float = self.global_position.distance_to(observable.global_position)
	if distance_between > sight_distance:
		return false

	# Obs is close enough, check if obstacles in between are blocking sight
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	ray_query.from = self.global_position
	ray_query.to = observable.global_position
	
	var result: Dictionary = space_state.intersect_ray(ray_query)

	if result.is_empty():
		return true # no obstacles blocking sight
	else:
		return false # something is blocking sight
