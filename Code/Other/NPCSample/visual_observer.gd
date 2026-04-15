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

@export var sight_distance: float = 5.0*16.0

func get_detection_candidates() -> Array[Observable]:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape_rid = PhysicsServer2D.circle_shape_create()
	var radius = sight_distance
	PhysicsServer2D.shape_set_data(shape_rid, radius)
	query.shape_rid = shape_rid
	query.collide_with_bodies = true
	
	# Execute physics queries here...
	var result: Array[Dictionary] = space_state.intersect_shape(query)


	# Release the shape when done with physics queries.
	PhysicsServer2D.free_rid(shape_rid)
	return []

func can_detect(observable: Observable) -> bool:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		self.global_position, 
		observable.global_position, 
		sight_raycast_layers
		)
	var result: Dictionary = space_state.intersect_ray(query)

	if result.is_empty():
		return true
	else:
		print_debug("sight ray hit: "+str(result["collider"]))
		return false