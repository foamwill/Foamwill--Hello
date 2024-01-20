extends Button


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	connect("pressed",self,"load_level")

func load_level():
	if get_name() == "RestartButton":
		get_tree().change_scene("res://scenes/UserInterface.tscn")
	else:
		get_tree().change_scene("res://scenes/level1.tscn")
