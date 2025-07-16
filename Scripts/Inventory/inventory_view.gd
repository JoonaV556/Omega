class_name InventoryView
extends CanvasLayer

func _input(event):
	if Input.is_action_just_released("Close Inventory"):
		hide()
