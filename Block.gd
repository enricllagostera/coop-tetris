extends Node2D

var coord
var down_direction
export var type = "I"

signal block_locked

func _ready():
	pass # Replace with function body.

func move():
	position += down_direction * 16
	print(position)
	if position.x > 20 * 16:
		emit_signal("block_locked")
