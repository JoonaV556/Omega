extends Node

const SingleInventoryUIInstance = preload("res://Scenes/Inventory/SingleInventoryUI.tscn")

var single_inventory_ui: SingleInventoryUI

func _ready():
	single_inventory_ui = SingleInventoryUIInstance.instantiate()
	
	add_child(single_inventory_ui)
	single_inventory_ui.hide()
	
func open_single_inventory(inventory: Inventory):
	single_inventory_ui.load_inventory(inventory)
	single_inventory_ui.show()
