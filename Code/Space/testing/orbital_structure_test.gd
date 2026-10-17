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