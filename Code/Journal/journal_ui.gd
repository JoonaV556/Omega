extends CanvasLayer

@export var quest_ui_scene_path: String = "uid://c1s7f8x35slxg"

@export var journal: Journal

@onready var quests_container: VBoxContainer = get_node("%VBoxContainer - QuestContainer")

var q_scene: PackedScene

var q_node_templ: QuestUI

var quest_uis: Dictionary[Quest, QuestUI]

func _ready():
	q_scene = load(quest_ui_scene_path) as PackedScene
	q_node_templ = q_scene.instantiate() as QuestUI
	journal.on_quest_completed.connect(on_quest_complete)

func _process(delta):
	if Input.is_action_just_pressed("ToggleJournal"):
		if !visible:
			visible = true
		else:
			visible = false

func on_quest_complete(q: Quest):
	quest_uis[q].mark_complete(true)

func add_quest_ui(quest: Quest):
	var q_ui: QuestUI = q_node_templ.duplicate()
	quests_container.add_child(q_ui)
	q_ui.set_title(quest.title)
	q_ui.mark_complete(quest.completed)
	for note in quest.notes_active:
		q_ui.add_note(note)
	quest_uis[quest] = q_ui

func add_quest_note(q: Quest, note: String):
	quest_uis[q].add_note(note)
