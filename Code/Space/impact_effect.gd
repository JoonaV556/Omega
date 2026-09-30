class_name ImpactEffect
extends Resource

## Impact direction is the direction in global space from where the impacted object was hit from. [br]
## impact_data is a dictionary[string, val] with the following fields: [br] 
## collider: The colliding object. [br]
## collider_id: The colliding object's ID. [br]
## normal: The object's surface normal at the intersection point,
## or Vector2(0, 0) if the ray starts inside the shape and PhysicsRayQueryParameters2D.hit_from_inside is true. [br] 
## position: The intersection point. [br]
## rid: The intersecting object's RID. [br]
## shape: The shape index of the colliding shape. If the ray did not intersect anything, then an empty dictionary is returned instead.
func on_impact(impact_direction: Vector2, impact_data : Dictionary):
    pass