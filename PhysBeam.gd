class_name PhysBeam
extends RefCounted

# parameters
var node_a: PhysNode
var node_b: PhysNode
var mass: float
var stiffness: float
var damping: float
# calculate
var target_length: float
# dynamic
var length: float
var force: float

@warning_ignore("shadowed_variable")
func _init(node_a: PhysNode, node_b: PhysNode, mass_per_m: float, stiffness: float, damping: float):
	self.node_a = node_a
	self.node_b = node_b
	force = 0
	length = (node_a.position - node_b.position).length()
	target_length = length
	self.mass = mass_per_m * length
	self.stiffness = stiffness / length
	self.damping = damping / length

func update_forces():
	var b_to_a = (node_a.position - node_b.position)
	length = b_to_a.length()
	var direction = b_to_a / length
	var velo = node_b.velocity - node_a.velocity
	var velo_s = velo.dot(direction)
	var spring_force = (target_length - length) * stiffness
	var damp_force = velo_s * damping
	force = spring_force + damp_force
	var force_vector = direction * force
	node_a.force += force_vector
	node_b.force -= force_vector
