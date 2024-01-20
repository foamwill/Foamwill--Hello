extends KinematicBody

class_name Player

onready var animationPlayer = $ybot_new/AnimationPlayer
onready var mesh = $ybot_new/Armature
onready var bg_sound:AudioStreamPlayer = get_node("../bgsound")
var sound_is_on:bool = true
onready var user_message_ui:Label = get_node("../userMessageUI");
onready var timer:Timer = get_node("../Timer");
onready var scoreUI:Label = get_node("../scoreUI");
var petrol_can1:TextureRect
var petrol_can2:TextureRect
var petrol_can3:TextureRect
onready var beep_sound:AudioStreamPlayer = get_node("../AudioStreamPlayer")
onready var viewport_container:ViewportContainer = get_node("../ViewportContainer")

# declearing player stats
var stats = {
	jumpstrength = 100,
	movespeed = 5,
	velocity = Vector3.ZERO,
	direction = Vector3.ZERO,
	gravity = 9.8,
	accel = 7,
	fov_accel = 10,
	decel = 0.5,
	score = 0,
	nb_petrol_can = 0
}

var cam_rot = 0

func _ready():
	stats.score = 0
	stats.nb_petrol_can = 0
	scoreUI.set_text("Score: "+str(stats.score));
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# taking camera rotation into account
	# taking directional input, then rotating and normalizing in the direction of movement
	stats.direction = Vector3(Input.get_action_strength("player_left") - Input.get_action_strength("player_right"), 
	0, 
	Input.get_action_strength("player_forwards") - Input.get_action_strength("player_backwards")).rotated(Vector3.UP, cam_rot).normalized();
	if stats.direction != Vector3.ZERO:#Input.is_action_pressed("player_forwards") || Input.is_action_pressed("player_backwards") || Input.is_action_pressed("player_left") || Input.is_action_pressed("player_right"):
		cam_rot = $Target/h.global_transform.basis.get_euler().y
		# if player is sprinting
		if Input.is_action_pressed("player_sprint"):
			# playing animation run
			animationPlayer.play("Fast Run")
			stats.movespeed = 25
			$Target/h/Camera.fov = lerp($Target/h/Camera.fov, 90, delta * stats.fov_accel);
		else:
			# playing animation walk
			animationPlayer.play("Walking")
			stats.movespeed = 5;
			$Target/h/Camera.fov = lerp($Target/h/Camera.fov, 70, delta);
	else:
		# changing camera fov to default
		$Target/h/Camera.fov = lerp($Target/h/Camera.fov, 70, delta);
		# idle animation
		animationPlayer.play("Idle")
		# if action not pressed then we want to stop moving
		stats.movespeed = 0
	# checking if player is not floor, then apply gravity
	if !is_on_floor():
		stats.velocity.y -= stats.gravity * stats.decel;
	# else gravity won't be applied
	else:
		stats.velocity.y = 0;
		animationPlayer.playback_default_blend_time = 0.2;
		if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
			# jump animation
			animationPlayer.playback_default_blend_time = 0;
			animationPlayer.play("Jump")
			stats.velocity.y += stats.jumpstrength;
	
	# we are smoothly moving the player in the diection of movement using 'lerp'
	stats.velocity = lerp(stats.velocity, stats.direction * stats.movespeed, stats.accel * delta);
	
	# rotate player mesh towards camera facing
	mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(stats.direction.x, stats.direction.z), delta * stats.movespeed)
	
	# actually moving player using move_and_slide()
	stats.velocity = move_and_slide(stats.velocity, Vector3.UP, true);
	
	# below code for testing collision
	for index in get_slide_count():
		var collision = get_slide_collision(index);
		if (collision.collider.is_in_group("pick_me") || collision.collider.is_in_group("petrol_can") || collision.collider.is_in_group("plane")):
#			print("collision with "+collision.collider.name);
			if !collision.collider.is_in_group("plane"):
				collision.collider.queue_free()
			timer.start()
			if collision.collider.is_in_group("pick_me"):
				stats.score += 1;
				beep_sound.play()
				scoreUI.set_text("Score: "+str(stats.score));
				# updating score count
				if (stats.score == 1):
					user_message_ui.set_text(str(stats.score) + " Box Collected")
				else:
					user_message_ui.set_text(str(stats.score) + " Boxes Collected")
			elif collision.collider.is_in_group("plane"):
				if (stats.nb_petrol_can < 3):
					user_message_ui.set_text("Sorry you need 3 cans to fly the Plane")
				else:
#					user_message_ui.set_text("Congratulations, you can fly the Plane");
					get_tree().change_scene("res://scenes/end_scene.tscn")
			else:
				if collision.collider.is_in_group("petrol_can"):
					stats.nb_petrol_can += 1
					match stats.nb_petrol_can:
						1: petrol_can1.visible = true
						2: petrol_can2.visible = true
						3: petrol_can3.visible = true
					# updating petrol-can count
					if (stats.nb_petrol_can == 1):
						user_message_ui.set_text(str(stats.nb_petrol_can) + " Can Collected")
					else:
						user_message_ui.set_text(str(stats.nb_petrol_can) + " Cans Collected")
				
			if stats.score >= 3:
				get_node("../maze").queue_free()
				get_node("../Control").visible = true
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				var lvl2 = load("res://scenes/level2.tscn").instance();
				lvl2.set_name("level2")
				get_parent().add_child(lvl2);
				init_ui_level2()
				get_node("../timer").counter = 0;
				stats.score = 0

func calculate_range(initial_velocity, launch_angle):
	# Convert launch angle to radians
	var launch_angle_rad = rad2deg(launch_angle)
	
	# Acceleration due to gravity on Earth
	stats.gravity = 9.8  # m/s²
	
	# Calculate range using the formula
	var range_value = (pow(initial_velocity, 2) * sin(2 * launch_angle_rad)) / stats.gravity
	
	return range_value


func _on_Timer_timeout():
	user_message_ui.set_text("")
	timer.stop()
	beep_sound.stop()

func init_ui_level2():
	petrol_can1 = get_node("../level2/petrol_can1_ui");
	petrol_can2 = get_node("../level2/petrol_can2_ui");
	petrol_can3 = get_node("../level2/petrol_can3_ui");
	petrol_can1.visible = false
	petrol_can2.visible = false
	petrol_can3.visible = false

func _input(_event):
	if Input.is_key_pressed(KEY_P):
		if (sound_is_on):
			bg_sound.stream_paused = true
		else:
			bg_sound.stream_paused = false
		sound_is_on = !sound_is_on
	if Input.is_key_pressed(KEY_M):
		viewport_container.visible = !viewport_container.visible
