class_name PhysBeam
extends RefCounted

var nodeA: PhysNode
var nodeB: PhysNode
var force: float
var mass: float
var length: float
var target_length: float
var stiffness: float
var damping: float
var new_force_multiplier = 1.25

func _init(_nodeA: PhysNode, _nodeB: PhysNode, _mass_per_m: float, _stiffness: float, _damping: float):
	nodeA = _nodeA
	nodeB = _nodeB
	force = 0
	target_length = (nodeA.position - nodeB.position).length()
	length = target_length
	mass = _mass_per_m * target_length
	stiffness = _stiffness / length
	damping = _damping / length

func update_forces():
	length = (nodeA.position - nodeB.position).length()
	var direction = (nodeA.position - nodeB.position).normalized()
	var veloA = nodeA.velocity.dot(direction)
	var veloB = nodeB.velocity.dot(direction)
	var velo = veloA - veloB
	var new_force = (target_length - length) * stiffness
	new_force = (new_force - velo * damping)
	force = force + new_force_multiplier * (new_force - force)
	nodeA.force += direction * force
	nodeB.force -= direction * force
