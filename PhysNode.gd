class_name PhysNode
extends RefCounted

var position: Vector3
var velocity: Vector3
var force: Vector3
var mass: float
var fixed: bool

class State extends RefCounted:
	var p: Vector3
	var v: Vector3
	var f: Vector3
	var a: Vector3

var rk4: Array[State]

func _init(_position: Vector3, _fixed: bool):
	position = _position
	velocity = Vector3.ZERO
	mass = 1
	fixed = _fixed
	for i in range(4):
		rk4.append(State.new())
