extends Label

func _on_bridge_simspeed_changed():
	text = "max phys per render: %d\nphys rate: %d fps\nsim speed: %0.3f" % \
		[Engine.max_physics_steps_per_frame, Engine.physics_ticks_per_second, get_node("/root/Main/Bridge").simspeed]

