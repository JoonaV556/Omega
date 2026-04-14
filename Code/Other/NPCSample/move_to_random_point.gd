class_name TMoveToRandom
extends Task

var destination_pos: Vector2

var dest_set: bool = false
var map_ready: bool = false
var map_rid: int

var nav_map: TileMapLayer

var self_nav_a: NavigationAgent2D
var self_npc: NpcCharacter

func start():
	super.start()

	# retrieve correct nav map id from level
	var scene = get_tree().current_scene
	var level := scene as Level
	nav_map = level.nav_tilemap

	# start moving towards random point once map is ready
	if map_ready:
		set_destination()
		return
		
	# start moving towards random point once map is ready
	NavigationServer2D.map_changed.connect(self.on_map_update)

func on_map_update(rid):
	if dest_set:
		return
	if rid != nav_map.get_navigation_map():
		return
	
	set_destination()
	
func set_destination():
	destination_pos = NavigationServer2D.map_get_random_point(nav_map.get_navigation_map(), 1, false)
	print("random target point: "+str(destination_pos))

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
	
	dest_set = true
	map_ready = true

func _physics_process(delta: float) -> void:
	if self.completed:
		return
	if not dest_set:
		return
	
	# complete task if target is reached
	if self_nav_a.is_target_reached():
		self_npc.move_dir = Vector2.ZERO
		self.completed = true
		print("move-to task complete")
		return

	var next_path_pos: Vector2 = self_nav_a.get_next_path_position()

	# move npc towards target
	self_npc.move_dir = Vector2(next_path_pos - self_npc.global_position)
