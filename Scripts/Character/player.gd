class_name Player
extends Character

@export var speed = 400

var inventory: Inventory

func _ready():
	inventory = Inventory.new()

func update_character_physics():
	var input_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	velocity = input_direction * speed
	
func _input(event):
	if Input.is_action_just_released("Open Inventory"):
		GlobalInventoryHandler.open_single_inventory(inventory)
