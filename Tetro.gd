extends Node2D


var rel_blocks = [Vector2(0,0), Vector2(-1,-1), Vector2(-1,0), Vector2(1,0)]
onready var visual_blocks = [$Block0, $Block1, $Block2, $Block3]
var offset = Vector2()
export var coord = Vector2()
var rot = Game.Rot.R0
var piece = Game.Piece.J
var locking = false
var locked = false
var player = -1


func rotate_clockwise():
	var target_rot = Game.ROT_CLOCKWISE[rot]
	rot = target_rot


func render():
	var blocks = get_abs_blocks()
	for i in range(0, blocks.size()):
		visual_blocks[i].position = blocks[i] * Game.FTILE
		visual_blocks[i].modulate = Color(Game.Colors[piece])
	pass


func get_abs_blocks():
	var abs_blocks = []
	for b in rel_blocks:
		abs_blocks.append(b+coord)
	return abs_blocks


func lockdown_cancelled():
	print("tetro lock cancelled")
	locking = false
	locked = false
	for vb in visual_blocks:
		vb.modulate = Color.white
	$LockDownTimer.stop()
	pass


func lockdown_completed():
	print("tetro lock completed")
	locking = false
	locked = true
	$LockDownTimer.stop()
#	var pre = OS.get_ticks_msec()
	get_parent().get_parent().block_locked(player)
#	print("ms: ", OS.get_ticks_msec() - pre)
	pass


func lockdown_started():
	print("tetro locking")
	locking = true
	for vb in visual_blocks:
		vb.modulate = Color.red
	$LockDownTimer.start()
	pass


func _on_LockDownTimer_timeout():
	print("lock down finished")
	lockdown_completed()
	pass
