extends Node
var time = 0
var counter = 55
onready var timer_ui:Label = get_node("../timerUI");
onready var user_message_ui:Label = get_node("../userMessageUI");

func _ready():
	timer_ui.set_text("00m:00s");
	user_message_ui.set_text("");

func _process(delta):
	time += delta
	if(time > 1):
		counter += 1;
		var seconds = counter % 60;
		var minutes = counter / 60;
		time = 0
#		print("%dm:%ds"%[minutes, seconds]);
		timer_ui.set_text("%dm:%ds"%[minutes, seconds]);
		if (counter > 104):
			user_message_ui.set_text("Time ALMOST UP");
		if counter > 120:
#			print("Time's up");
			get_tree().change_scene("res://scenes/scene1.tscn");
