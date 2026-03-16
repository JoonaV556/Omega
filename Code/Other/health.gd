class_name Health
extends Node

signal on_depleted

@export var start_health: 	float = 100.0
@export var max_health: 	float = 100.0
var health: 				float

func _ready() -> void:
	health = start_health

func damage(amount: float):
	if (health - amount) <= 0.0:
		on_depleted.emit()
		health = 0
