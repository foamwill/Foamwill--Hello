extends KinematicBody

class_name Player

onready var animationPlayer = $playerMesh/AnimationPlayer
onready var mesh = $playerMesh/Armature

# declearing player stats
var stats = {
	jumpstrength = 100,
	movespeed = 5,
	velocity = Vector3.ZERO,
	direction = Vector3.ZERO,
	gravity = 9.8,
	accel = 7,
	fov_accel = 10,
	decel = 0.5
}

var cam_rot = 0

func _ready():
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
