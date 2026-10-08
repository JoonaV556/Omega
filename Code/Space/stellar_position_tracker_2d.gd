class_name StellarPositionTracker2D
extends StellarPositionTracker

@export var tracked_override: Node2D

signal on_init(chunk_position: Vector2i, local_position: Vector2, world_position: Vector2)
signal on_chunk_changed(chunk_position: Vector2i, local_position: Vector2, world_position: Vector2)
signal on_origin_shift_position_treshold_exceeded(_tracked: Node2D)
signal on_origin_shift(current_chunk_coords: Vector2i, local_chunk_position: Vector2, world_position)

var _tracked: Node2D

## Position of the tracked inside the actual 2D world
var _tracked_last_real_position: Vector2

var _last_origin_shift_version: int

var movement_delta_since_last_tick: Vector2

var _exceeded_position_limit_last_frame: bool = false


func _ready() -> void:
	if tracked_override:
		_tracked = tracked_override
	
	if !_tracked:
		var parent = get_parent() as Node2D

		if !parent:
			push_error("No node to track")
			return

		_tracked = parent
	
	if !_tracked:
		push_error("No node to track")
		return
	
	# Init chunk size
	set_chunk_size(SpaceGlobals.chunk_size_pixels)

	# Init position
	set_position(start_chunk_coords, start_local_position)

	# Init needed 2d values
	_tracked_last_real_position = _tracked.global_position
	_last_origin_shift_version = SpaceGlobals.origin_shift_version

	_exceeded_position_limit_last_frame = false

	on_init.emit(current_chunk_coordinates, current_local_position, _tracked_last_real_position)


func _physics_process(delta: float) -> void:
	if !_tracked:
		return
	# Check if tracked has moved too far away from world center
	var global_pos := _tracked.global_position
	var treshold := SpaceGlobals.global_position_origin_shift_treshold
	var x_exceeded = global_pos.x > treshold.x or global_pos.x < -treshold.x
	var y_exceeded = global_pos.y > treshold.y or global_pos.y < -treshold.y

	if _exceeded_position_limit_last_frame and (!x_exceeded and !y_exceeded):
		_exceeded_position_limit_last_frame = false ## reset flag

	if x_exceeded or y_exceeded:
		print('Exceeded o-o_shift pos limit treshold')
		on_origin_shift_position_treshold_exceeded.emit(_tracked) # Moved too far away
		_exceeded_position_limit_last_frame = true

	# Check movement delta in real 2d space, taking into account origin shifts
	movement_delta_since_last_tick = _tracked.global_position - _tracked_last_real_position

	# Account origin shifts
	var o_shift = false
	if _last_origin_shift_version != SpaceGlobals.origin_shift_version:
		movement_delta_since_last_tick -= SpaceGlobals.origin_shift_amount
		_last_origin_shift_version = SpaceGlobals.origin_shift_version
		o_shift = true
		print('Origin o_shift detected')

	_tracked_last_real_position = _tracked.global_position

	var old_chunk := current_chunk_coordinates

	# Update position in virtual chunk space
	move(movement_delta_since_last_tick)

	# Inform others of origin shift
	if o_shift:
		on_origin_shift.emit(current_chunk_coordinates, current_local_position, _tracked.global_position)

	if current_chunk_coordinates != old_chunk:
		on_chunk_changed.emit(current_chunk_coordinates, current_local_position, _tracked_last_real_position)
		print('Moved to stellar chunk %s (local %s)' % [current_chunk_coordinates, current_local_position])
	
	
