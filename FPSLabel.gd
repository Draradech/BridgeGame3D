extends Label

func _process(_delta):
	set_text("%d fps" % Engine.get_frames_per_second())
