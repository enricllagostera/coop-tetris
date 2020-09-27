extends Object

class_name PieceBag

var blocks = []


func _init():
	reset()
	pass


func reset(previous_piece = -1):
	blocks = [ Game.Piece.I, Game.Piece.J, Game.Piece.O, Game.Piece.S, Game.Piece.Z, Game.Piece.T, Game.Piece.L]
	blocks.shuffle()	
	while blocks[0] == previous_piece:
		blocks.shuffle()


func pop_next(previous_piece = -1):
	var next_piece = -1
	if blocks.size() == 0:
		reset(previous_piece)
	next_piece = blocks.pop_front()
	return next_piece


func view_next(previous_piece = -1):
	if blocks.size() > 0:
		return blocks[0]
	reset(previous_piece)
	return blocks[0]
