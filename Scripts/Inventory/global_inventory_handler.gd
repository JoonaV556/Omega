extends Node

const SingleInventoryViewInstance = preload("res://Scenes/Inventory/SingleInventoryView.tscn")

var single_inventory_view: SingleInventoryView

func _ready():
	single_inventory_view = SingleInventoryViewInstance.instantiate()
	
	add_child(single_inventory_view)
	single_inventory_view.hide()
	
func open_single_inventory(inventory: Inventory):
	single_inventory_view.set_inventory(inventory)
	single_inventory_view.show()
