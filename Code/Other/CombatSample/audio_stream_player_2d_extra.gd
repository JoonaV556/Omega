extends AudioStreamPlayer2D
## TODO - maybe cache some random-gen deltas in array and loop them instead of new rand call every func call?


@export_range(0.0, 1.0) var rand_pitch_delta_override: float = 0.0

var pitch_scale_original

func _ready():
    pitch_scale_original = self.pitch_scale

func play_at_rand_pitch(rand_pitch_delta: float = 0.0, from_position: float = 0.0):
    self.pitch_scale = pitch_scale_original
    var rng = RandomNumberGenerator.new()

    var clamped_delta
    if rand_pitch_delta_override > 0:
        clamped_delta = clampf(rand_pitch_delta_override, 0.0, 1.0)
    else:
        clamped_delta = clampf(rand_pitch_delta, 0.0, 1.0)

    self.pitch_scale += rng.randf_range(-clamped_delta, clamped_delta)
    self.play(from_position)