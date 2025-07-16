class_name Floor
extends Node2D

signal activated
signal deactivated

func _ready():
	activated.connect(_on_activated)
	deactivated.connect(_on_deactivated)
	
	var has_player = false
	for node in get_children():		
		if not node.has_meta("is_player"):
			continue
			
		activate()
		return
		
	deactivate()

func activate():
	propagate_call("set_deferred", ["disabled", false])
	show()
	
func deactivate():
	propagate_call("set_deferred", ["disabled", true])
	hide()

func _on_activated() -> void:
	activate()


func _on_deactivated() -> void:
	deactivate()
