class_name Interactor
extends Area2D

var interact_obj = null

func _ready():
	set_process_input(true)

func _on_body_entered(body: Node2D):
	if body is not Interactable:
		return
		
	body.interact_available.emit()
	interact_obj = body
	
		
func _on_body_exited(body: Node2D):
	if body is not Interactable:
		return
		
	body.interact_unavailable.emit()
	interact_obj = body

func _input(event):
	if interact_obj == null:
		return
	if Input.is_key_pressed(KEY_E):
		interact_obj.interact.emit()
