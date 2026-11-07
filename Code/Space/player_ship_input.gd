class_name PlayerShipInput
extends Node2D


@export var spaceship_controller: SpaceShipController


func _ready() -> void:
	if spaceship_controller:
		return
		
	spaceship_controller = get_parent() as SpaceShipController


func _process(delta: float) -> void:
	if !spaceship_controller:
		return

	var fire := Input.is_action_just_pressed("Fire")

	spaceship_controller.apply_input(
		get_global_mouse_position(),
		Input.get_axis("MoveDown", "MoveUp"),
		Input.get_axis("MoveLeft", "MoveRight"),
		fire
	)

	
