#extends Node

class_name Bike

var speed:float
var color:String
var name:String

# creating a default constructor as follows with default values
func _init(new_name:="A New Bike", new_color:="blue", new_speed:=0.0):
	speed = new_speed
	color = new_color
	name = new_name

# function for displaying variables
func display_name():
	print("Name: "+name)
func display_color():
	print("Color: "+color)
func display_speed():
	speed += 1
	print("Speed: "+str(speed))
