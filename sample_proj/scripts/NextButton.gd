extends Button


func _ready():
	connect("pressed", self, "load_level")

func load_level():
	if get_name() == "NextButton":
		get_parent().visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
