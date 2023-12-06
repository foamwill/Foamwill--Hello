extends KinematicBody

export var speed = 3
export var Decel = 50
export var Accel = 50
var jump = 30
const GRAVITY = 100
var direction = Vector3()
var running = false
onready var mesh = $ybot/Armature
onready var animationPlayer = $ybot/AnimationPlayer

func _physics_process(delta):
	var input_vector = Vector3.ZERO
	var h_rot = $Target.global_transform.basis.get_euler().y
	
	input_vector = Vector3(Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"), 
	0, 
	Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")).rotated(Vector3.UP, h_rot)
	input_vector = input_vector.normalized()
	
	if input_vector != Vector3.ZERO:
		if Input.is_action_pressed("sprint") || running:
			speed = 10
			animationPlayer.play("Running")
		else:
			speed = 3
			animationPlayer.play("Walking")
		direction = direction.move_toward(input_vector * speed, Accel * delta)
		
		# Calculate the rotation angle
		var target_rotation = atan2(direction.x, direction.z)
		
		mesh.rotation.y = lerp_angle($Target.rotation.y, target_rotation, delta * Accel)
		print(direction.x, " " , direction.z)
#		print(mesh.rotation_degrees.y)
	else:
		animationPlayer.play("Idle")
		direction = direction.move_toward(Vector3.ZERO, Decel * delta)
#	direction = lerp(direction, input_vector * speed, delta * Accel)
	
	direction = move_and_slide(direction, Vector3.UP)
	
	if !is_on_floor():
		direction.y -= GRAVITY * delta
	else:
		direction.y = 0
		if is_on_floor() and Input.is_action_just_pressed("ui_select"):
			direction.y += jump

func _on_CheckBox_toggled(_button_pressed):
	running = !running
