extends Node
# just a test script for testing out normal distro
class_name GaussianPrintTest
@export
var tries:		int 		= 10
@export
var range:		Vector2i 	= Vector2i(0, 100)
@export
var deviation: 	float 		= 1.0

# print normal rng numbers within certain range
func _ready():
	var rng_gen = RandomNumberGenerator.new()
	print_debug("Generating numbers in range: "+str(range.x)+"-"+str(range.y))
	print_debug("Deviation: "+str(deviation))
	for i in range(tries):
		var rnd: int = rng_gen.randfn(range.x+(range.y-range.x)/2, deviation)
		print_debug(str(rnd))
