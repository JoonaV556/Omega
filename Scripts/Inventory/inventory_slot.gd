@tool
class_name InventorySlot
extends NinePatchRect

var stack: ItemStack

@onready var item_icon = $MarginContainer/ItemIcon
@onready var quantity = $MarginContainer/Quantity

func _ready():
	if Engine.is_editor_hint():
		var test_item = Item.new()
		var icon = load("res://icon.svg")
		test_item.set_icon(icon)
		var test_stack = ItemStack.new()
		test_stack.set_item(test_item)
		set_stack(test_stack)
	else: 
		clear()

func has_item() -> bool:
	return stack != null and stack.has_item()
	
## Returns whether this slot has the same item as the given slot. Returns true if neither of the slots (this and the given slot) have an item.
func has_same_item(slot: InventorySlot) -> bool:
	if stack == null and slot.stack == null: return true
	return stack.has_same_item(slot.stack)
	
## Adds as many items from the given slot as possible. If it's not possible to add items from the given slot, does nothing and returns 0.
## Returns how many items were added to this slot.
## See ItemStack.add_items_from_stack() for more details.
func try_add_items_from_slot(slot: InventorySlot) -> int:
	if not slot.has_item(): return 0
	if stack == null: stack = ItemStack.new()
	var nr_added = stack.try_add_items_from_stack(slot.stack)
	update_stack_visuals()
	return nr_added
	
func remove_items(quantity_to_remove: int):
	if not has_item(): return
	stack.remove(quantity_to_remove)
	if stack.quantity == 0:
		clear()
	else:
		update_stack_visuals()

func set_stack(new_stack: ItemStack):
	stack = new_stack
	update_stack_visuals()

func update_stack_visuals():
	if stack == null or not stack.has_item():
		item_icon.texture = null
		quantity.text = ""
	else:
		item_icon.texture = stack.item.icon
		quantity.text = str(stack.quantity)

func clear():
	item_icon.texture = null
	quantity.text = ""
	stack = ItemStack.new()

func hide_item():
	if stack == null or not stack.has_item(): return
	item_icon.hide()
	quantity.hide()
	
func show_item():
	if stack == null or not stack.has_item(): return
	item_icon.show()
	quantity.show()

func get_icon_size() -> Vector2:
	return item_icon.size
