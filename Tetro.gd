extends Node2D

var rel_blocks = [Vector2(0,0), Vector2(-1,-1), Vector2(-1,0), Vector2(1,0)]
var visual_offset = Vector2()
var offset = Vector2()
export var coord = Vector2()
var rot = Game.Rot.R0
var piece = Game.Piece.J

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

func shift(dir):
	get_parent().shift_tetro(self, dir)
#	var target_coord = coord
#	if dir == Dir.D:
#		target_coord += Vector2(0,1)
##	if unobstructed in the target coord, then apply position
#	coord = target_coord
#	position = coord * FTILE

func _process(delta):
	
	pass
