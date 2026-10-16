extends Node


func _ready() -> void:
    var c := Vector2i(0, 0)

    print("Generating orbital struct 1")

    SpaceChunkGenerator.generate_chunk_realistic(
        c,
        SpaceChunkGenerator.ChunkDetailLevel.FULL
    )

    print("Generating orbital struct 2")

    SpaceChunkGenerator.generate_chunk_realistic(
        Vector2i(999, 999),
        SpaceChunkGenerator.ChunkDetailLevel.FULL
    )