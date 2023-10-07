class_name PhysBeam
extends RefCounted

var node_a: PhysNode
var node_b: PhysNode
var mass: float
var target_length: float
var stiffness: float
var damping: float

var length: float
var force: float

func _init(_node_a: PhysNode, _node_b: PhysNode, _mass_per_m: float, _stiffness: float, _damping: float):
	node_a = _node_a
	node_b = _node_b
	force = 0
	target_length = (node_a.position - node_b.position).length()
	length = target_length
	mass = _mass_per_m * target_length
	stiffness = _stiffness / length
	damping = _damping / length

func update_forces():
	var b_to_a = (node_a.position - node_b.position)
	length = b_to_a.length()
	var direction = b_to_a / length
	var velo = node_a.velocity - node_b.velocity
	var velo_s = velo.dot(direction)
	force = (target_length - length) * stiffness
	force -= velo_s * damping
	var force_vector = direction * force
	node_a.force += force_vector
	node_b.force -= force_vector
