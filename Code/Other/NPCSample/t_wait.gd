## Simple wait for seconds task
class_name TWait
extends Task

## seconds
@export var duration_min: float = 2.0
## seconds
@export var duration_max: float = 5.0
## if set to positive value, duration will always be this instead of being randomized
@export var duration_static: float = -5

func start():
    super.start()

    var duration
    if duration_static > 0.0:
        duration = duration_static
    else:
        var rng = RandomNumberGenerator.new()
        duration = rng.randf_range(duration_min, duration_max)
    print("waiting for: "+str(duration)+" seconds")
        
    await get_tree().create_timer(duration).timeout
    complete()