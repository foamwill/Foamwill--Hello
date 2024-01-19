class_name Weapon

const TYPE_GUN:int = 0
const TYPE_AUTO_GUN:int = 1
const TYPE_GRENADE:int = 2

var reload_time:int
var name:String
var ammos:int
var max_ammo:int
# below is a class constructor
func _init(wapon_type:int = TYPE_GUN):
	match wapon_type:
		# simple gun
		TYPE_GUN:
			name = "GUN"
			reload_time = 2
			ammos = 10
			max_ammo = 20
		# automatic gun
		TYPE_AUTO_GUN:
			name = "AUTOMATIC GUN"
			reload_time = 1
			ammos = 20
			max_ammo = 40
		# grenade
		TYPE_GRENADE:
			name = "GRENADE"
			reload_time = 3
			ammos = 10
			max_ammo = 5
	print("Created Weapon Type: "+str(wapon_type))

func increase_ammo(ammo_increase:int = 1):
	if (ammos+ammo_increase <= max_ammo):
		ammos += ammo_increase
func decrease_ammo(ammo_decrease:int = 1):
	ammos -= ammo_decrease
	if (ammos < 0):
		ammos = 0
