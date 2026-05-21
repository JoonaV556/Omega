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
## degrees
@export var max_bullet_spread_angle: float = 5.0
## seconds
@export var recoil_cooldown_duration: float = 1.0
@export var recoil_alpha_increase_per_shot: float = 0.07
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

var bullet_spread_alpha: float = 0.0

var rng: RandomNumberGenerator

enum FireMode {SEMI, FULL, BURST}

func _ready() -> void:
	time_between_shots = 1.0/float(rpm/60.0)
	current_fire_mode = start_firemode
	bullets_in_chamber = bullets_start
	on_ammo_updated.emit(bullets_in_chamber, magazine_size)
	rng = RandomNumberGenerator.new()

func _process(delta: float) -> void:
	secs_since_last_shot = clampf(secs_since_last_shot+delta, 0.0, 99999.0)

	# reset bullet spread / recoil
	if secs_since_last_shot > recoil_cooldown_duration:
		bullet_spread_alpha = 0.0
		
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

	if Input.is_action_just_pressed("Reload") and !reloading:
		reload()

func fire():
	if reloading:
		return
	if bullets_in_chamber <= 0:
		return

	# spawn projectile
	var _bullet_node = bullet_prefab.instantiate()
	get_tree().current_scene.add_child(_bullet_node)
	get_tree().current_scene.move_child(_bullet_node, -1)
	
	
	# fire projectile
	var _bullet := _bullet_node as Bullet
	if not _bullet:
		return
	if bullet_spawn_pivot:
		_bullet.global_position = bullet_spawn_pivot.global_position
	else:
		_bullet.global_position = self.global_position

	# increase spread on consecutive shots
	if secs_since_last_shot < recoil_cooldown_duration:
		bullet_spread_alpha = clampf(bullet_spread_alpha + recoil_alpha_increase_per_shot, 0.0, 1.0)
	
	# calculate bullet spread
	var rand_bool: bool = randi() % 2 == 0 # negative or positive angle
	var actual_spread_alpha: float = rng.randf_range(0.0, bullet_spread_alpha) # TODO - maybe cache some random spreads in array instead of generating them on each shot at runtime
	var spread_angle_degs: float
	if rand_bool:
		spread_angle_degs = deg_to_rad(max_bullet_spread_angle * actual_spread_alpha)
	else:
		spread_angle_degs = deg_to_rad(-max_bullet_spread_angle * actual_spread_alpha)
	var fire_dir: Vector2 = self.global_transform.x.normalized().rotated(spread_angle_degs)

	# fire the bullet
	_bullet.fire(fire_dir, self.bullets_velocity)

	
	bullets_in_chamber -= 1
	secs_since_last_shot = 0.0
	on_shot_fired.emit(self.global_transform.x.normalized())
	on_shot_fired_e.emit()
	on_ammo_updated.emit(bullets_in_chamber, magazine_size)

func reload():
	reloading = true
	on_reload_start.emit()
	await get_tree().create_timer(reload_duration).timeout
	bullets_in_chamber = magazine_size
	on_ammo_updated.emit(bullets_in_chamber, magazine_size)
	reloading = false
	on_reload_complete.emit()
