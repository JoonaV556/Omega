class_name CellTemplateLibrary
extends Node

var template_groups : Dictionary[StringName, Array]

const small_road_group_name : StringName = StringName("small_road")
const highway_group_name : StringName = StringName("highway")
const road_connector_group_name : StringName = StringName("road_connector")


func get_random_small_road_template(road_cell_connections : int) -> RoadCellTemplate:
	var group = template_groups[small_road_group_name]
	var matching_templates = group.filter(
		func(tmpl : RoadCellTemplate):
			return tmpl.connections == road_cell_connections
	)

	return matching_templates.pick_random()

func get_random_highway_template(highway_cell_connections : int) -> RoadCellTemplate:
	var matching_templates = template_groups[highway_group_name].filter(
		func(tmpl : RoadCellTemplate):
			return tmpl.connections == highway_cell_connections
	)

	return matching_templates.pick_random()

func get_random_connector_template(connector_sr_connections : int, connector_hw_connections : int) -> RoadConnectorCellTemplate:
	var matching_templates = template_groups[road_connector_group_name].filter(
		func(tmpl : RoadConnectorCellTemplate):
			return (tmpl.small_road_connections == connector_sr_connections) and (tmpl.highway_connections == connector_hw_connections)
	)

	return matching_templates.pick_random()
