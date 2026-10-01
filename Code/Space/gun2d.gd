class_name Gun2D
extends Node2D

@export var projectile_scene : PackedScene

@export var projectile_node : Projectile2D

@export var collision_object_to_ignore_for_hits : CollisionObject2D


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Fire"):
		fire()


func fire():
	var _spawned_projectile : Node
	
	if projectile_scene:
		_spawned_projectile = projectile_scene.instantiate()

	if !projectile_scene and projectile_node:
		_spawned_projectile = projectile_node.duplicate() 
		_spawned_projectile.show()

	if !_spawned_projectile:
		return

	if _spawned_projectile is not Projectile2D:
		_spawned_projectile.queue_free()
		return

	var _projectile_node = _spawned_projectile as Projectile2D
	_projectile_node.global_position = global_position
	_projectile_node.global_rotation = global_rotation

	var p_parent = get_canvas_layer_node()

	if !p_parent:
		p_parent = get_tree()

	# Prevent shooting ourselves
	if collision_object_to_ignore_for_hits:
		_projectile_node.rids_to_exclude = []
		_projectile_node.rids_to_exclude.append(collision_object_to_ignore_for_hits.get_rid())

	_projectile_node.fire(-global_transform.y, p_parent)
