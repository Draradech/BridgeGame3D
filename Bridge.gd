extends Node

signal simspeed_changed

var beam_mass_per_m = 7.0 # kg/m
var beam_stiffness = 20.0e6 # N/m * m
var beam_damping = 15.0e3 # N/(m/s) * m
var node_mass = 10.0 # kg
var gravity = 9.81 # m/s^2
var damping = 0.99 # velocity left after 1s
var physics_fps = 1000
var min_render_fps = 30
var simspeed = 1.0

var node_positions: Array[Vector3] = [
	Vector3(-10, 0, -1.5),
	Vector3( -5, 0, -1.5),
	Vector3(  0, 0, -1.5),
	Vector3(  5, 0, -1.5),
	Vector3( 10, 0, -1.5),

	Vector3(-10, 0, 1.5),
	Vector3( -5, 0, 1.5),
	Vector3(  0, 0, 1.5),
	Vector3(  5, 0, 1.5),
	Vector3( 10, 0, 1.5),

	Vector3(-7.5, 4, 0),
	Vector3(-2.5, 4, 0),
	Vector3( 2.5, 4, 0),
	Vector3( 7.5, 4, 0),
	
	Vector3(-1.5, 4, 0),
	Vector3(-0.5, 4, 0),
	Vector3(0.5, 4, 0),
	Vector3(1.5, 4, 0),
	
	Vector3(-0.5, 15, 0),
	Vector3(-0.5, 10, 0),
	Vector3(-0.5, 5, 0),

	Vector3(0.5, 15, 0),
	Vector3(0.5, 14, 0),
	Vector3(0.5, 13, 0),
	Vector3(0.5, 12, 0),
	Vector3(0.5, 11, 0),
	Vector3(0.5, 10, 0),
	Vector3(0.5, 9, 0),
	Vector3(0.5, 8, 0),
	Vector3(0.5, 7, 0),
	Vector3(0.5, 6, 0),
	Vector3(0.5, 5, 0),
	
	#Vector3( 10, 5, 1.5),
	#Vector3( 10, 5, -1.5),
]

var beam_connections = [
	[0, 1], [0, 10], [10, 1],
	[1, 2], [1, 11], [11, 2],
	[2, 3], [2, 12], [12, 3],
	[3, 4], [3, 13], [13, 4],

	[5, 6], [5, 10], [10, 6],
	[6, 7], [6, 11], [11, 7],
	[7, 8], [7, 12], [12, 8],
	[8, 9], [8, 13], [13, 9],
	
	[10, 11], 
	[11, 14], [14, 15], [15, 16], [16, 17], [17, 12], 
	#[11, 12],
	[12, 13],
	
	[0, 5], [1, 6], [2, 7], [3, 8], [4, 9],
	[0, 6], [1, 7], [2, 8], [3, 9],
	
	[18, 19], [19, 20],
	[21, 22], [22, 23], [23, 24], [24, 25], [25, 26], [26, 27], [27, 28], [28, 29], [29, 30], [30, 31],
	#[32, 9], [33, 4],
]

var nodes: Array[PhysNode]
var beams: Array[PhysBeam]

func update_simspeed():
	Engine.physics_ticks_per_second = (int)(physics_fps * simspeed)
	@warning_ignore("integer_division")
	Engine.max_physics_steps_per_frame = max(2, Engine.physics_ticks_per_second / min_render_fps)
	simspeed_changed.emit()

func _ready():
	update_simspeed()
	$MultiMeshBeams.multimesh.instance_count = beam_connections.size()
	$MultiMeshNodes.multimesh.instance_count = node_positions.size()
	for i in range(node_positions.size()):
		nodes.append(PhysNode.new(node_positions[i], false))
	for i in range(beam_connections.size()):
		beams.append(PhysBeam.new(
									nodes[beam_connections[i][0]],
									nodes[beam_connections[i][1]],
									beam_mass_per_m,
									beam_stiffness,
									beam_damping))
	nodes[0].fixed = true
	#nodes[4].fixed = true
	nodes[5].fixed = true
	#nodes[9].fixed = true
	nodes[10].fixed = true
	nodes[18].fixed = true
	nodes[21].fixed = true
	#nodes[32].fixed = true
	#nodes[33].fixed = true
	update_masses()

func _process(_delta):
	for i in range(nodes.size()):
		var n = nodes[i]
		var t = Transform3D()
		t = t.translated(n.position)
		$MultiMeshNodes.multimesh.set_instance_transform(i, t)
		$MultiMeshNodes.multimesh.set_instance_color(i, Color.RED if n.fixed else Color.ORANGE if n.mass > 2000 else Color.WHITE)
	$MultiMeshNodes.multimesh.set_visible_instance_count(nodes.size())
	for i in range(beams.size()):
		var b = beams[i]
		var t = Transform3D()
		var ab = b.node_b.position - b.node_a.position
		t = t.looking_at(ab, Vector3(2, 3, 4))
		t = t.rotated_local(Vector3.RIGHT, -PI / 2)
		t = t.translated_local(Vector3(0, b.length/2, 0))
		t = t.scaled_local(Vector3(1, b.length, 1))
		t = t.translated(b.node_a.position)
		$MultiMeshBeams.multimesh.set_instance_transform(i, t)
		$MultiMeshBeams.multimesh.set_instance_color(i, Color.from_hsv(clamp(0.33 - 0.33 * b.force / 30e3, 0, 0.66), 1.0, 1.0))
	$MultiMeshBeams.multimesh.set_visible_instance_count(beams.size())

func _physics_process(_delta):
	var local_delta = 1.0/physics_fps
	var velo_factor = pow(damping, local_delta)
	
	for rki in range(4):
		var dt = (0.5 if rki != 3 else 1.0) * local_delta
		for n in nodes:
			n.rk4[rki].p = n.position
			n.rk4[rki].v = n.velocity
			if rki != 0 and not n.fixed:
					n.rk4[rki].p += dt * n.rk4[rki - 1].v
					n.rk4[rki].v += dt * n.rk4[rki - 1].a
			n.rk4[rki].f = Vector3.DOWN * n.mass * gravity
		for b in beams:
			b.update_forces(rki)
		for n in nodes:
			n.rk4[rki].a = n.rk4[rki].f / n.mass
	
	# apply
	for n in nodes:
		n.force = (n.rk4[0].f + 2 * n.rk4[1].f + 2 * n.rk4[2].f + n.rk4[3].f) / 6
		if not n.fixed:
			n.position += local_delta * (n.rk4[0].v + 2 * n.rk4[1].v + 2 * n.rk4[2].v + n.rk4[3].v) / 6
			n.velocity += local_delta * (n.rk4[0].a + 2 * n.rk4[1].a + 2 * n.rk4[2].a + n.rk4[3].a) / 6
			n.velocity *= velo_factor
	for b in beams:
		b.apply_step()

func update_masses():
	for n in nodes:
		n.mass = node_mass
	for b in beams:
		b.node_a.mass += b.mass / 2
		b.node_b.mass += b.mass / 2
	nodes[14].mass += 14
	nodes[20].mass += 2000
	nodes[31].mass += 2000

func _unhandled_input(event):
	if event.is_action_pressed("ui_down"):
		beams.remove_at(25)
	if event.is_action_pressed("ui_up"):
		nodes[9].mass += 100
	if event.is_action_pressed("ui_right"):
		if simspeed * 2 <= 8:
			simspeed *= 2
			update_simspeed()
	if event.is_action_pressed("ui_left"):
		if simspeed / 2 >= 1.0 / 16:
			simspeed /= 2
			update_simspeed()
