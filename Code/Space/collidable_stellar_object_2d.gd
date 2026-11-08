class_name CollidableStellarObject2D
extends StellarObjectSprite2D


var nav_obst: NavigationObstacle2D

func set_radius_pixels(_radius_pixels: float) -> void:
	super(_radius_pixels)

	var shape := get_node("%CollisionShape2D") as CollisionShape2D

	var circle := CircleShape2D.new()
	circle.radius = radius_pixels
	shape.shape  = circle

	# affect navigation
	nav_obst = get_node('%NavigationObstacle2D') as NavigationObstacle2D
	nav_obst.radius = _radius_pixels
