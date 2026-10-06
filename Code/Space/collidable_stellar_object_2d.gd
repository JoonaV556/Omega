class_name CollidableStellarObject2D
extends StellarObjectSprite2D


func set_radius_pixels(_radius_pixels: float) -> void:
    super(_radius_pixels)

    var shape := get_node("%CollisionShape2D") as CollisionShape2D

    var circle := CircleShape2D.new()
    circle.radius = radius_pixels
    shape.shape  = circle