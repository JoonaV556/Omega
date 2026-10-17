class_name OrbitalBody
extends SpaceObject

## A space-based body / object which spins around its axis and orbits another body (unless rogue or a parent)

## How fast the body spins around its center, in degrees per second.
var spin_speed: float

## The body this body orbits around, may be null if primary etc.
var orbit_parent: OrbitalBody

## Radius of the orbit circle the body orbits around its parent.
var parent_orbit_radius: float 

## Children bodies orbiting this body
var orbiting_children: Array[OrbitalBody]


func get_orbit_levels_num() -> int:
    var levels_num := 0

    for child: OrbitalBody in orbiting_children:
        levels_num = maxi(levels_num, 1 + child.get_orbit_levels_num())

    return levels_num


func get_bodies_on_orbit_level(level: int) -> Array[OrbitalBody]:
    var bodies: Array[OrbitalBody] = []

    if level < 0:
        return bodies
        
    if level == 0:
        bodies.append_array(orbiting_children)
        return bodies

    for child: OrbitalBody in orbiting_children:
        bodies.append_array(child.get_bodies_on_orbit_level(level - 1))
        
    return bodies