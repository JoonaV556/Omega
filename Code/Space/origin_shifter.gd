class_name OriginShifter
extends Node


@export_category("Origin shifting")
@export var origin_shift_individual_targets: Array[Node2D]
@export var origin_shift_target_parents: Array[Node]
@export var min_seconds_between_origin_shifts: float = 0.5


var _origin_shift_timer: float = 0.0


func _ready() -> void:
	_origin_shift_timer = 0.0


func _physics_process(delta: float) -> void:
	_origin_shift_timer += delta
		

## Moves Node2D targets back to around global position (0, 0). Required to avoid issues caused by floating point errors, when player flies too far off from the center of the world. [br]
func origin_shift(pivot_node: Node2D):
	if _origin_shift_timer < min_seconds_between_origin_shifts:
		return

	var pivot_move_offset := -pivot_node.global_position 

	for indv_target in origin_shift_individual_targets:
		var _target := indv_target as Node2D
		if !_target:
			continue
		_target.global_position += pivot_move_offset 
			
	for parent: Node in origin_shift_target_parents:
		for child: Node in parent.get_children():
			var _target := child as Node2D
			if !_target:
				continue
			_target.global_position += pivot_move_offset

	SpaceGlobals.origin_shift_amount = pivot_move_offset
	SpaceGlobals.origin_shift_version += 1

	_origin_shift_timer = 0.0

	print("Performed origin shift.")
