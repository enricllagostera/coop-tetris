extends Node2D

var rel_blocks = [Vector2(0,0), Vector2(-1,-1), Vector2(-1,0), Vector2(1,0)]
var visual_offset = Vector2()
var offset = Vector2()
export var coord = Vector2()
var rot = Game.Rot.R0
var piece = Game.Piece.J
var lock_countdown = false
var locked = false

var visual_offset_table = {
	Game.Piece.J: Vector2(-1.5, -1.5)
}


func _ready():
	position = coord * Game.FTILE
	$Visual.offset = visual_offset_table[Game.Piece.J] * Game.FTILE
	pass # Replace with function body.


func rotate_clockwise():
	var target_rot = Game.ROT_CLOCKWISE[rot]
	print(target_rot)
	rot = target_rot
	render_rotation()

func render_rotation():
	if rot == Game.Rot.R0:
		$Visual.rotation = deg2rad(0)
	if rot == Game.Rot.RR:
		$Visual.rotation = deg2rad(90)
	if rot == Game.Rot.R2:
		$Visual.rotation = deg2rad(180)
	if rot == Game.Rot.RL:
		$Visual.rotation = deg2rad(270)


func lockdown_cancelled():
	print("tetro lock cancelled")
	lock_countdown = false
	locked = false
	$LockDownTimer.stop()
	pass


func lockdown_completed():
	print("tetro lock completed")
	lock_countdown = false
	locked = true
	$LockDownTimer.stop()
	pass


func lockdown_started():
	print("tetro locking")
	$LockDownTimer.start()
	lock_countdown = true
	pass


func _on_LockDownTimer_timeout():
	print("lock down finished")
	lockdown_completed()
	pass
