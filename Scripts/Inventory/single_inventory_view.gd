class_name SingleInventoryView
extends InventoryView

const InventorySlotInstance = preload("res://Scenes/Inventory/InventorySlot.tscn")
const SingleInventoryViewInstance = preload("res://Scenes/Inventory/SingleInventoryView.tscn")

func set_inventory(inventory: Inventory):
	var grid = $PanelContainer/CenterContainer/MarginContainer/Grid
	
	for child in grid.get_children():
		grid.remove_child(child)
	
	grid.columns = inventory.columns
	
	var item
	var slot
	for stack in inventory.items:
		item = null
		if stack != null and stack.item != null:
			item = stack.item
			
		slot = InventorySlotInstance.instantiate()
		slot.set_item(item)
		grid.add_child(slot)
	
