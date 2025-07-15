class_name NodeSwitchTrigger
extends Area2D

@export var target_floor: Floor = null
@export var hide_floors: Array[Node2D]

func _on_body_entered(body: Node2D) -> void:
	print(target_floor)
	if target_floor == null:
		return
	print(body)
	
	body.reparent(target_floor)
	target_floor.show()
	for floor in hide_floors:
		floor.hide()
