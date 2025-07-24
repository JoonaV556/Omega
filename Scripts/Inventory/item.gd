class_name Item
extends Node2D

@export var item_name: String
@export var icon: Texture2D
@export var max_stack: int

func _init(itm_name: String = "", item_icon: Texture2D = null, item_max_stack: int = 100):
	item_name = itm_name
	icon = item_icon
	max_stack = item_max_stack

func _ready():
	if icon == null:
		push_warning("Item ", self, " does not have an icon")
	else: 
		$Icon.texture = icon

func set_icon(new_icon: Texture2D):
	icon = new_icon
