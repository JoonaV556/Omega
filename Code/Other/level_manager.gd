class_name LevelManager
extends Node

static var instance: LevelManager

# todo:
# detach() func - removes a level from tree without unloading it from memory?

# name, string UID or path
@export var level_scenes: Dictionary[level_name, String] = {
	level_name.blue_house: "asd",
	level_name.teardrop_hills: "asd",
}

@export
var level_names_readable: Dictionary[level_name, String] = {}

var levels: Dictionary[level_name, Level] = {}

enum level_name { 
	blue_house,
	teardrop_hills,
}

signal on_after_ready

signal on_level_loaded(level_unique_name: StringName)
signal on_level_unloaded(level_unique_name: StringName)

func _ready() -> void:
	if instance == null:
		instance = self
	elif instance != self:
		push_error("WARNING: multiple level managers!!!!")
	on_after_ready.emit()

func load_level(_level_name: level_name):
	# load 
	if _level_name not in levels:
		var l_scene = load(level_scenes[_level_name]) # heavy
		var l_node: Level = l_scene.instantiate()
		
		get_tree().current_scene.add_child(l_node)
		
		levels[_level_name] = l_node
		print("loaded level "+str(l_node.unique_name))
		on_level_loaded.emit(l_node.unique_name)
	return levels[_level_name]

func unload_level_by_name(_level_name: level_name):
	if _level_name in levels:
		unload_level(levels[_level_name])

func unload_level(_level: Level):
	if levels.values().has(_level):
		levels[levels.find_key(_level)].queue_free()
		levels.erase(levels.find_key(_level))
		print("unloaded level "+str(_level.unique_name))
		on_level_unloaded.emit(_level.unique_name)
