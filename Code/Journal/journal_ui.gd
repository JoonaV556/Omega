extends CanvasLayer

@export var quest_ui_scene_path: String = "uid://7trafrbhq8q5"
@onready var quests_container: VBoxContainer = get_node("%VBoxContainer - QuestContainer")

var q_scene: PackedScene
var q_node_templ: QuestUI

func _ready():
	q_scene = load(quest_ui_scene_path) as PackedScene
	q_node_templ = q_scene.instantiate() as QuestUI

func on_update(quests: Array[Quest]):
	for q in quests:
		var n_q_node: QuestUI = q_node_templ.duplicate()
		quests_container.add_child(n_q_node)
		n_q_node.set_title(q.title)
		n_q_node.mark_complete(q.completed)
		for note in q.notes:
			n_q_node.add_note(note)

func on_add_quest(quest: Quest):
	var n_q_node: QuestUI = q_node_templ.duplicate()
	quests_container.add_child(n_q_node)
	n_q_node.set_title(quest.title)
	n_q_node.mark_complete(quest.completed)
	for note in quest.notes:
		n_q_node.add_note(note)

func _process(delta):
	if Input.is_action_just_pressed("ToggleJournal"):
		if !visible:
			visible = true
		else:
			visible = false