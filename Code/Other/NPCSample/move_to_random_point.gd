class_name TMoveToRandom
extends Task

var target_pos: Vector2

func start():
	# get random accessible point once nav map is ready
	NavigationServer2D.map_changed.connect(self.get_pos)

	# calculate a path to it

	pass

func get_pos(rid):
	var scene = get_tree().current_scene
	var level := scene as Level
	var nav_map: TileMapLayer
	# if !level:
	# 	return
	nav_map = level.nav_tilemap
	
	if rid != nav_map.get_navigation_map():
		return
	
	# if !nav_map:
	# 	return
	target_pos = NavigationServer2D.map_get_random_point(nav_map.get_navigation_map(), 1, false)
	print("random target point: "+str(target_pos))
	var npc: Node2D = self.get_parent().get_parent()
	print("closest point: "+str(NavigationServer2D.map_get_closest_point(nav_map.get_navigation_map(), npc.global_position)))

func update():
	# feed vector pointing towards target to character controller
	pass
