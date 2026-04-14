class_name MuzzleFlashController
extends PointLight2D

@export var light_energy_curve: Curve
## seconds
@export var light_flash_duration: float = 0.2

@export var randomize_flash_start_energy: bool = true

@export_range(0.0,1.0) var rand_offset_range: float = 0.3

var flash_current_time_point: float = 0.0 # seconds
var flashing = false

var rand_offsets: Array[float]
var next_offset_index = 0
const rand_offsets_count = 5

func _ready():
    if randomize_flash_start_energy:
        var rng: RandomNumberGenerator = RandomNumberGenerator.new()
        rand_offsets = []
        for i in range(rand_offsets_count):
            var _offset = rng.randf_range(-rand_offset_range, rand_offset_range)
            rand_offsets.append(_offset)

func flash(fire_dir):
    flashing = true
    flash_current_time_point = 0.0

    if randomize_flash_start_energy:
        self.energy = light_energy_curve.sample(flash_current_time_point/light_flash_duration) + rand_offsets[next_offset_index]
    else:
        self.energy = light_energy_curve.sample(flash_current_time_point/light_flash_duration)
    if (next_offset_index + 1) >= rand_offsets.size():
        next_offset_index = 0
    else:
        next_offset_index += 1

func _process(delta):
    if flashing:
        if flash_current_time_point > light_flash_duration:
            flashing = false
            flash_current_time_point = 0.0
        else:
            self.energy = light_energy_curve.sample(flash_current_time_point/light_flash_duration)
            flash_current_time_point += delta