extends Node

func _ready():
	var mybike:Bike = Bike.new();
	mybike.display_name();
	mybike.display_color();
	mybike.display_speed();
	
	var mybike2:Bike = Bike.new("Pluto","Metalic midnightblue",10);
	mybike2.display_name();
	mybike2.display_color();
	mybike2.display_speed();
