class_name KillhouseManager
extends Node

@export var player: Node2D
@export var targets_parent: Node

var targets: Array[StaticDamageable]

var targets_killed: int = 0
var kills_required: int = 9999
var round_ongoing: bool = false

var player_start_pos: Vector2 = Vector2.ZERO

signal killhouse_completed
signal killhouse_started
signal on_reset

func _ready() -> void:
	for child in targets_parent.get_children():
		var damageable := child as StaticDamageable
		if damageable:
			targets.append(damageable)
	
	kills_required = targets.size()
	
	for target in targets:
		target.health.on_depleted.connect(self.on_target_killed)
	
	player_start_pos = player.global_position

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ResetKillhouse"):
		reset()

func reset():
	print("shit")
	
	# move player back to beginning
	player.global_position = player_start_pos
	
	# revive targets
	for target in targets:
		target.health.revive()
	
	targets_killed = 0
	round_ongoing = false
	
	on_reset.emit()
	print_debug("round reset")

func start_round():
	if round_ongoing:
		return
	round_ongoing = true
	killhouse_started.emit()
	print_debug("round started")

func on_player_reached_exit(player: Node2D):
	if targets_killed == kills_required:
		killhouse_completed.emit()
		print_debug("round ended")

func on_target_killed():
	targets_killed += 1
