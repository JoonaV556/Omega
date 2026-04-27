class_name MeleeAttack
extends Node2D

## Phys layers the attack will affect
@export_flags_2d_physics var attack_layers = (1 << 3 - 1) # tick layer 3 by deflt.
@export var damage: float = 50.0
## pixels
@export var attack_circle_radius: float = 8.0
## pixels
@export var attack_range: float = 10.0
## secs
@export var cooldown_duration: float = 1.0


var cooldown_left: float

var shape_query
var space_state

func _ready():
	# preconfig physics queries
	shape_query = PhysicsShapeQueryParameters2D.new()
	shape_query.collision_mask = attack_layers	
	shape_query.collide_with_bodies = true

	# ignore self in phys queries
	var co := get_parent() as CollisionObject2D
	if co:
		shape_query.exclude = [co.get_rid()]
	else:
		push_error("failed excluding self from queries")

	space_state = get_world_2d().direct_space_state
	

func _process(delta):
	cooldown_left = clampf(cooldown_left - delta, 0.0, 9999.0)

## Attempts an attack in the direction of target_pos. Returns true if attack hits something [br]
## CANNOT BE CALLED OUTSIDE OF _physics_process():
func attack_in_direction(target_pos: Vector2) -> bool:
	if cooldown_left > 0.01:
		return false

	# create circle shape for the query 
	var shape_rid = PhysicsServer2D.circle_shape_create()
	var radius = attack_circle_radius
	PhysicsServer2D.shape_set_data(shape_rid, radius)
	shape_query.shape_rid = shape_rid
	
	# attack in direction of target
	var attack_pos: Vector2 = self.global_position.direction_to(target_pos) * attack_range
	shape_query.transform.origin = attack_pos # spawn point

	# Execute physics queries here...
	var result: Array[Dictionary] = space_state.intersect_shape(shape_query)

	var hit: bool = !result.is_empty()

	# Damage targets in the attack area
	var damaged = 0
	for dic: Dictionary in result:
		var hit_collider: CollisionObject2D = dic["collider"]

		# deal damage
		var dealt_dmg = false
		var health := hit_collider.get_node("%Health") as Health
		if health:
			health.deal_damage(self.damage)
			damaged += 1
			dealt_dmg = true

		# impair target movement
		var _sfr := hit_collider.get_node_or_null("%StatusEffectReceiver") as StatusEffectReceiver
		if dealt_dmg and _sfr:
			var ef: StatusEffect = SEImpairMovement.new(1.0)
			_sfr.apply_effect(ef)

		# fire event for sfx. etc.
		if dealt_dmg:
			GlobalEventBus.on_melee_attack.emit(hit_collider.global_position)

	print("damaged "+str(damaged)+ " objects in attack area")

	# Release the shape when done with physics queries.
	PhysicsServer2D.free_rid(shape_rid)
	
	cooldown_left = cooldown_duration

	return hit
