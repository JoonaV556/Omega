extends Node

@export var player: Player
@export var intro_dialogue: DialogueStarter
@export var cutscene_bg: CanvasLayer
@export var intro_layer: Node2D


func on_lvl_loaded(lvl_name: StringName):
	if lvl_name == StringName("teardrop_hills"):
		attach_intro()

func on_lvl_unloaded(lvl_name: StringName):
	if lvl_name == StringName("teardrop_hills"):
		detach_intro()

func detach_intro():
	intro_layer.get_parent().remove_child(intro_layer)

func attach_intro():
	get_tree().current_scene.add_child(intro_layer)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# do som init
	LevelManager.instance.on_level_loaded.connect(on_lvl_loaded)
	LevelManager.instance.on_level_unloaded.connect(on_lvl_unloaded)
	detach_intro()
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
