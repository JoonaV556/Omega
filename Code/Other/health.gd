class_name Health
extends Node

signal on_depleted
signal on_revived

@export var start_health: 	float = 100.0
@export var max_health: 	float = 100.0
var health: 				float

var is_dead: bool = false

func _ready() -> void:
	health = start_health
	is_dead = false

func deal_damage(amount: float):
	if (health - amount) <= 0.0:
		is_dead = true
		health = 0
		on_depleted.emit()
	else:
		health -= amount

func revive():
	is_dead = false
	health = max_health
	on_revived.emit()
