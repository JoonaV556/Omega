@tool
extends Node

@export var label_font: Font
@export var control_theme: Theme
@export_tool_button("Set Label Fonts") var set_fonts_action = set_fonts
@export_tool_button("Set Control Themes") var set_control_themes_action = set_control_themes


func set_fonts() -> void:
	var scene_root := get_tree().edited_scene_root
	if scene_root == null:
		return

	_set_fonts_recursive(scene_root)


func set_control_themes() -> void:
	var scene_root := get_tree().edited_scene_root
	if scene_root == null:
		return

	_set_control_themes_recursive(scene_root)


func _set_fonts_recursive(node: Node) -> void:
	if node is Label:
		node.add_theme_font_override("font", label_font)

	for child in node.get_children():
		_set_fonts_recursive(child)


func _set_control_themes_recursive(node: Node) -> void:
	if node is Control:
		node.theme = control_theme

	for child in node.get_children():
		_set_control_themes_recursive(child)
    