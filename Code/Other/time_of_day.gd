## Tracks and updates simulated game-world time. [br]
## Also updates useful daylight values for simulating different daylight levels in game world.
class_name TimeOfDay
extends Node

@export var time_scale: float = 1.0

@export_range(0.0, 24.0) var start_hour: float = 9.0

@export var daylight_curve: Curve

signal on_daylight_update(daylight_alpha: float)
signal on_daylight_color_update(daylight_color: Color)

## Represents current game time in hours, in decimal format. I.E. 8.50 in time_hrs represents the IRL time of 08:30
var time_hrs: float = 0.0
var daylight_alpha: float = 0.0
## Represents the brightness of daylight currently in a color format. The actual light level is updated in the HSV-value V-property (Value / brightness)
var daylight_color: Color = Color.WHITE

func _ready():
    time_hrs = start_hour

func _process(delta):
    var delta_hrs = (delta / 60.0 / 60.0) * time_scale
    if (time_hrs + delta_hrs) > 24.0:
        var leftover = (time_hrs + delta_hrs) - 24.0
        time_hrs = leftover
    else:
        time_hrs += delta_hrs

    daylight_alpha = daylight_curve.sample(time_hrs)
    daylight_color.v = daylight_curve.sample(time_hrs)
    on_daylight_update.emit(daylight_alpha)
    on_daylight_color_update.emit(daylight_color)