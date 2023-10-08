extends Node

var physics_fps = 4000
var min_render_fps = 30.0
var simspeed = 1.0
var bridge

func _ready():
	update_simspeed()
	set_scene(Playground.bridge_def)
	
func _process(_delta):
	$UI/LabelFPS.text = "%d fps" % Engine.get_frames_per_second()
	bridge.update_mesh($MultiMeshNodes.multimesh, $MultiMeshBeams.multimesh)

func _physics_process(_delta):
	bridge.sim_step(1.0 / physics_fps)

func update_simspeed():
	Engine.physics_ticks_per_second = (int)(physics_fps * simspeed)
	Engine.max_physics_steps_per_frame = max(2, Engine.physics_ticks_per_second / min_render_fps)
	$UI/LabelPhys.text = "max phys per render: %d\nphys rate: %d fps\nsim speed: %0.3f" % \
		[Engine.max_physics_steps_per_frame, Engine.physics_ticks_per_second, simspeed]

func set_scene(bridge_def):
	$MultiMeshNodes.multimesh.instance_count = bridge_def.nodes.size() + bridge_def.beams.size() * 2
	$MultiMeshBeams.multimesh.instance_count = bridge_def.beams.size() * 2
	bridge = Bridge.new(bridge_def)

func _unhandled_key_input(event):
	if not event.pressed:
		return
	if event.keycode == KEY_ESCAPE:
		get_tree().quit()
	if event.keycode == KEY_F:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1600, 900))
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if event.keycode == KEY_DOWN:
		if bridge:
			bridge.event_delete_beam()
	if event.keycode == KEY_UP:
		if bridge:
			bridge.event_add_mass()
	if event.keycode == KEY_RIGHT:
		if simspeed * 2 <= 8:
			simspeed *= 2
			update_simspeed()
	if event.keycode == KEY_LEFT:
		if simspeed / 2 >= 1.0 / 16:
			simspeed /= 2
			update_simspeed()
	if event.keycode == KEY_0:
		set_scene(BridgeDefinition.new())
	if event.keycode == KEY_1:
		set_scene(Playground.bridge_def)
	if event.keycode == KEY_2:
		set_scene(AngeTruss1.bridge_def)
	if event.keycode == KEY_3:
		set_scene(AngeTruss2.bridge_def)
	if event.keycode == KEY_4:
		set_scene(AngeTruss3.bridge_def)
	if event.keycode == KEY_5:
		set_scene(AngeTruss4.bridge_def)
	if event.keycode == KEY_6:
		set_scene(AngeTruss5.bridge_def)
