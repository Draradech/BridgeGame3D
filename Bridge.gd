class_name Bridge extends RefCounted

var beam_mass_per_m = 7.0 # kg/m
var beam_stiffness = 10.0e6 # N/m * m
var beam_damping = 20.0e3 # N/(m/s) * m
var node_mass = 10.0 # kg
var gravity = 9.81 # m/s^2
var damping = 0.99 # velocity left after 1s

var delete_index: int
var add_mass_index: int
var add_mass: float
var z_fix: bool

var nodes: Array[PhysNode]
var beams: Array[PhysBeam]

func _init(bridge_def: BridgeDefinition):
	for i in range(bridge_def.nodes.size()):
		nodes.append(PhysNode.new(bridge_def.nodes[i]))
	for i in range(bridge_def.beams.size()):
		beams.append(PhysBeam.new(	nodes[bridge_def.beams[i][0]],
									nodes[bridge_def.beams[i][1]],
									beam_mass_per_m,
									beam_stiffness,
									beam_damping))
	delete_index = bridge_def.delete_index
	add_mass_index = bridge_def.add_mass_index
	add_mass = bridge_def.add_mass
	z_fix = bridge_def.z_fix

func update_masses():
	for n in nodes:
		n.mass = node_mass + n.add_mass
	for b in beams:
		b.node_a.mass += b.mass / 2
		b.node_b.mass += b.mass / 2

func sim_step(delta):
	update_masses()
	var velo_factor = pow(damping, delta)
	for n in nodes:
		n.force = Vector3.DOWN * n.mass * gravity
	for b in beams:
		b.update_forces()
	for n in nodes:
		if not n.fixed:
			n.acc = n.force / n.mass
			n.velocity += delta * n.acc
			n.velocity *= velo_factor
			n.position += delta * n.velocity
	if z_fix:
		for n in nodes:
			n.force.z = 0
			n.velocity.z = 0
			n.position.z = 0

func update_mesh(node_mesh, beam_mesh):
	for i in range(nodes.size()):
		var n = nodes[i]
		var t = Transform3D()
		t = t.scaled_local(log(n.mass) * Vector3.ONE * 0.43)
		t = t.translated(n.position)
		node_mesh.set_instance_transform(i, t)
		node_mesh.set_instance_color(i, Color.RED if n.fixed else Color.WHITE)
	node_mesh.set_visible_instance_count(nodes.size())
	for i in range(beams.size()):
		var b = beams[i]
		var t = Transform3D()
		var ab = b.node_b.position - b.node_a.position
		t = t.looking_at(ab, Vector3(2, 3, 4))
		t = t.rotated_local(Vector3.RIGHT, -PI / 2)
		t = t.translated_local(Vector3(0, b.length/2, 0))
		t = t.scaled_local(Vector3(1.5, b.length, 1.5))
		t = t.translated(b.node_a.position)
		beam_mesh.set_instance_transform(i, t)
		beam_mesh.set_instance_color(i, Color.from_hsv(clamp(0.33 - 0.33 * b.force / 30e3, 0, 0.66), 1.0, 1.0))
		#beam_mesh.set_instance_color(i, Color.from_hsv(0.0 if b.force > 0 else 0.66, clamp(abs(b.force) / 30e3, 0, 1), 1.0))
	beam_mesh.set_visible_instance_count(beams.size())

func event_add_mass():
	if add_mass_index >= 0:
		nodes[add_mass_index].add_mass += add_mass

func event_delete_beam():
	if delete_index >= 0 and delete_index < beams.size():
		beams.remove_at(delete_index)
