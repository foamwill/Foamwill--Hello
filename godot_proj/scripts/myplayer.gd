extends KinematicBody

class_name Player

onready var animationPlayer = $ybot_new/AnimationPlayer
onready var mesh = $ybot_new/Armature
onready var uiMessage:Label = get_node("../uiMessage")
onready var timer:Timer
var inventory:WeaponInventory
var reload_timer:Timer
var can_shoot = true

# we need camera access to work with raycast
onready var camera:Camera = get_node("Target/h/Camera")
# creating a raycast to detect what is in front of our player
var ray:RayCast
# ammunation
var gun_ammo = 6
var magzine = 36
onready var sound_fx:AudioStreamPlayer = get_node("sound_fx")

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
	score = 0
}

var cam_rot = 0

func _ready():
	#Timer for weapons
	reload_timer = Timer.new()
	add_child(reload_timer)
	reload_timer.connect("timeout", self, "reload_timer_timeout")
	inventory = WeaponInventory.new()
	
	# creating object of raycast and enabling it
	ray = RayCast.new()
	ray.enabled = true
	# here adding ray as a child of camera
	camera.add_child(ray)
	# setting the length of ray with vector
	ray.cast_to = Vector3(0,0,-100)
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3
	timer.connect("timeout", self, "timedout")
	uiMessage.set_text("")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	gun_ammo = inventory.get_curr_weapon_max_ammo()
	magzine = inventory.get_curr_weapon_ammos()

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
	# checking if gun is fired
	if (Input.is_action_pressed("fire") && gun_ammo > 0):
		var condition1 = (inventory.weapon_index == Weapon.TYPE_GUN)
		var condition2 = (inventory.weapon_index == Weapon.TYPE_AUTO_GUN)
		var condition3 = inventory.has_ammo_for_current()
		var condition4 = can_shoot
		if((condition1 || condition2) && condition3 && condition4):
			inventory.decrease_curr_ammo()
			can_shoot = false
			reload_timer.wait_time = inventory.get_curr_reload_time()
			reload_timer.start()
			sound_fx.play()
			# here checking the collision of raycast
			if (ray.is_colliding()):
				# when raycast is colliding with something then we
				# here we are trying to get which object we are colliding with
				var obj = ray.get_collider()
				var sphere = CSGSphere.new()
				print("the object: "+obj.get_name()+" is in front of the player\nAmmo: "+str(gun_ammo)+" left")
				if gun_ammo == 0:
					uiMessage.set_text(obj.get_name()+" 'R' to reload ammo: "+str(gun_ammo))
				else:
					# decrease the gun_ammo
					sound_fx.stop()
					gun_ammo -= 1
					uiMessage.set_text(obj.get_name()+", Bullets: "+str(gun_ammo))
				timer.start()
				if obj.is_in_group("target"):
					obj.got_hit()
	if Input.is_key_pressed(KEY_R) && magzine != 0:
		print("Magzine: "+str(magzine)+", Ammo: "+str(gun_ammo))
		if gun_ammo == 0:
			magzine -= 6
			gun_ammo = inventory.get_curr_weapon_ammos()
		if gun_ammo < inventory.get_curr_weapon_ammos():
			magzine -= (inventory.get_curr_weapon_ammos()-gun_ammo)
			gun_ammo = inventory.get_curr_weapon_ammos()
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("collect"):
			#print("Collision with: "+collision.collider.name)
			timer.start()
			stats.score += 1
			if stats.score == 1:
				uiMessage.set_text("you have collected "+str(stats.score)+" ball")
			else:
				uiMessage.set_text("you have collected "+str(stats.score)+" balls")
			#print("Score: "+str(stats.score))
			collision.collider.queue_free()
		elif collision.collider.name == "end" and stats.score == 4:
			uiMessage.set_text("Congratulations!! you have won the game")
			timer.wait_time = 5
			timer.start()
			print("congratulations")
		elif collision.collider.name == "end" and stats.score != 4:
			uiMessage.set_text("Collect all 4 balls first")
			timer.start()
		elif (collision.collider.is_in_group("ammo_gun")):
			if magzine >= 252:
				magzine = 252
			else:
				magzine += 36
			collision.collider.queue_free()
	if Input.is_action_just_pressed("change_weapon"):
		inventory.change_weapon()
		var message = inventory.get_curr_weapon_name()
		message += "("+str(inventory.get_curr_weapon_ammos())+")"
		reload_timer.wait_time = inventory.get_curr_reload_time()
		uiMessage.set_text(message)

func timedout():
	uiMessage.set_text("")
	timer.stop()

func reload_timer_timeout():
	can_shoot = true
	reload_timer.stop()
