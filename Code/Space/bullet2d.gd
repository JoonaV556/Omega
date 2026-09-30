## Projectile which flies forward in velocity direction and damages objects when it hits them
class_name Bullet2D
extends Projectile2D


@export var damage: float = 10.0

@export_flags_2d_physics var hit_and_damage_layers

@export var impact_effects: Array[ImpactEffect]

var _velocity : Vector2

var _fly = false

var _max_fly_distance : float = 300.0 * 16.0

var _max_fly_distance_squared : float 

var _start_pos : Vector2 = Vector2.ZERO


signal on_hit(position : Vector2, hit_obj : Node)


## Velocity == Fly direction and muzzle velocity in pixels per second
func fire(velocity_direction : Vector2, attach_to : Node, velocity_speed : float = 10.0 * 16.0, max_fly_distance : float = _max_fly_distance):
	_velocity = velocity_direction.normalized() * velocity_speed
	_start_pos = global_position
	_max_fly_distance_squared = max_fly_distance * max_fly_distance
	attach_to.add_child(self)
	_fly = true


func _physics_process(delta: float) -> void:
	if !_fly:
		return

	# Fly forwards, deal damage to hit object, and disappear.
	var prev_pos: Vector2 = self.global_position
	var next_pos: Vector2 = self.global_position + (_velocity.normalized() * _velocity.length() * delta)

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(prev_pos, next_pos, hit_and_damage_layers)

	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.hit_from_inside = true

	# Exclude some obejcts from being hit by the bullet
	var query_rids = query.exclude
	query_rids = rids_to_exclude
	query.exclude = query_rids

	var hit_result: Dictionary = space_state.intersect_ray(query)
	
	# Hit nothing, continue flying 
	if hit_result.is_empty(): 
		self.global_position = next_pos
		
		var distance_flown_squared : float = global_position.distance_squared_to(_start_pos)
		# Disappear if flown for too long
		if distance_flown_squared > _max_fly_distance_squared:
			self._fly = false
			self.queue_free()
			return
		return

	# Hit something. activate impacteffects
	if impact_effects:
		for ef in impact_effects:
			var impact_dir = prev_pos.direction_to(next_pos).normalized()
			ef.on_impact(impact_dir, hit_result)

	var hit_node := hit_result["collider"] as Node

	on_hit.emit(hit_result["position"], hit_node)

	# Disappear
	global_position = hit_result["position"]
	self._fly = false
	self.queue_free()
