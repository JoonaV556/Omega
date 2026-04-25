class_name NpcCharacter
extends Character

@export var nav_agent: NavigationAgent2D

var move_dir: Vector2 = Vector2.ZERO 

func _ready():
    super._ready()

func update_character_physics():
    if movement_enabled:
        velocity = Vector2(move_dir.normalized()*self.current_move_speed)

func _on_movement_disabled():
    velocity = Vector2.ZERO
