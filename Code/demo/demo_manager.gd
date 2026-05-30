extends Node

@export var player: Player
@export var intro_dialogue: TimelineStarter
@export var cutscene_bg: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.disable_movement()
	player.visible = false
	
	# start dialogue 
	intro_dialogue.start()
	await Dialogic.timeline_ended
	cutscene_bg.hide()

	# spawn house level and place player in the house
	var l_blue_h: Level = LevelManager.instance.load_level(LevelManager.level_name.blue_house)
	player.global_position = l_blue_h.player_start_position.global_position
	l_blue_h.player_start_position.get_parent().visible = true	
	
	get_tree().current_scene.move_child(player, -1)
	player.enable_movement()
	player.visible = true
