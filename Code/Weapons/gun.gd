class_name Gun
extends Node2D

signal on_shot_fired(fire_dir)
signal on_shot_fired_e
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
## rounds per minute. changing at runtime not yet supported
@export var rpm: int = 600
@export var start_firemode: FireMode = FireMode.SEMI

var bullets_in_chamber:int

var reloading = false

var current_fire_mode: FireMode = FireMode.SEMI

var time_between_shots: float

var secs_since_last_shot: float = 99999.0

enum FireMode {SEMI, FULL, BURST}

func _ready() -> void:
	time_between_shots = 1.0/float(rpm/60.0)
	current_fire_mode = start_firemode
	bullets_in_chamber = bullets_start
	on_ammo_updated.emit(bullets_in_chamber, magazine_size)

func _process(delta: float) -> void:
	secs_since_last_shot = clampf(secs_since_last_shot+delta, 0.0, 99999.0)
	
	if Input.is_action_just_pressed("Fire"): 
		if bullets_in_chamber <= 0:
			on_dry_fire.emit()

	# fire gun 
	match current_fire_mode:
		FireMode.SEMI:
			if secs_since_last_shot < time_between_shots:
				return
			if Input.is_action_just_pressed("Fire"):
				fire()
		FireMode.FULL:
			if secs_since_last_shot < time_between_shots:
				return
			if Input.is_action_pressed("Fire"):
				fire()
		FireMode.BURST:
			push_warning("burst not implemented")

	if Input.is_action_just_pressed("Reload"):
		reload()

func fire():
	if reloading:
		return
	if bullets_in_chamber <= 0:
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
	secs_since_last_shot = 0.0
	on_shot_fired.emit(self.global_transform.x.normalized())
	on_shot_fired_e.emit()
	on_ammo_updated.emit(bullets_in_chamber, magazine_size)

func reload():
	reloading = true
	await get_tree().create_timer(reload_duration).timeout
	bullets_in_chamber = magazine_size
	on_ammo_updated.emit(bullets_in_chamber, magazine_size)
	reloading = false