extends CanvasLayer

@export var level_label: Label
@export var anim_player: AnimationPlayer
@export var display_length_secs: float = 2

func _ready() -> void:
	visible = false
	GlobalEventBus.on_level_transition_started.connect(fade_in)
	GlobalEventBus.on_level_transition_ended.connect(fade_out)

func fade_in(level_name: String):
	var anchor = get_child(0) as Control
	anchor.modulate.a = 1.0
	level_label.text = level_name
	visible = true

func fade_out():
	await get_tree().create_timer(display_length_secs).timeout
	anim_player.play("level_trans_fadein")
	await anim_player.animation_finished
	hide()
