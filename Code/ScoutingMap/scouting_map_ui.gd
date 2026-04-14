## GUI manager script for the scouting map
class_name ScoutingMapUI
extends Node

@export var scouting_map: ScoutingMap
@export var map_cell_prefab: PackedScene
@export var map_root_control: Control
@export var select_entry_side_hint:RichTextLabel
@export var map_begin_btn:Button
@export var cell_entry_side_btn_n:Button
@export var cell_entry_side_btn_s:Button
@export var cell_entry_side_btn_w:Button
@export var cell_entry_side_btn_e:Button
@export var map_cell_pixel_separation: int = 1
@export var map_cell_completed_color: Color = Color.FOREST_GREEN
@export var map_cell_can_explore_color: Color = Color.FOREST_GREEN
@export var map_cell_border_unselected_color:Color = Color(1.0,1.0,1.0, 0.3)
@export var map_cell_border_selected_color:Color = Color(1.0,1.0,1.0, 0.7)
@export var entry_side_hint_color_inactive:Color = Color(1.0,1.0,1.0, 0.3)
@export var entry_side_hint_color_active:Color = Color(1.0,1.0,1.0, 1.0)

var selected_cell_gui: ScoutingMapCellUI

enum CellEntrySide {North=0, South=1, West=2, East=3}
var desired_entry_side:CellEntrySide

func _ready() -> void:
	map_root_control.set_visible(false)
	map_begin_btn.disabled = true
	cell_entry_side_btn_n.disabled = true
	cell_entry_side_btn_s.disabled = true
	cell_entry_side_btn_w.disabled = true
	cell_entry_side_btn_e.disabled = true
	select_entry_side_hint.add_theme_color_override("default_color",entry_side_hint_color_inactive)

func _process(_delta: float) -> void:
	if Input.is_action_just_released("ToggleScoutingMap"):
		if map_root_control.visible == true:
			map_root_control.set_visible(false)
		else:
			map_root_control.set_visible(true)

func generate_ui():
	var _map_size: Vector2i = scouting_map.get_map_grid_size()
	
	# create and fill map ui grid wi th map cells
	var _map_vbox:VBoxContainer = VBoxContainer.new()
	_map_vbox.name = "Map VBox (generated)"
	map_root_control.add_child(_map_vbox)
	_map_vbox.add_theme_constant_override("separation", map_cell_pixel_separation)
	
	# create horizontal rows
	for i in range(_map_size.y):
		var _map_hbox:HBoxContainer = HBoxContainer.new()
		_map_hbox.name = "Map HBox (generated)"
		_map_hbox.add_theme_constant_override("separation", map_cell_pixel_separation)
		_map_vbox.add_child(_map_hbox) 
		_map_vbox.move_child(_map_hbox, 0) # we need to move the row to index 0 so it renders above rows added earlier, instead of below
		
		# fill row with cells
		for x in range(_map_size.x):
			var _cell_ui_node = map_cell_prefab.instantiate()
			var _cell_coord = Vector2i(x, i)
			_cell_ui_node.name = str("Map Cell "+str(_cell_coord)) 
			# highlight the cell with color if needed
			update_cell_color(_cell_ui_node, Vector2i(x, i))
			set_cell_border_color(_cell_ui_node, map_cell_border_unselected_color)
			_map_hbox.add_child(_cell_ui_node)
			_cell_ui_node.on_clicked.connect(self.on_gui_cell_clicked)
			_cell_ui_node.coords = Vector2i(x, i)

func on_gui_cell_clicked(_cell_ui: ScoutingMapCellUI):
	if scouting_map.select_cell(_cell_ui.coords):
		# un-highlight old selection
		if selected_cell_gui != null:
			set_cell_border_color(selected_cell_gui, map_cell_border_unselected_color)
			
		# highlight new selection
		selected_cell_gui = _cell_ui
		set_cell_border_color(selected_cell_gui, map_cell_border_selected_color)
		print_debug("selected map cell "+str(_cell_ui.name)+"!")
		
		# activate begin button
		if scouting_map.can_explore(selected_cell_gui.coords):
			map_begin_btn.disabled = false
			# update entry side selection buttons
			select_entry_side_hint.add_theme_color_override("default_color",entry_side_hint_color_active)
			var _entry_sides = scouting_map.get_enterable_sides(scouting_map.selected_cell)
			if _entry_sides.has(ScoutingMap.CellEntrySide.North):
				cell_entry_side_btn_n.disabled = false
			else:
				cell_entry_side_btn_n.disabled = true
				
			if _entry_sides.has(ScoutingMap.CellEntrySide.South):
				cell_entry_side_btn_s.disabled = false
			else:
				cell_entry_side_btn_s.disabled = true
				
			if _entry_sides.has(ScoutingMap.CellEntrySide.West):
				cell_entry_side_btn_w.disabled = false
			else:
				cell_entry_side_btn_w.disabled = true
				
			if _entry_sides.has(ScoutingMap.CellEntrySide.East):
				cell_entry_side_btn_e.disabled = false	
			else:
				cell_entry_side_btn_e.disabled = true
		else:
			select_entry_side_hint.add_theme_color_override("default_color",entry_side_hint_color_inactive)
			map_begin_btn.disabled = true
			# update entry side selection buttons
			cell_entry_side_btn_n.disabled = true
			cell_entry_side_btn_s.disabled = true
			cell_entry_side_btn_w.disabled = true
			cell_entry_side_btn_e.disabled = true

func on_entry_side_btn_pressed(_side:String):
	match _side:
		"n":
			desired_entry_side = CellEntrySide.North
		"s":
			desired_entry_side = CellEntrySide.South
		"e":
			desired_entry_side = CellEntrySide.East
		"w":
			desired_entry_side = CellEntrySide.West

func on_begin_btn_pressed():
	var _e_sides = scouting_map.get_enterable_sides(scouting_map.selected_cell)
	# todo implement entering from desired side
	scouting_map.enter_selected_cell(
		scouting_map.get_enterable_sides(scouting_map.selected_cell)[0]
	)

func set_cell_border_color(_cell_ui:ScoutingMapCellUI, _color:Color):
	var _border:ReferenceRect = _cell_ui.get_child(0)
	_border.border_color = _color

func update_cell_color(_cell_ui: ColorRect, _map_coords: Vector2i):
	var _cell_data: ScoutingMapCell = scouting_map.get_cell_on_map(_map_coords)
	# highlight cells the player can enter
	if scouting_map.can_explore(_map_coords):
		_cell_ui.color = map_cell_can_explore_color
	# highlight completed cells
	if _cell_data.completed == true:
		_cell_ui.color = map_cell_completed_color
