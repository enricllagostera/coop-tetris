extends Node

const FTILE = 16
const HTILE = 8

enum Dir {R, D, L, U, N}
enum Rot { R0, RR, R2, RL }
enum Piece { I, O, J, L, T, S, Z}

const SHIFTS = {
	Dir.D: Vector2(0,1),
	Dir.R: Vector2(1,0),
	Dir.L: Vector2(-1,0),
	Dir.U: Vector2(0, -1),
	Dir.N: Vector2(0,0)
}

const TETROS = {
	Piece.J: {
		Rot.R0: [ Vector2(0,0), Vector2(-1,0), Vector2(-1, -1), Vector2(1,0)],
		Rot.RR: [ Vector2(0,0), Vector2(0,-1), Vector2(1, -1), Vector2(0,1)]
	}
}

const ROT_CLOCKWISE = { Rot.R0 : Rot.RR, Rot.RR: Rot.R2, Rot.R2: Rot.RL, Rot.RL: Rot.R0 }

func calc_tetro_abs_coords(origin, piece, rot):
	var res = []
	for b in TETROS[piece][rot]:
		res.append(origin + b)
	return res
	pass

func calc_tetro_rel_coords(piece, rot):
	var res = []
	for b in TETROS[piece][rot]:
		res.append(b)
	return res
	pass
