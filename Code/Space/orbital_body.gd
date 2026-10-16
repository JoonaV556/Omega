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