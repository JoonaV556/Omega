class_name Interactable
extends StaticBody2D

@export var hint = ""

signal interact_available
signal interact_unavailable
signal interact

func _ready():
	interact_available.connect(_on_interact_available)
	interact_unavailable.connect(_on_interact_unavailable)
	$Hint.hide()
	
func _on_interact_available():
	$Hint.text = hint
	$Hint.show()

func _on_interact_unavailable():
	$Hint.hide()
