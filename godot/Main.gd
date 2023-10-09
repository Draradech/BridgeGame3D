extends Node

var physics_fps = 4000
var min_render_fps = 30.0
var multistep_at_1x = 16.0
var multistep = 16
var bridge

func _ready():
	Engine.physics_ticks_per_second = (int)(physics_fps / multistep_at_1x)
	Engine.max_physics_steps_per_frame = max(2, Engine.physics_ticks_per_second / min_render_fps)
	update_simspeed()
	set_scene(Playground.bridge_def)
	
func _process(_delta):
	$UI/LabelFPS.text = "%d iter/s\n%d fps" % \
		[min(Engine.get_frames_per_second() * Engine.max_physics_steps_per_frame, Engine.physics_ticks_per_second) * multistep, Engine.get_frames_per_second()]
	bridge.update_mesh($MultiMeshNodes.multimesh, $MultiMeshBeams.multimesh)

func _physics_process(_delta):
	bridge.sim_step(1.0 / physics_fps, multistep)

func update_simspeed():
	if multistep >= multistep_at_1x:
		$UI/LabelPhys.text = "max engine phys per render: %d\nengine phys rate: %d fps\nsim phys rate: %d fps\nmultistep: %d\nsim speed: %d x" % \
			[Engine.max_physics_steps_per_frame, Engine.physics_ticks_per_second, physics_fps, multistep, multistep / multistep_at_1x]
	else:
		$UI/LabelPhys.text = "max engine phys per render: %d\nengine phys rate: %d fps\nsim phys rate: %d fps\nmultistep: %d\nsim speed: 1/%d x" % \
			[Engine.max_physics_steps_per_frame, Engine.physics_ticks_per_second, physics_fps, multistep, multistep_at_1x / multistep]

func set_scene(bridge_def):
	$MultiMeshNodes.multimesh.instance_count = bridge_def.nodes.size() + bridge_def.beams.size() * 2
	$MultiMeshBeams.multimesh.instance_count = bridge_def.beams.size() * 2
	bridge = Bridge.new(bridge_def)

func _unhandled_key_input(event):
	if not event.pressed:
		return
	match event.keycode:
		KEY_ESCAPE:
			get_tree().quit()
		KEY_F:
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_size(Vector2i(1600, 900))
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		KEY_DOWN:
			if bridge:
				bridge.event_delete_beam()
		KEY_UP:
			if bridge:
				bridge.event_add_mass()
		KEY_RIGHT:
			if multistep * 2 <= 256 * multistep_at_1x:
				multistep *= 2
				update_simspeed()
		KEY_LEFT:
			if multistep / 2.0 >= 1:
				multistep /= 2
				update_simspeed()
		KEY_0:
			set_scene(BridgeDefinition.new())
		KEY_1:
			set_scene(AngeTruss1.bridge_def)
		KEY_2:
			set_scene(AngeTruss2.bridge_def)
		KEY_3:
			set_scene(AngeTruss3.bridge_def)
		KEY_4:
			set_scene(AngeTruss4.bridge_def)
		KEY_5:
			set_scene(AngeTruss5.bridge_def)
		KEY_6:
			set_scene(Playground.bridge_def)
		KEY_7:
			set_scene(PerfTest.bridge_def)
		KEY_8:
			set_scene(WeightCompare.bridge_def)
