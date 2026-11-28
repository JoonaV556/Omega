class_name SpaceShipController
extends RigidBody2D

enum SteeringMode {
	STEER_TOWARDS_POSITION,
	STEER_TOWARDS_DIRECTION
}

@export_group("General")
@export var override_max_speed: bool = false

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

## Reference to the virtual spaceship instance.
var ship_id: int = -1

# Where ship points to
var input_steer_direction: Vector2

## -1,0 backwards, 1.0 forward
var input_thrust: float = 0.0

## -1.0 left, 1.0 right
var input_strafe: float = 0.0

var input_fire: bool = false

## Measure of the total thruster effort. Can be used to calculate fuel consumption etc.
var _total_thruster_effort: float

var _is_probably_editor_placed: bool = false


func _ready() -> void:
	input_steer_direction = global_position + Vector2.UP.rotated(global_rotation)

	# Register as new ship if not yet registered - useful for enabling virtualization for editor-placed spaceship nodes
	if SpaceshipManager.get_ship(ship_id) == null:
		_is_probably_editor_placed = true
		ship_id = SpaceshipManager.register_ship(SpaceShip.new())

	# Make sure editor-placed spaceship nodes are recognized as loaded by chunk renderer
	var ship: SpaceShip = SpaceshipManager.get_ship(ship_id)
	if !SpaceChunkRenderer.is_loaded(ship):
		ship.name = self.name
		SpaceChunkRenderer.mark_loaded(ship, self)

	# Fetch max_speed from virtualized instance
	if !override_max_speed:
		max_speed = ship.max_speed

	# Initialize stellar position of editor placed ships by referencing rendered space chunk positions (wait until spacechunkrenderer has some chunks rendered)
	if _is_probably_editor_placed:
		await SpaceUtils.wait_process_ticks(self, 5)
		var space_coords := SpaceChunkRenderer.instance.to_space_coordinate(
			global_position
		)
		ship.position_tracker.set_position(space_coords[0], space_coords[1])


func _physics_process(delta: float) -> void:
	# steer 
	var angle_rad = Vector2.UP.angle_to(input_steer_direction)

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

	var total_thruster_force := Vector2.ZERO
	
	_total_thruster_effort = 0.0

	# Forward & backwards thrust
	if input_thrust != 0.0:
		var force = forward_thruster_force if input_thrust > 0.0 else backward_thruster_force
		var forward_force: Vector2 = Vector2.UP.rotated(rotation) * force * input_thrust

		total_thruster_force += forward_force

		_total_thruster_effort += forward_force.length()

	# Strafing
	if input_strafe != 0.0:
		var strafing_force: Vector2 = Vector2.RIGHT.rotated(rotation) * strafing_thruster_force * input_strafe

		total_thruster_force += strafing_force

		_total_thruster_effort += strafing_force.length()

	# Braking
	if input_thrust == 0.0 and input_strafe == 0.0 and not linear_velocity.is_zero_approx():
		var speed := linear_velocity.length()
		var brake_force := minf(braking_force, mass * speed / delta)
		var total_brake_force: Vector2 = -linear_velocity / speed * brake_force

		total_thruster_force += total_brake_force
		
		_total_thruster_effort += total_brake_force.length()

	apply_central_force(total_thruster_force)


func apply_input(
	thrust: float, 
	strafe: float, 
	fire_input: bool = false, 
	steering_mode: SteeringMode = SteeringMode.STEER_TOWARDS_POSITION,
	aim_target_position: Vector2 = Vector2.ZERO, 
	steer_towards_direction: Vector2 = Vector2.ZERO
	) -> void:

	if steering_mode == SteeringMode.STEER_TOWARDS_POSITION:
		input_steer_direction = global_position.direction_to(aim_target_position)
	else:
		input_steer_direction = steer_towards_direction.normalized()

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
