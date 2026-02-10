class_name Inventory
extends Node2D

const InventorySlotInstance = preload("res://Scenes/Inventory/InventorySlot.tscn")

var rows: int = 3
var columns: int = 10

var items: Array[ItemStack]

func _init() -> void:
	init_with_size(rows*columns)

func init_with_size(size: int):
	items = []
	items.resize(size)
	for i in range(size):
		items.set(i, ItemStack.new())

func get_size():
	return items.size()
	
func resize(nr_rows: int, nr_columns: int): # Resizes the inventory. Warning: at the moment, this discards all items in the inventory. To be fixed
	rows = nr_rows
	columns = nr_columns
	init_with_size(rows*columns)

func get_stack(index: int) -> ItemStack:
	return items[index]

func insert(stack: ItemStack, index: int) -> ItemStack: # Adds the given item stack to the inventory to the given 1D index. If a stack with an item already exists in the given index, replaces that stack. Returns the stack that was in the index originally.
	var existing_stack = items[index]
	items[index] = stack
	return existing_stack

func add(stack: ItemStack): # Adds an item to the first available slot in the inventory. Does nothing if inventory full
	for i in range(items.size()):
		if items[i].has_item():
			continue
		
		items[i] = stack
		return

func discard_one(index: int): # Discards a single item from the stack with the given 1D index
	if not items[index].has_item():
		return
		
	items[index].remove_one()

func discard_stack(index: int): # Discards the whole stack in the given 1D index
	items[index] = ItemStack.new()
