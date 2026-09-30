class_name IEDealDamage
extends ImpactEffect


@export var damage: float = 10.0


func on_impact(impact_direction: Vector2, impact_data: Dictionary):
	var hit_node := impact_data["collider"] as Node
	var hit_object_health_component:= hit_node.get_node_or_null("%Health") as Health # scene unique nodes, read more @https://docs.godotengine.org/en/stable/tutorials/scripting/scene_unique_nodes.html
	
	if !hit_object_health_component:
		var children = hit_node.get_children()

		if children.is_empty():
			return

		for c in hit_node.get_children():
			if c is Health:
				hit_object_health_component = c as Health

	if !hit_object_health_component:
		return

	hit_object_health_component.deal_damage(damage)