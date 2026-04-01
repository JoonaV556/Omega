class_name Bullet
extends Node2D

@export var damage: float = 10
@export_flags_2d_physics var raycast_mask
@export var enable_bullet_holes: bool = true
@export var bullet_hole_prefab: PackedScene

var can_update: bool = false
var velocity: float
## pixels
var cast_ahead_distance: float = 3.0
var debug_draw_circle = false
@export var draw_debug_circle_override = false

# velocity in pixels per second. 16px ~= 1 meter
func fire(_fly_direction:Vector2, _velocity, _debug_draw_circle: bool = false) -> void:
	self.global_rotation = _fly_direction.angle() # align to fire dir
	self.velocity = _velocity
	can_update = true
	self.debug_draw_circle = _debug_draw_circle

func _physics_process(delta: float) -> void:
	if !can_update:
		return

	var prev_pos: Vector2 = self.global_position
	var next_pos: Vector2 = self.global_position + (self.global_transform.x.normalized() * self.velocity * delta)

	# raycast from new position to last position
	var vector: Vector2 = prev_pos + ((next_pos-prev_pos)*cast_ahead_distance)
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(prev_pos, vector, raycast_mask)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.hit_from_inside = true
	var result: Dictionary = space_state.intersect_ray(query)

	if result.is_empty(): 
		# if no obstacles, can_update ahead
		self.global_position = next_pos
	else:
		if debug_draw_circle or draw_debug_circle_override:
			var circle = DebugCircle.new(2.0)
			get_tree().current_scene.add_child(circle)
			circle.global_position = result["position"]
		# try to deal damage
		var _damageable := result["collider"] as StaticDamageable
		if _damageable:
			_damageable.health.deal_damage(self.damage)
		
		# spawn bullet hole
		if (bullet_hole_prefab and !_damageable):
			var hole_node = bullet_hole_prefab.instantiate()
			self.get_tree().current_scene.add_child(hole_node)
			var hole := hole_node as BulletHole
			if hole:
				hole.global_position = result["position"]

		# destroy self
		self.global_position = result["position"]
		self.can_update = false
		self.queue_free()