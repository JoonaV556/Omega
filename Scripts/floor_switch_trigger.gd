class_name NodeSwitchTrigger
extends Area2D

@export var floor_to_activate: Floor
@export var floors_to_deactivate: Array[Floor]

func _on_body_entered(body: Node2D) -> void:
	if floor_to_activate == null:
		return
	
	body.reparent(floor_to_activate)
	floor_to_activate.activated.emit()
	for floor in floors_to_deactivate:
		floor.deactivated.emit()
