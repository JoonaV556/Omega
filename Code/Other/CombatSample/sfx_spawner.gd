class_name SfxSpawner
extends Node2D

# todo: make reusable for any kind of pooled sfx
# 4 sources for sfx
# on bullet land, take source from array top, move to bottom

@export var stream: AudioStream
## pixels - 16 = 1 meter
@export var audio_max_distance: float = 2000.0
var sources: Array[AudioStreamPlayer2D]

func _ready():
    for i in range(4):
        var source = AudioStreamPlayer2D.new()
        source.name = "sfx source - pooled"
        source.stream = stream
        source.max_distance = audio_max_distance
        self.add_child(source)
        sources.append(source)
    
    GlobalEventBus.on_bullet_landed.connect(self.play)



func play(pos: Vector2):
    var src = sources.pop_at(0)
    src.global_position = pos
    src.play()
    sources.push_back(src)