class_name BridgeDefinition extends RefCounted

var nodes
var beams
var roads
var delete_index
var add_mass_index
var add_mass
var z_fix
var car
var car_offset
var car_rotation

@warning_ignore("shadowed_variable")
func _init(def):
	nodes = def.get("nodes", [])
	beams = def.get("beams", [])
	roads = def.get("roads", [])
	delete_index = def.get("delete_index", -1)
	add_mass_index = def.get("add_mass_index", -1)
	add_mass = def.get("add_mass", 0)
	z_fix = def.get("z_fix", false)
	car = def.get("car", null)
	car_offset = def.get("car_offset", Vector3(0, 0, 0))
	car_rotation = def.get("car_rotation", 0.0)
