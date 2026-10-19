extends Node


func _ready() -> void:
	var c := Vector2i(0, 0)

	var iterations := 5

	for n in range(0, iterations):
		c.x += n
		c.y += n
		print("Generating orbital struct %s " % [n])
		SpaceChunkGenerator.generate_chunk_realistic(
			c,
			SpaceChunkGenerator.ChunkDetailLevel.FULL
		)

	# var parent := OrbitalBody.new(SpaceChunkGenerator._generate_random_name())

	# for n in range(3):
	# 	var c := OrbitalBody.new(SpaceChunkGenerator._generate_random_name())
	# 	c.orbit_radius = 100.0
	# 	parent.add_child(c)

	# print(parent.orbiting_children[0].get_sibling_divider_distance())
