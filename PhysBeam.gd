class_name PhysBeam
extends RefCounted

var node_a: PhysNode
var node_b: PhysNode
var mass: float
var target_length: float
var stiffness: float
var damping: float
var rk4_f: Array[Vector3]
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
	rk4_f.resize(4)

func update_forces(rki):
	var b_to_a = (node_a.rk4[rki].p - node_b.rk4[rki].p)
	var rklength = b_to_a.length()
	var direction = b_to_a / rklength
	var velo = node_a.rk4[rki].v - node_b.rk4[rki].v
	var velo_s = velo.dot(direction)
	var rkforce = (target_length - rklength) * stiffness
	rkforce -= velo_s * damping
	rk4_f[rki] = direction * rkforce
	node_a.rk4[rki].f += rk4_f[rki]
	node_b.rk4[rki].f -= rk4_f[rki]

func apply_step():
	length = (node_a.position - node_b.position).length()
	var b_to_a = (node_a.position - node_b.position)
	var direction = b_to_a / length
	force = ((rk4_f[0] + 2 * rk4_f[1] + 2 * rk4_f[2] + rk4_f[3]) / 6).dot(direction)
