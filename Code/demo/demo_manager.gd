extends Node

@export var player: Player
@export var intro_dialogue: TimelineStarter
@export var cutscene_bg: CanvasLayer

@export var level_asset_teardrop_valley: PackedScene
var level_teardrop_valley: Level
@export var level_asset_blue_house: PackedScene
var level_blue_house: Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	player.disable_movement()
	player.visible = false

	# preload neighborhood level and house level 
	var trdrop := level_asset_teardrop_valley.instantiate() as Level
	level_teardrop_valley = trdrop
	var house := level_asset_blue_house.instantiate() as Level
	level_blue_house = house

	# start dialogue 
	intro_dialogue.start()
	await Dialogic.timeline_ended
	cutscene_bg.hide()

	# spawn house level and place player in the house
	get_tree().current_scene.add_child(level_blue_house)
	player.global_position = level_blue_house.player_start_position.global_position
	get_tree().current_scene.move_child(player, -1)
	player.enable_movement()
	player.visible = true
