class_name TMoveToRandom
extends Task

var destination_pos: Vector2

var dest_set: bool = false
var map_ready: bool = false
var can_set = false

var nav_map: TileMapLayer

var self_nav_a: NavigationAgent2D
var self_npc: NpcCharacter

func start():
	super.start()
	print("move to random started")

	# retrieve correct nav map id from level
	var scene = get_tree().current_scene
	var level := scene as Level
	nav_map = level.nav_tilemap

	if map_ready:
		set_destination()

	# start moving towards random point once map is ready
	if not NavigationServer2D.map_changed.is_connected(self.on_map_update):
		NavigationServer2D.map_changed.connect(self.on_map_update)

func on_map_update(rid):
	if dest_set:
		return
	if rid != nav_map.get_navigation_map():
		return

	can_set = true

func _physics_process(delta: float) -> void:
	# try set destination
	if can_set:
		# wait until navigation map is ready so we wont get just a zero vector
		var r_point: Vector2 = NavigationServer2D.map_get_random_point(nav_map.get_navigation_map(), 1, false)
		if (abs(r_point.x) < 0.01):
			return

		set_destination()
		map_ready = true
		can_set = false

	if self.completed:
		return
	if not dest_set:
		return
	
	# complete task if target is reached
	if self_nav_a.is_target_reached():
		self_npc.move_dir = Vector2.ZERO
		self.complete()
		print("move-to task complete")
		return

	var next_path_pos: Vector2 = self_nav_a.get_next_path_position()

	# move npc towards target
	self_npc.move_dir = Vector2(next_path_pos - self_npc.global_position)

func set_destination():
	destination_pos = NavigationServer2D.map_get_random_point(nav_map.get_navigation_map(), 1, false)

	# get nav agent 
	var npc := self.get_parent().get_parent() as NpcCharacter
	if !npc:
		push_error("couldnt get ref to NpcParent")
		return
	self_nav_a = npc.nav_agent
	self_npc = npc

	# set target
	if not self_nav_a.is_target_reachable():
		push_error("target not reachable")
		return
	self_nav_a.target_position = destination_pos	
	print("npc target point: "+str(destination_pos))

	dest_set = true
	map_ready = true

