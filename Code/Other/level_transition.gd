@tool
class_name LevelTransition
extends Area2D

@export var target: LevelTransition
@export var transition_name: StringName = "default"
@export var target_level_name: LevelManager.level_name
@export var target_level_transition_name: StringName
@export var target_level_transition_index: int

var ignore: RID

func _ready():
	self.body_entered.connect(_body_entered)

func _body_entered(body: Node2D):
	var body_col := body as CollisionObject2D

	# donts send the same body instantly back if it's the same one that just came through
	if body_col and (body_col.get_rid() == self.ignore):
		ignore = RID()
		return

	if body is Character:
		# send to trans. in other level
		if target == null:
			call_deferred("move_to_level", body)
			return

		# send to trans. in same level
		if self.get_parent() != target.get_parent():
			self.get_parent().visible = false 
			target.get_parent().visible = true
		target.send_to(body)	

func move_to_level(body):
	GlobalEventBus.on_level_transition_started.emit(
			LevelManager.instance.level_names_readable[target_level_name]
		)

	# load other level
	var t_level: Level = LevelManager.instance.load_level(target_level_name)
	
	# get correct trans. point
	var trs: LevelTransition
	if !target_level_transition_name.is_empty():
		trs = t_level.get_transition_by_name(target_level_transition_name)
	else:
		trs = t_level.get_transition_by_idx(target_level_transition_index)
	
	# send to other trans. point
	if self.get_parent() != trs.get_parent():
			self.get_parent().visible = false 
			trs.get_parent().visible = true
	trs.send_to(body)

	GlobalEventBus.on_level_transition_ended.emit()

	# move body to bottom of hierarch.
	body.get_parent().move_child(body, -1)

	# unload current level
	var current: Node = self as Node
	var parent_level: Level = null
	while !parent_level:
		var cand = current.get_parent()
		if cand is Level:
			parent_level = cand as Level
		current = cand
	LevelManager.instance.unload_level(parent_level)

func send_to(body: Node2D):
	var body_col := body as CollisionObject2D
	self.ignore = body_col.get_rid()
	body.global_position = self.get_child(0).global_position 
