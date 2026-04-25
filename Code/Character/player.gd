class_name Player
extends Character

const BeachBall = preload("res://Scenes/Inventory/Items/BeachBall.tscn")
const Shell = preload("res://Scenes/Inventory/Items/Shell.tscn")

@export_range(0.0,1.0) var additional_impulses_decay_per_tick: float = 0.95

var additional_impulses: Vector2 = Vector2.ZERO

var inventory: Inventory
var journal: Journal

func _ready() -> void:
	super._ready()
	inventory = Inventory.new()
	journal = Journal.new()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Sprint"):
		set_sprinting(true)
	if Input.is_action_just_released("Sprint"):
		set_sprinting(false)

func update_character_physics():
	var input_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	velocity = Vector2(input_direction*self.current_move_speed) + additional_impulses
	# decay impulses
	additional_impulses = additional_impulses*(1.0-additional_impulses_decay_per_tick)

func add_impulse(impulse: Vector2):
	additional_impulses += impulse
	
func _input(_event):
	if Input.is_action_just_released("Open Inventory"):
		GlobalInventoryHandler.open_single_inventory(inventory)
	if Input.is_action_just_released("Open Journal"):
		GlobalJournalHandler.open_journal(journal)