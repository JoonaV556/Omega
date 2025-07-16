class_name InventorySlot
extends NinePatchRect

static func create(item: Item) -> InventorySlot:
	var slot = InventorySlot.new()
	slot.set_item(item)
	return slot

func set_item(item: Item):
	if item == null: return
	$MarginContainer/ItemIcon.texture = item.icon
