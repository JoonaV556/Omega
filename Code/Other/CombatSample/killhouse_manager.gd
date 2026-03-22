class_name KillhouseManager
extends Node

@export var targets_parent: Node
var targets: Array[StaticDamageable]

var targets_killed: int = 0
var kills_required: int = 9999

signal killhouse_completed

func _ready() -> void:
	for child in targets_parent.get_children():
		var damageable := child as StaticDamageable
		if damageable:
			targets.append(damageable)
	
	kills_required = targets.size()
	
	for target in targets:
		target.health.on_depleted.connect(self.on_target_killed)

func on_player_reached_exit(player: Node2D):
	if targets_killed == kills_required:
		killhouse_completed.emit()

func on_target_killed():
	targets_killed += 1

#var _projectile := _projectile_node as Projectile
	#if not _projectile:
		#return
	#_projectile.global_position = self.global_position
