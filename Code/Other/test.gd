class_name Test
extends Node

@export var enabled: bool = true

func _ready() -> void:
    if enabled:
        run()

func run():
    pass