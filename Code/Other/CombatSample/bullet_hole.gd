class_name BulletHole
extends Sprite2D

@export var life_duration: float = 6.0
var lifetime = 0.0

func _process(delta):
    lifetime += delta
    if lifetime > life_duration:
        self.queue_free()