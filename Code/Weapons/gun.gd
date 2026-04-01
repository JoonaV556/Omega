class_name Gun
extends Node2D

signal on_shot_fired(fire_dir)
signal on_reload_start
signal on_reload_complete
signal on_dry_fire
signal on_ammo_updated(ammo, max_ammo)

@export var bullet_prefab: PackedScene

@export var magazine_size:int = 12
@export var bullets_start:int = 12
## velocity in pixels per second. 16px ~= 1 meter
@export var bullets_velocity:float = 0.1
@export var bullet_spawn_pivot: Node2D
## seconds
@export var reload_duration: float = 1.0

var bullets_in_chamber:int
var reloading = false

func _ready() -> void:
	bullets_in_chamber = bullets_start
	on_ammo_updated.emit(bullets_in_chamber, magazine_size)

func _process(delta: float) -> void:
	# fire if fire key is pressed
	if Input.is_action_just_pressed("Fire"):
		fire()
	if Input.is_action_just_pressed("Reload"):
		reload()

func fire():
	if reloading:
		return
	if bullets_in_chamber <= 0:
		on_dry_fire.emit()
		return
	
	# spawn projectile
	var _bullet_node = bullet_prefab.instantiate()
	get_tree().current_scene.add_child(_bullet_node)
	# fire projectile
	var _bullet := _bullet_node as Bullet
	if not _bullet:
		return
	if bullet_spawn_pivot:
		_bullet.global_position = bullet_spawn_pivot.global_position
	else:
		_bullet.global_position = self.global_position
	_bullet.fire(self.global_transform.x.normalized(), self.bullets_velocity)
	
	bullets_in_chamber -= 1
	on_shot_fired.emit(self.global_transform.x.normalized())
	on_ammo_updated.emit(bullets_in_chamber, magazine_size)

func reload():
	reloading = true
	await get_tree().create_timer(reload_duration).timeout
	bullets_in_chamber = magazine_size
	on_ammo_updated.emit(bullets_in_chamber, magazine_size)
	reloading = false