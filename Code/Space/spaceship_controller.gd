class_name SpaceShipController
extends RigidBody2D

@export_group("Thrust settings") # Defaults are calibrated for a small fighter-sized ship with a rigidbody mass of 1kg
## meters per second (tiles)
@export var max_speed = 50.0
@export var forward_thruster_force : float  = 250.0
@export var backward_thruster_force : float = 200.0
@export var strafing_thruster_force : float  = 300.0
@export var braking_force = 200.0
@export var max_turn_speed_degrees: float = 180.0 
@export var turn_responsiveness: float = 6.0 ## How quickly it turns toward the target angle
@export var turn_acceleration: float = 40.0 ## How fast it accelerates/decelerates to target speed

@export_group("Weapons")
@export var guns: Array[Gun2D]


# Where ship points to
var input_aim_target_position: Vector2

## -1,0 backwards, 1.0 forward
var input_thrust: float = 0.0

## -1.0 left, 1.0 right
var input_strafe: float = 0.0

var input_fire: bool = false


func _ready() -> void:
	input_aim_target_position = global_position + Vector2.UP.rotated(global_rotation)


func _physics_process(delta: float) -> void:
	# steer 
	var aim_direction := global_position.direction_to(input_aim_target_position)
	var angle_rad = Vector2.UP.angle_to(aim_direction)

	var angle_error := wrapf(angle_rad - global_rotation, -PI, PI)

	# 1. Calculate desired speed based on error, capped by max_turn_speed_degrees
	var mts_rad = deg_to_rad(max_turn_speed_degrees)
	var target_angular_velocity := clampf(
		angle_error * turn_responsiveness, 
		-mts_rad, 
		mts_rad
	)

	# 2. Smoothly accelerate toward the target angular velocity
	angular_velocity = move_toward(angular_velocity, target_angular_velocity, turn_acceleration * delta)

	# Forward & backwards thrust
	if input_thrust != 0.0:
		var force = forward_thruster_force if input_thrust > 0.0 else backward_thruster_force
		apply_central_force(Vector2.UP.rotated(rotation) * force * input_thrust)

	# Strafing
	if input_strafe != 0.0:
		apply_central_force(Vector2.RIGHT.rotated(rotation) * strafing_thruster_force * input_strafe)

	# Braking
	if input_thrust == 0.0 and input_strafe == 0.0 and not linear_velocity.is_zero_approx():
		var speed := linear_velocity.length()
		var brake_force := minf(braking_force, mass * speed / delta)
		apply_central_force(-linear_velocity / speed * brake_force)


func apply_input(aim_target_position: Vector2, thrust: float, strafe: float, fire_input: bool = false) -> void:
	input_aim_target_position = aim_target_position
	input_thrust = clampf(thrust, -1.0, 1.0)
	input_strafe = clampf(strafe, -1.0, 1.0)
	input_fire = fire_input
	
	if input_fire:
		for gun in guns:
			gun.fire()
		input_fire = false


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	# Cap max speed
	if linear_velocity.length() / 16.0 > max_speed:
		var limited = linear_velocity.normalized() * max_speed * 16
		linear_velocity = limited
