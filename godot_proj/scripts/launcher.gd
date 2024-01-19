extends Spatial

export (PackedScene) var ball
var shoot_timer:Timer
onready var csgCylinder = $CSGCylinder
var ball_mass = 3

func _ready():
	shoot_timer = Timer.new()
	add_child(shoot_timer)
	shoot_timer.wait_time = 3
	shoot_timer.connect("timeout", self, "throw_projectile")
	shoot_timer.start()

func _process(_delta):
	var distance = global_transform.origin.distance_to(get_node("../myplayer").transform.origin)
	# if player is in this range then launcher will shoot its balls
	if distance <= 100:
		self.look_at(get_node("../myplayer/aimPart").global_transform.origin, Vector3.UP)
		self.rotation.x = 0
		self.rotation.z = 0
		csgCylinder.look_at(get_node("../myplayer/aimPart").global_transform.origin, get_node("../myplayer/aimPart").global_transform.origin)
		csgCylinder.rotation_degrees.y = clamp(csgCylinder.rotation_degrees.y, deg2rad(0), deg2rad(5))
		#print(csgCylinder.rotation_degrees.y)

func throw_projectile():
	# finding the distance between self and other object (i.e launcher and player)
	var distance = global_transform.origin.distance_to(get_node("../myplayer").transform.origin)
	# if player is in this range then launcher will shoot its balls
	if distance <= 100:
		var new_ball = ball.instance()
		# this instance is added as a child of current node
		add_child(new_ball)
		new_ball.set_contact_monitor(true)
		new_ball.set_max_contacts_reported(5)
		new_ball.connect("body_entered", self, "ball_collision")

		# creating timer object
		var timer = Timer.new()
		# adding timer as child of new_ball, so that it could have its life-span
		new_ball.add_child(timer)
		# connecting the condition i.e "timeout" of timer to the new_ball
		# which will execute the queue_free function, when the timeout has happened
		timer.connect("timeout", new_ball, "queue_free")
		# setting the timeout duration or lifespan
		timer.set_wait_time(4)
		timer.start()

		# now we need to look at the player every time we attack
		# it take object position and axis of rotation
		look_at(get_node("../myplayer/aimPart").global_transform.origin, Vector3.UP)

		# adding linear velocity to our rigidBody (i.e ball) in some direction
		# print("distance between player: " + str(distance))
		new_ball.linear_velocity = transform.basis.xform(Vector3.FORWARD)*(60) * ball_mass

func ball_collision(body):
	if (body.name == "myplayer"):
		get_node("../myplayer").transform.origin = get_node("../start").transform.origin + Vector3.UP

