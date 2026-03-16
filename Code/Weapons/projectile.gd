class_name Projectile
extends Node2D

@export var damage: float = 10
@export var velocity: float = 0.1
var fired:bool = false

func fire(_fly_direction:Vector2, _velocity) -> void:
	self.global_rotation = _fly_direction.angle()
	self.velocity = _velocity
	fired = true

func _process(delta: float) -> void:
	if not fired:
		return
	self.global_position = self.global_position + (self.transform.x.normalized() * self.velocity) 
