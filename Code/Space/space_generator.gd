class_name SpaceGenerator

class universe_params:
	var galaxies_min = 5
	var galaxies_max = 30

	var gal_coords_min = Vector2(-50.0, -50.0)
	var gal_coords_max = Vector2(50.0, 50.0)
	
	var systems_per_galaxy_min = 1
	var systems_per_galaxy_max = 10

	var system_coords_min = Vector2(-50.0, -50.0)
	var system_coords_max = Vector2(50.0, 50.0)


static func _generate_random_name(rng: RandomNumberGenerator) -> String:
	var roots: Array = [
		"Aster", "Boreal", "Cinder", "Drift", "Eos", "Feral",
		"Gale", "Hallow", "Iris", "Juno", "Kite", "Lyra",
		"Mira", "Nyx", "Orion", "Peregrin", "Quill", "Rift",
		"Sol", "Talon", "Umbra", "Vega", "Warden", "Yara", "Zephyr"
	]
	var suffix := rng.randi_range(1, 999)
	return "%s %s" % [roots[rng.randi() % roots.size()], suffix]


static func generate_universe(params : universe_params) -> StellarObject:
	var _obj_root : StellarObject = StellarObject.new(Vector2.ZERO, "universe")

	var cluster : Array[StellarObject] = []
	var rng := RandomNumberGenerator.new()

	if params == null:
		params = universe_params.new()

	var galaxy_count_min: int = params.galaxies_min
	var galaxy_count_max: int = params.galaxies_max

	var galaxy_count: int = rng.randi_range(galaxy_count_min, galaxy_count_max)

	for galaxy_index in range(galaxy_count):
		var galaxy_coords := Vector2(
			rng.randf_range(params.gal_coords_min.x, params.gal_coords_max.x),
			rng.randf_range(params.gal_coords_min.y, params.gal_coords_max.y)
		)
		var galaxy := Galaxy.new(galaxy_coords, _generate_random_name(rng))
		galaxy.systems = []
		galaxy.objects = []
		galaxy.so_parent = _obj_root

		var system_count_min: int = params.systems_per_galaxy_min
		var system_count_max: int = params.systems_per_galaxy_max

		var system_count: int = rng.randi_range(system_count_min, system_count_max)

		for system_index in range(system_count):
			var system_coords := Vector2(
				rng.randf_range(params.system_coords_min.x, params.system_coords_max.x),
				rng.randf_range(params.system_coords_min.y, params.system_coords_max.y)
			)
			var system := System.new(system_coords, _generate_random_name(rng))
			system.so_parent = galaxy
			galaxy.systems.append(system)
			galaxy.objects.append(system)

		cluster.append(galaxy)

	_obj_root.objects = cluster
	return _obj_root
