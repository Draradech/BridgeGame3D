class_name Bridge extends RefCounted

var beam_mass_per_m = 4.0 # kg/m
var beam_stiffness = 18e6 # N/m * m
var beam_damping = 0.5e3 # N/(m/s) / kg
var node_mass = 10.0 # kg
var gravity = 9.81 # m/s^2
var velo_damping = 0.99 # velocity left after 1s

var delete_index: int
var add_mass_index: int
var add_mass: float

var physics
var def
var road_mesh: ImmediateMesh

func _init(bridge_def: BridgeDefinition, roadmesh: ImmediateMesh):
	self.road_mesh = roadmesh
	def = bridge_def
	physics = SpringPhysics.new()
	physics.construct(gravity, velo_damping, bridge_def.z_fix, node_mass)
	for i in range(bridge_def.nodes.size()):
		physics.addNode(bridge_def.nodes[i][0], bridge_def.nodes[i][1], bridge_def.nodes[i][2])
	for i in range(bridge_def.beams.size()):
		physics.addBeam(	bridge_def.beams[i][0],
							bridge_def.beams[i][1], 
							beam_mass_per_m,
							#(0.03e6 if (i == 31 or i == 34 or i == 37 or i == 40) else beam_stiffness), # car prototype
							beam_stiffness,
							beam_damping)
							#(1.5e3 if (i == 31 or i == 34 or i == 37 or i == 40) else beam_damping)) # car prototype
	delete_index = bridge_def.delete_index
	add_mass_index = bridge_def.add_mass_index
	add_mass = bridge_def.add_mass

func update_road_mesh():
	if def.roads.size() == 0: return
	road_mesh.clear_surfaces()
	road_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	road_mesh.surface_set_color(Color.DARK_SLATE_GRAY * 0.5)
	for i in range(def.roads.size()):
		var b1a = physics.get_beam_pos_a(def.roads[i][0])
		var b1b = physics.get_beam_pos_b(def.roads[i][0])
		var b2a = physics.get_beam_pos_a(def.roads[i][1])
		var b2b = physics.get_beam_pos_b(def.roads[i][1])
		var center = 0.25 * (b1a + b1b + b2a + b2b)
		#print(b1a, b1b, b2a, b2b, center)
		road_mesh.surface_set_normal((b1a - b1b).cross(center - b1a))
		road_mesh.surface_add_vertex(b1a)
		road_mesh.surface_add_vertex(b1b)
		road_mesh.surface_add_vertex(center)
		road_mesh.surface_set_normal((b2a - b2b).cross(center - b2a))
		road_mesh.surface_add_vertex(b2a)
		road_mesh.surface_add_vertex(b2b)
		road_mesh.surface_add_vertex(center)
		road_mesh.surface_set_normal((b1a - b2a).cross(center - b1a))
		road_mesh.surface_add_vertex(b1a)
		road_mesh.surface_add_vertex(b2a)
		road_mesh.surface_add_vertex(center)
		road_mesh.surface_set_normal((b1b - b2b).cross(center - b1b))
		road_mesh.surface_add_vertex(b1b)
		road_mesh.surface_add_vertex(b2b)
		road_mesh.surface_add_vertex(center)
	road_mesh.surface_end()

func sim_step(delta, batching):
	physics.sim_step(delta, batching)

func update_mesh(node_mesh, beam_mesh):
	update_road_mesh()
	for i in range(physics.get_num_nodes()):
		var t = Transform3D()
		t = t.scaled_local(log(physics.get_node_mass(i)) * Vector3.ONE * 0.43)
		#t = t.scaled_local(Vector3.ONE * (3.0 if def.nodes[i][1] else 0.75))
		t = t.translated(physics.get_node_position(i))
		node_mesh.set_instance_transform(i, t)
		node_mesh.set_instance_color(i, Color.RED if physics.get_node_fixed(i) else Color.WHITE)
	node_mesh.set_visible_instance_count(physics.get_num_nodes())
	for i in range(physics.get_num_beams()):
		var t = Transform3D()
		var ab = physics.get_beam_pos_b(i) - physics.get_beam_pos_a(i)
		t = t.looking_at(ab, Vector3(2, 3, 4))
		t = t.rotated_local(Vector3.RIGHT, -PI / 2)
		t = t.translated_local(Vector3(0, physics.get_beam_length(i)/2, 0))
		t = t.scaled_local(Vector3(1.5, physics.get_beam_length(i), 1.5))
		t = t.translated(physics.get_beam_pos_a(i))
		beam_mesh.set_instance_transform(i, t)
		beam_mesh.set_instance_color(i, Color.from_hsv(clamp(0.33 - 0.33 * physics.get_beam_force(i) / 200e3, 0, 0.66), 1.0, 1.0))
		#beam_mesh.set_instance_color(i, Color.from_hsv(0.0 if b.force > 0 else 0.66, clamp(abs(b.force) / 30e3, 0, 1), 1.0))
	beam_mesh.set_visible_instance_count(physics.get_num_beams())

func event_add_mass():
	if add_mass_index >= 0:
		physics.add_mass(add_mass_index, add_mass)

func event_break_beam():
	if delete_index >= 0 and delete_index < physics.get_num_beams():
		physics.break_beam(delete_index)
		delete_index += 1
