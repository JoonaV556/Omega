class_name BehaviorAgent
extends Node

@export var tasks:      Array[Task]

@export var enable_loop_tasks: bool = true

var current_task:       Task

var task_start_indx:    int = 0
var current_task_indx:  int = 0

func _ready():
	if not tasks:
		return
	if not tasks.size() > 0:
		return
	
	current_task_indx = task_start_indx

	begin_task(tasks[current_task_indx])

func _on_complete():
	current_task.on_complete.disconnect(_on_complete)
	print("task complete")
		
	if (current_task_indx + 1) >= tasks.size():
		current_task_indx = 0
		print("all tasks completed. looping back to first task")
	else:
		current_task_indx += 1

	print(tasks[current_task_indx])
	begin_task(tasks[current_task_indx])

func begin_task(task):
	current_task = task
	current_task.on_complete.connect(_on_complete)
	current_task.start()
