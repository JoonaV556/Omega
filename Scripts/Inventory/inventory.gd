class_name Inventory
extends Node2D

const InventorySlotInstance = preload("res://Scenes/Inventory/InventorySlot.tscn")

var rows: int = 3
var columns: int = 10

var items: Array[ItemStack] = []

func _init() -> void:
	items.resize(rows*columns)

func set_size(rows: int, columns: int):
	self.rows = rows
	self.columns = columns
	items.resize(rows*columns)
