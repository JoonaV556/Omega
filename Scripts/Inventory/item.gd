class_name Item
extends Node2D

@export var item_name: String
@export var icon: Texture2D
@export var max_stack: int

func _ready():
	if icon == null:
		push_warning("Item ", self, " does not have an icon")
	else: 
		$Icon.texture = icon

func set_icon(new_icon: Texture2D):
	icon = new_icon
