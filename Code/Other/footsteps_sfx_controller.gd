extends AudioStreamPlayer2D
@export var animsprite: AnimatedSprite2D
@export var footstep_anim_name: String = "Walk"
@export var footstep_frames: Array[int]
# Plays footstep sfx by reading characters AnimatedSprite state and deciding when to play sound
func on_frame_switched():
	if animsprite == null:
		return
	if not (footstep_anim_name in animsprite.animation):
		return	
	var frame = animsprite.frame
	for target_frame: int in footstep_frames:
		if target_frame == frame:
			play()
	
