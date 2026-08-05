@tool
extends TPursue
class_name TPursueCharacter
## REQUIRES BTPLAYEREXTENDED
## moves npc towards target pos [br]
## optionally moves towards target char instead [br]
## optionally tries to imitate target chars move speed

@export var target_character_blackboard_var: StringName = StringName("target_char")

@export var imitate_move_speed: bool = true

@export var pursue_character_position: bool = false

var trg_c: Character

var pre_fail = false


func _generate_name() -> String:
	return "Pursue Character"

func _enter() -> void:
	super._enter()

	var player: OBTPlayer
	for c in agent.get_children():
		if c is OBTPlayer:
			player = c
	
	if !player: 
		push_error("cant find btplayer")

	trg_c = player.node_blackboard[target_character_blackboard_var]

	if trg_c:
		print("trg obj is char")

	pre_fail = false
	if !trg_c:
		pre_fail = true

func _tick(delta: float) -> Status:
	# stop pursue if char ref is null
	if pre_fail:
		return FAILURE
	if !trg_c:
		return FAILURE

	# imitate move speed
	if imitate_move_speed:
		if trg_c.sprinting and !npc.sprinting:
			npc.set_sprinting(true)
		if !trg_c.sprinting and npc.sprinting:
			npc.set_sprinting(false)
	
	# move the agent towards the target character
	return super.update(delta)

func _get_target_pos() -> Vector2:
	if pursue_character_position:
		return trg_c.global_position
	else:
		var ret = target_position_var.get_value(scene_root, blackboard)
		if !ret:
			push_error("error retrieving pursue target position value from blackboard")
		return ret
	
