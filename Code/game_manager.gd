## This is the pretty much the entry point for the whole game.
class_name GameManager
extends Node
@export var player: Node2D
@export var camera: Node2D
@export var init_level: PackedScene = null
var _levels_root: Node2D

func _ready() -> void:
	# create a root node for levels
	_levels_root = Node2D.new()
	_levels_root.name = "Levels"
	self.add_child(_levels_root)
	
	# load first level
	self.call_deferred("load_level", init_level)

func load_level(_level: PackedScene):
	var _level_node = _level.instantiate()
	if _level_node is Level:
		_levels_root.add_child(_level_node)
		_level_node.load(player, camera)
