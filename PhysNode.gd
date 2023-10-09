class_name PhysNode extends RefCounted

var fixed: bool
var add_mass: float
var position: Vector3
var velocity: Vector3
var force: Vector3
var acc: Vector3
var mass: float

func _init(node_def):
	fixed = node_def[1]
	add_mass = node_def[2]
	position = node_def[0]
	velocity = Vector3.ZERO
	force = Vector3.ZERO
	acc = Vector3.ZERO
