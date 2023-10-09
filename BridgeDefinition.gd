class_name BridgeDefinition extends RefCounted

var nodes
var beams
var delete_index
var add_mass_index
var add_mass
var z_fix

@warning_ignore("shadowed_variable")
func _init(nodes = [], beams = [], delete_index = -1, add_mass_index = -1, add_mass = 0, z_fix = false):
	self.nodes = nodes
	self.beams = beams
	self.delete_index = delete_index
	self.add_mass_index = add_mass_index
	self.add_mass = add_mass
	self.z_fix = z_fix
