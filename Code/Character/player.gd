class_name Player
extends Character

const BeachBall = preload("res://Scenes/Inventory/Items/BeachBall.tscn")
const Shell = preload("res://Scenes/Inventory/Items/Shell.tscn")

@export var speed = 100

var inventory: Inventory
var journal: Journal

func _ready():
	inventory = Inventory.new()
	journal = Journal.new()

func update_character_physics():
	var input_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	velocity = input_direction * speed
	
func _input(_event):
	if Input.is_action_just_released("Open Inventory"):
		GlobalInventoryHandler.open_single_inventory(inventory)
	if Input.is_action_just_released("Open Journal"):
		GlobalJournalHandler.open_journal(journal)
