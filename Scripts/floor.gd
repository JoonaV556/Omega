class_name Floor
extends Node2D

signal activated
signal deactivated

func _ready():
	activated.connect(_on_activated)
	deactivated.connect(_on_deactivated)
	
	for node in get_children():		
		if not node.has_meta("is_player"):
			continue
			
		activate()
		return
		
	deactivate()

func activate():
	propagate_call("set_deferred", ["disabled", false])
	propagate_call("set_deferred", ["enabled", true])
	show()
	
func deactivate():
	propagate_call("set_deferred", ["disabled", true])
	propagate_call("set_deferred", ["enabled", false])
	hide()

func _on_activated() -> void:
	activate()

func _on_deactivated() -> void:
	deactivate()
