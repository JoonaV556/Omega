extends AnimatedSprite2D
# Controls character sprite animations by reading the state of CharacterBody2D

@export var character_body: CharacterBody2D
enum look_dir {down, up, left, right}
var current_look_dir = look_dir.down

func _process(_delta: float) -> void:
	if character_body == null:
		return
	var velocity = character_body.get_real_velocity()
	var magnitude = velocity.length()
	var moving = magnitude > 1.0
	#up
	if (velocity.x > -1.0 and velocity.x < 1.0) and velocity.y < -98.0:
		current_look_dir = look_dir.up
	#down
	if (velocity.x > -1.0 and velocity.x < 1.0) and velocity.y > 98.0:
		current_look_dir = look_dir.down
	#left
	if velocity.x < -65.0:
		current_look_dir = look_dir.left
	#right
	if velocity.x > 65.0:
		current_look_dir = look_dir.right
	if moving:
		match current_look_dir:
			look_dir.up:
				play("Walk_Up")
			look_dir.down:
				play("Walk_Down")
			look_dir.left:
				play("Walk_Left")
			look_dir.right:
				play("Walk_Right")
	else:
		match current_look_dir:
			look_dir.up:
				play("IdleBreathing_Up")
			look_dir.down:
				play("IdleBreathing_Down")
			look_dir.left:
				play("IdleBreathing_Left")
			look_dir.right:
				play("IdleBreathing_Right")
