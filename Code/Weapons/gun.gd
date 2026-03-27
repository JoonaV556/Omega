class_name Gun
extends Node2D

signal on_shot_fired
signal on_reload_start
signal on_reload_complete
signal on_dry_fire

@export var projetile_prefab: PackedScene

@export var magazine_size:int = 12
@export var bullets_start:int = 12
## velocity in pixels per second. 16px ~= 1 meter
@export var bullets_velocity:float = 0.1

var bullets_in_chamber:int

func _ready() -> void:
	bullets_in_chamber = bullets_start

func _process(delta: float) -> void:
	# fire if fire key is pressed
	if Input.is_action_just_pressed("Fire"):
		fire()
	if Input.is_action_just_pressed("Reload"):
		reload()

func fire():
	if bullets_in_chamber <= 0:
		on_dry_fire.emit()
		return
	
	# spawn projectile
	var _projectile_node = projetile_prefab.instantiate()
	get_tree().current_scene.add_child(_projectile_node)
	# fire projectile
	var _projectile := _projectile_node as Projectile
	if not _projectile:
		return
	_projectile.global_position = self.global_position
	_projectile.fire(self.global_transform.x.normalized(), self.bullets_velocity)
	
	bullets_in_chamber -= 1
	on_shot_fired.emit()

func reload():
	bullets_in_chamber = magazine_size
