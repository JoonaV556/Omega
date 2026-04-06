class_name SfxSpawner
extends Node2D

@export var stream: AudioStream
## pixels - 16 = 1 meter
@export var audio_max_distance: float = 2000.0

@export var override_sources: Array[AudioStreamPlayer2D]

var sources: Array[AudioStreamPlayer2D]

func _ready():
    if override_sources.size() <= 0:
        for i in range(4):
            var source = AudioStreamPlayer2D.new()
            source.name = "sfx source - pooled"
            source.stream = stream
            source.position = Vector2.ZERO
            source.max_distance = audio_max_distance
            self.add_child(source)
            sources.append(source)
    else:
        sources = override_sources.duplicate()

func play_at_position(pos: Vector2):
    var src = sources.pop_at(0)
    src.global_position = pos
    src.play()
    sources.push_back(src)

## play at spawners position
func play(delay_seconds: float = -1.0):
    if delay_seconds > 0:
        await get_tree().create_timer(delay_seconds).timeout
    play_at_position(self.global_position)