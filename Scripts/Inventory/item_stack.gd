class_name ItemStack
extends Node2D

@export var item: Item
@export var quantity: int

func has_item() -> bool:
	return item != null

## Returns whether this stack has the same item as the given stack. Also returns true if neither of the stacks (this and the given stack) have an item.
func has_same_item(another: ItemStack):
	var self_has_item = has_item()
	var another_has_item = another.has_item()
	if not self_has_item and not another_has_item: return true
	if not self_has_item and another_has_item: return false
	if self_has_item and not another_has_item: return false
	return another.item.scene_file_path == item.scene_file_path
	
func set_item(new_item: Item):
	item = new_item
	if quantity <= 0:
		quantity = 1

func set_quantity(new_quantity: int):
	quantity = new_quantity

## Copies the item and its quantity from the given stack.
func copy_items_from_slot(another: ItemStack):
	if not another.has_item(): 
		set_item(null)
		set_quantity(0)
		return
	set_item(another.item)
	set_quantity(another.quantity)

## Adds as many items from the given stack as possible. 
## If this stack doesn't have an item and the given stack does, adds all the items from the given stack.
## If the this stack and the given stack have a different item (see has_same_item()),
## or this stack's stack is full, does nothing.
## Returns how many items were added.
func try_add_items_from_stack(another: ItemStack) -> int:
	if not has_item() and not another.has_item(): return 0
	if not has_item():
		copy_items_from_slot(another)
		return quantity
	if not has_same_item(another): return 0
	return add(another.quantity)

## Adds the given quantity of items to this stack, or if the item's max_quantity is exceeded, fills the stack.
## Returns how many items were added. 
func add(quantity_to_add: int) -> int:
	if item == null: return 0
	var orig_quantity = quantity
	quantity = min(item.max_stack, quantity+quantity_to_add)
	return quantity-orig_quantity

func add_one():
	add(1)

func remove(quantity_to_remove: int):
	quantity = max(0, quantity-quantity_to_remove)
	if quantity == 0:
		item = null

func remove_one():
	remove(1)

func remove_all():
	remove(quantity)
