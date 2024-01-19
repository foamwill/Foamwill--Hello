extends Spatial

onready var horizontal = $"."
onready var vertical = $h
var cam_stats = {
	hrot = 0,
	vrot = 0,
	# i'm assuming that this function is returning result in multiple of 3
	max_angle = rad2deg(3),
	min_angle = rad2deg(-3),
	# mouse_sens range 0.1 to 1
	mouse_sens = 0.5,
	# mouse_speed default constant
	mouse_speed = 0.4
}

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$h/Camera.add_exception(get_parent())

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cam_stats.hrot += -event.relative.x * cam_stats.mouse_sens;
		cam_stats.vrot += event.relative.y * cam_stats.mouse_sens;

func _physics_process(_delta):
	cam_stats.vrot = clamp(cam_stats.vrot, cam_stats.min_angle, cam_stats.max_angle);
	horizontal.rotation_degrees.y = lerp(horizontal.rotation_degrees.y, cam_stats.hrot * cam_stats.mouse_sens, cam_stats.mouse_speed);
	horizontal.rotation_degrees.x = lerp(horizontal.rotation_degrees.x, cam_stats.vrot * cam_stats.mouse_sens, cam_stats.mouse_speed);
#	vertical.rotation_degrees.x = lerp(vertical.rotation_degrees.x, cam_stats.vrot * cam_stats.mouse_sens, cam_stats.mouse_speed);
	
	if Input.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = !Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
