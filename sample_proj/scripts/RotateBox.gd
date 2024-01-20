extends Node

func _ready():
	pass

func _process(delta):
	$".".rotation_degrees.y += 90 * delta
