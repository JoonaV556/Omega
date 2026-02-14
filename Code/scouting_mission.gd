extends Node

class_name ScoutingMission

@export
var level_generator: LevelGenerator
@export
var player: Node2D
@export
var player_placement_pixel_offset: Vector2i = Vector2i(0, 0)

var started: bool = false

func _process(delta: float) -> void:
	if (not started) and (level_generator.g_ready_to_generate == true):
		started = true
		# generate level
		var _level: Level = level_generator.generate_level()
		# draw level
		level_generator.draw_level(_level)
		print_debug("Generated level with size: "+str(_level.road_grid[0].size())+"x"+str(_level.road_grid.size())+" tiles.")
		# pick south entrance
		print_debug("Picking a map entry position for player...")
		var entry_candidates: Array[int]
		for _x in range(_level.road_grid[0].size()):
			if _level.road_grid[-1][_x] == true:
				entry_candidates.append(_x)
		var entry_x = entry_candidates.pick_random()
		print_debug("Found "+str(entry_candidates.size())+" possible map entry points (2-wide roads caount as 2 points). Picked node at "+str(entry_x)+", 0 (x,y)")
		# place player on south entrance
		player.global_position = Vector2(
				((entry_x * 16) + player_placement_pixel_offset.x), # tilemap tile is 16x16px
				(player_placement_pixel_offset.y)
			)
