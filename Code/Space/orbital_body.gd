class_name OrbitalBody
extends SpaceObject

## A space-based body / object which spins around its axis and orbits another body (unless rogue or a parent)

## How fast the body spins around its center, in degrees per second.
var spin_speed: float

var orbital_velocity: float

## The body this body orbits around, may be null if primary etc.
var orbit_parent: OrbitalBody

## How far apart the body orbits around its parent
var orbit_radius: float 

## Children bodies orbiting this body
var orbiting_children: Array[OrbitalBody]


## Returns the sum of orbit radiuses of the body and all of its hierarchical parents in the orbital tree.
func get_accumulated_orbit_radius() -> float:
	var accumulated_radius := orbit_radius

	if orbit_parent != null:
		accumulated_radius += orbit_parent.get_accumulated_orbit_radius()

	return accumulated_radius


## Returns siblings of the body, excluding the body itself
func get_siblings() -> Array[OrbitalBody]:
	var sibs: Array[OrbitalBody] = []

	if orbit_parent == null:
		return sibs

	sibs = orbit_parent.orbiting_children.duplicate()
	sibs.erase(self) 

	return sibs


## If body has siblings on other orbital tracks, returns distance to the nearest siblings orbital track. If no siblings or all siblings on same track, returns float.INF
func get_distance_to_nearest_sibling_orbit_track() -> float:
	var dist := INF

	if get_siblings().is_empty():
		return dist

	# get siblings on other orbit tracks
	var sibs := get_siblings_on_other_orbits()

	if sibs.is_empty():
		return dist

	# Calculate distance to nearest sibling
	for sib in sibs:
		var sib_dist := absf(sib.orbit_radius - orbit_radius)
		if sib_dist < dist:
			dist = sib_dist

	return dist


func get_siblings_on_other_orbits() -> Array[OrbitalBody]:
	var sibs := get_siblings()

	if sibs.is_empty():
		return sibs

	# Filter out siblings on same orbit track
	const other_orbit_treshold := 1.0

	var sibs_on_same_track: Array[OrbitalBody] = []
	
	for sib in sibs:
		var sib_dist := absf(sib.orbit_radius - orbit_radius)
		if sib_dist < other_orbit_treshold:
			sibs_on_same_track.append(sib)

	for _sib in sibs_on_same_track:
		sibs.erase(_sib)

	return sibs



func get_siblings_with_set_radiuses(min_orbit_radius: float) -> Array[OrbitalBody]:
	var sibs_s: Array[OrbitalBody] = [] 

	sibs_s = get_siblings()

	if !sibs_s.is_empty():
		sibs_s = sibs_s.filter(
			func(body: OrbitalBody): return body.orbit_radius > min_orbit_radius
		)

	return sibs_s


func has_orbit_radius() -> bool:
	return orbit_radius > 0.0


## Returns number of hierarchical orbit levels of bodies orbiting this body. 0 means no children.
func get_orbit_levels_num() -> int:
	var levels_num := 0

	for child: OrbitalBody in orbiting_children:
		levels_num = maxi(levels_num, 1 + child.get_orbit_levels_num())

	return levels_num


## Returns all descendant bodies at the given orbit level (0 returns direct children).
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

## Assuming all siblings are placed evenly apart from each other on the same orbit track, returns 1/2 of the distance to a sibling, i.e the distance to the 'sibling divider line'
func get_sibling_divider_distance() -> float:
	var root_angle := (360.0 / (get_siblings().size() + 1.0)) / 2.0
	return orbit_radius * sin(deg_to_rad(root_angle))


func add_child(body: OrbitalBody):
	orbiting_children.append(body)
	body.orbit_parent = self


func remove_child(body: OrbitalBody):
	if orbiting_children.has(body):
		body.orbit_parent = null
		orbiting_children.erase(body)


func get_bodies_num_in_hierarchy() -> int:
	var total := 1
	for child: OrbitalBody in orbiting_children:
		total += child.get_bodies_num_in_hierarchy()
		
	return total