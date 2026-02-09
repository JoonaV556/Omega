@tool
class_name SingleInventoryView
extends InventoryView

const InventorySlotInstance = preload("res://Scenes/Inventory/InventorySlot.tscn")
const SingleInventoryViewInstance = preload("res://Scenes/Inventory/SingleInventoryView.tscn")

var loaded_inventory: Inventory

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		var inventory = Inventory.new()
		
		var test_item_stack = ItemStack.new()
		test_item_stack.set_quantity(1)
		inventory.add(test_item_stack)
		
		load_inventory(inventory)

func load_inventory(inventory: Inventory):
	loaded_inventory = inventory
	var grid = $PanelContainer/CenterContainer/MarginContainer/Grid
	
	for child in grid.get_children():
		grid.remove_child(child)
	
	grid.columns = inventory.columns
	
	var slot
	for i in range(inventory.get_size()):
		var stack = inventory.get_stack(i)
		slot = InventorySlotInstance.instantiate()
		grid.add_child(slot)
		slot.name = "InventorySlot" + str(i)
		slot.set_stack(stack)
		slot.stack = stack
		slot.gui_input.connect(_handle_item_gui_input.bind(int(i)))
		slot.mouse_entered.connect(_handle_slot_mouse_entered.bind(int(i)))
		slot.mouse_exited.connect(_handle_slot_mouse_exited)
		
		if Engine.is_editor_hint():
			slot.owner = get_tree().edited_scene_root

func get_slot_with_index(index: int):
	return $PanelContainer/CenterContainer/MarginContainer/Grid.get_node("InventorySlot" + str(index))

func _handle_item_gui_input(event: InputEvent, index: int):
	if event is not InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.pressed and selected_slot == null:
		_handle_item_grabbed(index)
	elif not event.pressed:
		_handle_item_dropped()
		
func _handle_item_grabbed(slot_index: int):
	var slot = get_slot_with_index(slot_index)
	set_selected_slot(slot)
	slot.hide_item()

func _return_grabbed_item_to_original_slot():
	selected_slot.show_item()
	clear_selected_slot()

func _handle_item_dropped():
	if selected_slot == null or not selected_slot.has_item(): return
	if hover_slot == null or hover_slot == selected_slot:
		_return_grabbed_item_to_original_slot()
		return
	
	var nr_items_transferred = hover_slot.try_add_items_from_slot(selected_slot)
	if nr_items_transferred == 0: # Couldn't add items
		switch_items_in_slots(hover_slot, selected_slot)
	else:
		selected_slot.remove_items(nr_items_transferred)
	
	hover_slot.show_item()
	selected_slot.show_item()
	
	clear_selected_slot()
		
func _handle_slot_mouse_entered(index: int):
	set_hover_slot(get_slot_with_index(index))

func _handle_slot_mouse_exited():
	set_hover_slot(null)
