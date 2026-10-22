class_name OrbitalBodyRoot2D
extends Node2D

## Movement velocity of the body on its orbital track in pixels per second
var orbital_velocity: float

## How far the body orbits the root in pixels
var orbit_radius: float

## How fast the body at body pivot spins around its own axis in degs per second
var spin_speed: float


var body_pivot: Node2D

var body_spin_pivot: Node2D


var _ready = false


func init(body: OrbitalBody):
    name = "Orbital Body Root 2D - %s" % [body.name]

    orbital_velocity = body.orbital_velocity
    orbit_radius = body.orbit_radius
    spin_speed = body.spin_speed

    body_pivot = Node2D.new()
    body_pivot.name = "BodyPivot2D"
    add_child(body_pivot)
    body_pivot.position += Vector2(0, -orbit_radius)

    body_spin_pivot = Node2D.new()
    body_spin_pivot.name = "Body Spin Pivot"
    body_pivot.add_child(body_spin_pivot)

    _ready = true


func attach_body_2d(body: Node2D):
    if !_ready:
        return

    body_pivot.add_child(body)


func _process(delta: float) -> void:
    if !_ready:
        return

    _move_body(delta)

    _spin_body(delta)


func _move_body(delta):
    if is_zero_approx(orbit_radius):
        return

    var angular_velocity_degrees := rad_to_deg(absf(orbital_velocity) / absf(orbit_radius))
    rotation_degrees += angular_velocity_degrees * delta


func _spin_body(delta):
    body_spin_pivot.rotation_degrees += spin_speed * delta
