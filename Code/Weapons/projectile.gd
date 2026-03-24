class_name Projectile
extends RigidBody2D

@export var damage: 	float = 10
var pending_velocity: 	Vector2
var fired:				bool = false
var velocity_set:		bool = false

signal on_hit_something

func _ready() -> void:
	self.body_entered.connect(self.on_body_entered)

func fire(_fly_direction:Vector2, _velocity) -> void:
	self.global_rotation = _fly_direction.angle() # align to fire dir
	pending_velocity = _fly_direction.normalized() * _velocity
	fired = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not fired:
		return
	if velocity_set == true:
		return
	#launch projectile 
	state.linear_velocity = pending_velocity
	velocity_set = true

func on_body_entered(other_node: Node):
	# deal damage to the object if possible
	var _damageable := other_node as StaticDamageable
	if _damageable:
		_damageable.health.damage(self.damage)
	
	# destroy self
	self.on_hit_something.emit()
	self.queue_free()
