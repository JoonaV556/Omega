class_name BehaviorAgent
extends Node

@export var tasks: Array[Task]

var current_task: Task

func _ready():
    if not tasks:
        return
    if not tasks.size() > 0:
        return
    current_task = tasks[0]