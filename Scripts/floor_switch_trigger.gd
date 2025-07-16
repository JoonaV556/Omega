class_name NodeSwitchTrigger
extends Area2D

@export var target_floor: Floor = null
@export var hide_floors: Array[Node2D]

func _on_body_entered(body: Node2D) -> void:
	if target_floor == null:
		return
	
	body.reparent(target_floor)
	if body is CollisionObject2D:
		body.set_collision_layer(target_floor.collision_layer)
		body.set_collision_mask(target_floor.collision_layer)
	target_floor.show()
	for floor in hide_floors:
		floor.hide()
