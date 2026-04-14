class_name GunfireKnockback
extends Node

@export var target: Player
@export var knockback_force: float = 100.0

var dir: Vector2
var pending = false

func deal_knockback(fire_dir: Vector2):
    target.add_impulse(Vector2(fire_dir*-1).normalized() * knockback_force)
