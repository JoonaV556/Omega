class_name MapUI
extends Control


@export var galaxy_icon_texture : Texture

@export var galaxy_icon_scale : Vector2 = Vector2(1.0, 1.0)

@export var objects_root : Node2D

@export var object_info_label : Label

@export var selection_overlay_node : TextureRect

@export var map_ui_bg_root : CanvasLayer

@export var character_location_info_label: Label


var current_layer : LAYER

var _galaxy_icons : Array[Sprite2D]

var _object_selector : Selector

var _map_objects : Dictionary[Sprite2D, StellarObject]

var _active_context_menu : ContextMenu

var _active = true


signal on_layer_changed(new_layer : String)

signal on_map_opened_for_object(stellar_object : StellarObject)


enum LAYER {
	Galaxies, 
	Systems,
	}


enum OBJECT_TYPE {
	Galaxy,
	StarSystem
}


var object_type_strings : Dictionary = {
	OBJECT_TYPE.Galaxy: "Galaxy",
	OBJECT_TYPE.StarSystem: "Star System",
}


func _ready() -> void:
	_object_selector = Selector.new(self)
	_object_selector.on_selected.connect(on_object_selected)
	_object_selector.register_unselector_control(self)
	_object_selector.on_unselected.connect(on_object_unselected)
	_object_selector.on_selectable_rmb_clicked.connect(on_map_object_rmb_clicked)

	set_layer(LAYER.Galaxies)

	selection_overlay_node.hide()


func activate():
	self.show()
	objects_root.get_parent().show()
	map_ui_bg_root.show()
	_active = true


func deactivate():
	self.hide()
	map_ui_bg_root.hide()
	objects_root.get_parent().hide()
	_active = false


func toggle():
	if _active:
		deactivate()
	else:
		activate()


func on_map_object_rmb_clicked(map_object_node : Node):
	var sprite = map_object_node as Sprite2D
	
	if !sprite: 
		return
	
	var map_object = _map_objects[sprite]

	if !map_object:
		return

	if !map_object is Galaxy:
		return

	destroy_context_menu()

	var cm : ContextMenu = ContextMenu.new(self, get_local_mouse_position())
	cm.add_button("Enter map").connect(
		open_map_for_object.bind(map_object)
		)
	_active_context_menu = cm
	print('created context menu')


func open_map_for_object(object : StellarObject, show_map: bool = false):
	if !_active and show_map:
		activate()

	unselect()

	var layer = LAYER.Galaxies
	if object is Galaxy:
		layer = LAYER.Systems

	draw_objects(object.objects, layer)
	
	on_map_opened_for_object.emit(object)
	print('Opened local map for stellar object %s. Local map contains %s stellar objects.' % [object.name, object.objects.size()])


func set_character_location_info(character: Character):

	var type_str = object_type_strings[get_object_type_enum(character.location_object)] 

	character_location_info_label.text = String(
		"Character %s
		\n\t Flying in %s %s" % [character.name, type_str, character.location.name]
	)
	character_location_info_label.show()


func get_object_type_enum(object: StellarObject) -> OBJECT_TYPE:
	if object is Galaxy:
		return OBJECT_TYPE.Galaxy
	if object is StarSystem:
		return OBJECT_TYPE.StarSystem
	return OBJECT_TYPE.Galaxy


func on_object_selected(new_selection : Node):
	if !new_selection is Sprite2D:
		return

	var selected_sprite = new_selection as Sprite2D

	if !selected_sprite:
		return

	# Update object info ui
	var selected_object : StellarObject = _map_objects[selected_sprite]

	var object_type_str : String = "unknown"

	if selected_object is Galaxy:
		object_type_str = object_type_strings[OBJECT_TYPE.Galaxy]
	if selected_object is StarSystem:
		object_type_str = object_type_strings[OBJECT_TYPE.StarSystem]
		
	
	print('Selected %s' % [new_selection.name])

	object_info_label.text = String(
		"Object Info
		\n\t name: %s
		\n\t type: %s" % [selected_object.name, object_type_str]
	)
	object_info_label.show()

	selection_overlay_node.show()
	selection_overlay_node.position = selected_sprite.position


func on_object_unselected():
	print('Unselected')
	unselect()


func unselect():
	object_info_label.hide()
	selection_overlay_node.hide()

	destroy_context_menu()


func destroy_context_menu():
	if !_active_context_menu:
		return

	_active_context_menu.hide()
	_active_context_menu.queue_free()


func set_layer_int(new_layer : int):
	set_layer(new_layer as LAYER)


func set_layer(new_layer : LAYER):
	current_layer = new_layer
	on_layer_changed.emit(LAYER.keys()[current_layer])
	print('Map layer changed to %s' % [LAYER.keys()[current_layer]])


func draw_objects(objects : Array[StellarObject], objects_layer : int = LAYER.Galaxies):
	_map_objects.clear()

	for map_obj_sprite in objects_root.get_children():
		map_obj_sprite.queue_free()
	
	for so in objects:
		var map_object_sprite : Sprite2D = Sprite2D.new()

		objects_root.add_child(map_object_sprite)

		map_object_sprite.z_as_relative = false
		map_object_sprite.name = String('map_object_%s' % [so.name])
		map_object_sprite.position = so.local_coords
		map_object_sprite.texture = galaxy_icon_texture
		map_object_sprite.scale = galaxy_icon_scale
		map_object_sprite.centered = true

		_galaxy_icons.append(map_object_sprite)

		_map_objects[map_object_sprite] = so

		# Make map object selectable
		_object_selector.register_selectable_sprite2d(map_object_sprite)
	
	set_layer_int(objects_layer)


func update_galaxy_icons_scale(new_scale):
	for icon in _galaxy_icons:
		icon.scale = scale
