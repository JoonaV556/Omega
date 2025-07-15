extends StaticBody2D

func _on_interactable_interact() -> void:
	Dialogic.start("res://Dialogue/Timelines/robert_test_timeline.dtl")
