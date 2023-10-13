class_name Bridge extends RefCounted

var materials = [
	[ 4.0, 18e6, 230e3, 0.5e3, 1], #0 wood
	[16.0, 80e6, 500e3, 0.5e3, 1], #1 steel
	[16.0, 30e3, 500e3, 2.5e3, 3], #2 car spring
]
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
	physics.construct(gravity, velo_damping, def.z_fix, node_mass)
	for i in range(def.nodes.size()):
		physics.add_node(def.nodes[i][0], def.nodes[i][1], def.nodes[i][2], def.nodes[i][3] if def.nodes[i].size() >= 4 else false)
	for i in range(def.beams.size()):
		var material = materials[def.beams[i][2] if def.beams[i].size() >= 3 else 0]
		physics.add_beam(	def.beams[i][0],
							def.beams[i][1], 
							material[0],
							material[1],
							material[3],
							material[4]   )
	for i in range(def.roads.size()):
		physics.add_road(def.roads[i][0], def.roads[i][1], 60.0)
	delete_index = def.delete_index
	add_mass_index = def.add_mass_index
	add_mass = def.add_mass
	if def.car:
		for i in range(def.car.nodes.size()):
			physics.add_node(def.car.nodes[i][0].rotated(Vector3.UP, def.car_rotation) + def.car_offset, def.car.nodes[i][1], def.car.nodes[i][2], def.car.nodes[i][3] if def.car.nodes[i].size() >= 4 else false)
		for i in range(def.car.beams.size()):
			var material = materials[def.car.beams[i][2] if def.car.beams[i].size() >= 3 else 0]
			physics.add_beam(	def.nodes.size() + def.car.beams[i][0],
								def.nodes.size() + def.car.beams[i][1], 
								material[0],
								material[1],
								material[3],
								material[4]   )

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
		var b1a_up = 0.07 * (b1a - b1b).cross(b1a - b2a).normalized()
		var b1b_up = 0.07 * (b1a - b1b).cross(b1b - b2b).normalized()
		var b2a_up = 0.07 * (b2b - b2a).cross(b2a - b1a).normalized()
		var b2b_up = 0.07 * (b2b - b2a).cross(b2b - b1b).normalized()
		var center_up = 0.25 * (b1a_up + b1b_up + b2a_up + b2b_up)
		var b1a_top = b1a + b1a_up
		var b1b_top = b1b + b1b_up
		var b2a_top = b2a + b2a_up
		var b2b_top = b2b + b2b_up
		var center_top = center + center_up
		road_mesh.surface_set_normal((b1b_top - b1a_top).cross(center_top - b1a_top))
		road_mesh.surface_add_vertex(b1b_top)
		road_mesh.surface_add_vertex(b1a_top)
		road_mesh.surface_add_vertex(center_top)
		road_mesh.surface_set_normal((b2a_top - b2b_top).cross(center_top - b2a_top))
		road_mesh.surface_add_vertex(b2a_top)
		road_mesh.surface_add_vertex(b2b_top)
		road_mesh.surface_add_vertex(center_top)
		road_mesh.surface_set_normal((b1a_top - b2a_top).cross(center_top - b1a_top))
		road_mesh.surface_add_vertex(b1a_top)
		road_mesh.surface_add_vertex(b2a_top)
		road_mesh.surface_add_vertex(center_top)
		road_mesh.surface_set_normal((b2b_top - b1b_top).cross(center_top - b1b_top))
		road_mesh.surface_add_vertex(b2b_top)
		road_mesh.surface_add_vertex(b1b_top)
		road_mesh.surface_add_vertex(center_top)
		var b1a_bottom = b1a - b1a_up
		var b1b_bottom = b1b - b1b_up
		var b2a_bottom = b2a - b2a_up
		var b2b_bottom = b2b - b2b_up
		var center_bottom = center - center_up
		road_mesh.surface_set_normal((b1a_bottom - b1b_bottom).cross(center_bottom - b1a_bottom))
		road_mesh.surface_add_vertex(b1a_bottom)
		road_mesh.surface_add_vertex(b1b_bottom)
		road_mesh.surface_add_vertex(center_bottom)
		road_mesh.surface_set_normal((b2b_bottom - b2a_bottom).cross(center_bottom - b2a_bottom))
		road_mesh.surface_add_vertex(b2b_bottom)
		road_mesh.surface_add_vertex(b2a_bottom)
		road_mesh.surface_add_vertex(center_bottom)
		road_mesh.surface_set_normal((b2a_bottom - b1a_bottom).cross(center_bottom - b1a_bottom))
		road_mesh.surface_add_vertex(b2a_bottom)
		road_mesh.surface_add_vertex(b1a_bottom)
		road_mesh.surface_add_vertex(center_bottom)
		road_mesh.surface_set_normal((b1b_bottom - b2b_bottom).cross(center_bottom - b1b_bottom))
		road_mesh.surface_add_vertex(b1b_bottom)
		road_mesh.surface_add_vertex(b2b_bottom)
		road_mesh.surface_add_vertex(center_bottom)
	road_mesh.surface_end()

func sim_step(delta, batching):
	physics.sim_step(delta, batching)

func update_mesh(node_mesh, beam_mesh):
	update_road_mesh()
	for i in range(physics.get_num_nodes()):
		var t = Transform3D()
		var d = log(physics.get_node_mass(i)) * 0.43 * 0.2
		var node = null
		if def.nodes.size() > i:
			node = def.nodes[i]
		else:
			if def.car and def.car.nodes.size() > i - def.nodes.size():
				node = def.car.nodes[i - def.nodes.size()]
		if node and node.size() >= 4 and node[3]:
			d = 0.6
		t = t.scaled_local(d * Vector3.ONE)
		t = t.translated(physics.get_node_position(i))
		node_mesh.set_instance_transform(i, t)
		node_mesh.set_instance_color(i, Color.RED if physics.get_node_fixed(i) else Color.WHITE)
		if node and node.size() >= 4 and node[3]:
			node_mesh.set_instance_color(i, Color(0.1, 0.1, 0.1))
	node_mesh.set_visible_instance_count(physics.get_num_nodes())
	for i in range(physics.get_num_beams()):
		var beam = null
		if def.beams.size() > i:
			beam = def.beams[i]
		else:
			if def.car and def.car.beams.size() > i - def.beams.size():
				beam = def.car.beams[i - def.beams.size()]
		var material = materials[0]
		if beam and beam.size() >= 3: material = materials[beam[2]]
		var t = Transform3D()
		var ab = physics.get_beam_pos_b(i) - physics.get_beam_pos_a(i)
		t = t.looking_at(ab, Vector3(2, 3, 4))
		t = t.rotated_local(Vector3.RIGHT, -PI / 2)
		t = t.translated_local(Vector3(0, physics.get_beam_length(i)/2, 0))
		t = t.scaled_local(Vector3(0.15, physics.get_beam_length(i), 0.15))
		t = t.translated(physics.get_beam_pos_a(i))
		beam_mesh.set_instance_transform(i, t)
		beam_mesh.set_instance_color(i, Color.from_hsv(clamp(0.33 - 0.33 * physics.get_beam_force(i) / material[2], 0, 0.66), 1.0, 1.0))
	beam_mesh.set_visible_instance_count(physics.get_num_beams())

func event_add_mass():
	if add_mass_index >= 0:
		physics.add_mass(add_mass_index, add_mass)

func event_break_beam():
	if delete_index >= 0 and delete_index < physics.get_num_beams():
		physics.break_beam(delete_index)
		delete_index += 1
