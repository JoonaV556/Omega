class_name SpaceGlobals

const chunk_size_pixels: Vector2 = Vector2(5000.0, 5000.0)

const global_position_origin_shift_treshold: Vector2 = Vector2(800000.0, 800000.0)

## How many chunks fit inside a galaxy cell
const galaxy_cell_size: Vector2i = Vector2i(10, 10)

static var origin_shift_amount: Vector2 = Vector2.ZERO
static var origin_shift_version: int = 0


static func get_chunk_generator_params() -> SpaceChunkGenerator.generator_params:
	var params := SpaceChunkGenerator.generator_params.new()

	var good_radius := get_appropriate_planet_radius(chunk_size_pixels)

	params.chunk_belongs_to_galaxy_odds = 0.3

	params.has_system_odds_in_galaxy = 0.2	
	params.has_system_odds_no_galaxy = 0.05

	params.planets_per_system_min = 1 
	params.planets_per_system_max = 10

	params.planet_radius_min = good_radius.x
	params.planet_radius_max = good_radius.y

	params.chunk_size_pixels = chunk_size_pixels

	return params 


static func get_appropriate_planet_radius(_chunk_dimensions: Vector2) -> Vector2:
	var _max := chunk_size_pixels.x / 2.5
	var _min := _max / 20.0

	return Vector2(_min, _max)