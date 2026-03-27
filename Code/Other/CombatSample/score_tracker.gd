extends Node

var hi_score: float = 0.0
var score_set: bool = false

signal on_hi_score_updated(score: float)

func _ready() -> void:
	# load hi score
	var config = ConfigFile.new()
	var err = config.load("user://scores.cfg")
	if err != OK:
		push_warning("error loading killhouse hi score")
		return
	var loaded_score: float = config.get_value("Killhouse", "high-score")
	if loaded_score and (loaded_score > 00.00):
		hi_score = loaded_score
		on_hi_score_updated.emit(hi_score)
		score_set = true
		print("loaded high score!")

func on_timer_stopped(time: float):
	if (time < hi_score) or !score_set:
		hi_score = time
		# save hi score
		var config = ConfigFile.new()
		config.set_value("Killhouse", "high-score", hi_score)
		config.save("user://scores.cfg")
		on_hi_score_updated.emit(hi_score)
		print("saved new high score!")
		score_set = true

func get_score() -> float:
	return hi_score
