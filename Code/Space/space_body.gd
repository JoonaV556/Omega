class_name SpaceBody
extends SpaceObject


## How fast the body spins around its center, in degrees per second.
var spin_speed: float

## The body this body orbits around, may be null if primary etc.
var orbit_parent: SpaceBody

## Radius of the orbit circle the body orbits around its parent.
var parent_orbit_radius: float 

## Children bodies orbiting this body
var orbiting_children: Array[SpaceBody]