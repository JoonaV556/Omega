extends Node
class_name DemoDeathHandler

signal on_death_immediate
signal on_death_delayed

var checkpoints: Array[DemoCheckpoint]

func _ready():
	for n in get_children():
		var c = n as DemoCheckpoint
		if c:
			checkpoints.append(c)

func trigger(died: Health):
	# trigger death ui
	on_death_immediate.emit()

	# wait for a few secs
	await get_tree().create_timer(3.0).timeout

	# revive player on last checkpoint w marv
	on_death_delayed.emit()

	died.revive()

	var pl = died.get_parent() as Node2D
	
	for c in checkpoints:
		if c.active:
			pl.global_position = c.global_position
