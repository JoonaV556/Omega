class_name IEDealKnockback
extends ImpactEffect

@export var knockback_force_strength: float = 100.0


func on_impact(impact_direction: Vector2, impact_data : Dictionary):
    var hit_node = impact_data["collider"] as Node

    if !hit_node:
        return

    var rb = hit_node as RigidBody2D

    if !rb:
        return

    var impact_position_offset = impact_data["position"] - rb.global_position

    rb.apply_impulse(
        impact_direction * knockback_force_strength, 
        impact_position_offset
        )