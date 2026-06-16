class_name Health
extends Node

signal on_depleted
signal on_revived
signal on_hp_updated(hp, max_hp)

@export var start_health: 	float = 100.0
@export var max_health: 	float = 100.0
var health: 				float

var is_dead: bool = false

func _ready() -> void:
	health = start_health
	is_dead = false

	on_hp_updated.emit(health, max_health)

func deal_damage(amount: float):
	if is_dead:
		return
	if (health - amount) <= 0.0:
		is_dead = true
		health = 0
	else:
		health -= amount

	on_hp_updated.emit(health, max_health)

func revive():
	is_dead = false
	health = max_health
	on_revived.emit()

	on_hp_updated.emit(health, max_health)
