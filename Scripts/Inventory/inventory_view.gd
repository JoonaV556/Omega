class_name InventoryView
extends CanvasLayer

var selected_slot: InventorySlot # Which slot has an item been selected (dragged) from
var hover_slot: InventorySlot # Which slot is the mouse hovering over
var cursor_icon: TextureRect # The icon that shows up next to the mouse after an item is selected

func _ready():
	cursor_icon = TextureRect.new()
	cursor_icon.name = "InventoryCursorIcon"
	add_child(cursor_icon)
	# Without this, when the mouse is (slowly) moving right with an item selected, Godot thinks that the texture rect is
	# in front of the slot and doesn't emit a mouse entered/exited signal
	cursor_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event):
	if Input.is_action_just_released("Close Inventory"):
		hide()
		
	if selected_slot != null and event is InputEventMouseMotion:
		update_cursor_position(event.position)	

func slot_has_item(slot: InventorySlot) -> bool:
	if slot == null: return false
	if slot.stack == null: return false
	if slot.stack.item == null: return false
	return true

func update_cursor_position(position: Vector2):
	cursor_icon.position = position

func clear_cursor_icon():
	cursor_icon.texture = null

func update_cursor_icon():
	if not slot_has_item(selected_slot): return
	
	cursor_icon.texture = selected_slot.stack.item.icon
	cursor_icon.set_size(selected_slot.get_icon_size())
	update_cursor_position(get_viewport().get_mouse_position())
	
## Sets selected_slot to the given value and enables a cursor icon representing the item in the slot
func set_selected_slot(slot: InventorySlot):
	if not slot_has_item(slot): return
	
	selected_slot = slot
	update_cursor_icon()
	
## Sets selected_slot to null and clears the cursor icon
func clear_selected_slot():
	selected_slot = null
	clear_cursor_icon()

func set_hover_slot(slot: InventorySlot):
	hover_slot = slot

func switch_items_in_slots(slot1: InventorySlot, slot2: InventorySlot):
	var current_stack_in_hover_slot = hover_slot.stack
	hover_slot.set_stack(selected_slot.stack)
	selected_slot.set_stack(current_stack_in_hover_slot)
