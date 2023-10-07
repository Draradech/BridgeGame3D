class_name PhysNode
extends RefCounted

var position: Vector3
var velocity: Vector3
var acc: Vector3
var force: Vector3
var mass: float
var fixed: bool

func _init(_position: Vector3, _fixed: bool):
	position = _position
	velocity = Vector3.ZERO
	acc = Vector3.ZERO
	force = Vector3.ZERO
	mass = 1
	fixed = _fixed
