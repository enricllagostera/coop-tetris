extends Node

const FTILE = 16
const HTILE = 8

enum Dir {R, D, L, U, N}
enum Rot { R0, RR, R2, RL }
enum Piece { I = 0, J = 1, L = 2, O = 3, S = 4, T = 5, Z = 6}

const Colors = { 
	Piece.I: "#007899",  
	Piece.J: "#234975",  
	Piece.L: "#7f0622",  
	Piece.O: "#ff8426",  
	Piece.S: "#10d275",  
	Piece.T: "#430067",  
	Piece.Z: "#ff2674",  
}

enum Player { LEFT = 0, RIGHT = 1 }

const SHIFTS = {
	Dir.D: Vector2(0,1),
	Dir.R: Vector2(1,0),
	Dir.L: Vector2(-1,0),
	Dir.U: Vector2(0, -1),
	Dir.N: Vector2(0,0)
}

const TETROS_REL = {
	Piece.I: {
		Rot.R0: [ Vector2(0,0), Vector2(-1,0), Vector2(1, 0), Vector2(2,0)],
		Rot.RR: [ Vector2(0,0), Vector2(0,-1), Vector2(0, 1), Vector2(0,2)],
		Rot.R2: [ Vector2(-2,0), Vector2(-1,0), Vector2(0, 0), Vector2(1,0)],
		Rot.RL: [ Vector2(0,0), Vector2(0,-2), Vector2(0, -1), Vector2(0,1)]
	},
	Piece.J: {
		Rot.R0: [ Vector2(0,0), Vector2(-1,0), Vector2(-1, -1), Vector2(1,0)],
		Rot.RR: [ Vector2(0,0), Vector2(0,-1), Vector2(1, -1), Vector2(0,1)],
		Rot.R2: [ Vector2(-1,0), Vector2(0,0), Vector2(1, 0), Vector2(1,1)],
		Rot.RL: [ Vector2(0,0), Vector2(-1,1), Vector2(0, 1), Vector2(0,-1)]
	},
	Piece.L: {
		Rot.R0: [ Vector2(0,0), Vector2(-1,0), Vector2(1, 0), Vector2(1,-1)],
		Rot.RR: [ Vector2(0,0), Vector2(0,-1), Vector2(0, 1), Vector2(1,1)],
		Rot.R2: [ Vector2(-1,1), Vector2(-1,0), Vector2(0, 0), Vector2(1,0)],
		Rot.RL: [ Vector2(-1,-1), Vector2(0,-1), Vector2(0, 0), Vector2(0,1)]
	},
	Piece.O: {
		Rot.R0: [ Vector2(0,0), Vector2(1,0), Vector2(1, 1), Vector2(0,1)],
		Rot.RR: [ Vector2(0,0), Vector2(1,0), Vector2(1, 1), Vector2(0,1)],
		Rot.R2: [ Vector2(0,0), Vector2(1,0), Vector2(1, 1), Vector2(0,1)],
		Rot.RL: [ Vector2(0,0), Vector2(1,0), Vector2(1, 1), Vector2(0,1)]
	},
	Piece.S: {
		Rot.R0: [ Vector2(-1,0), Vector2(0,0), Vector2(0, -1), Vector2(1,-1)],
		Rot.RR: [ Vector2(0,-1), Vector2(0,0), Vector2(1, 0), Vector2(1,1)],
		Rot.R2: [ Vector2(-1,1), Vector2(0,1), Vector2(0, 0), Vector2(1,0)],
		Rot.RL: [ Vector2(0,0), Vector2(-1,0), Vector2(-1, -1), Vector2(0,1)],
		
	},
	Piece.T: {
		Rot.R0: [ Vector2(-1,0), Vector2(0,0), Vector2(1, 0), Vector2(0,-1)],
		Rot.RR: [ Vector2(0,0), Vector2(0,-1), Vector2(0, 1), Vector2(1,0)],
		Rot.R2: [ Vector2(-1,0), Vector2(0,0), Vector2(1, 0), Vector2(0,1)],
		Rot.RL: [ Vector2(-1,0), Vector2(0,0), Vector2(0, 1), Vector2(0,-1)]
	},
	Piece.Z: {
		Rot.R0: [ Vector2(-1,-1), Vector2(0,-1), Vector2(0, 0), Vector2(1,0)],
		Rot.RR: [ Vector2(0,0), Vector2(1,-1), Vector2(1, 0), Vector2(0,1)],
		Rot.R2: [ Vector2(-1,0), Vector2(0,0), Vector2(0, 1), Vector2(1,1)],
		Rot.RL: [ Vector2(-1,1), Vector2(-1,0), Vector2(0, 0), Vector2(0,-1)]
	}
}

const ROT_CLOCKWISE = { Rot.R0 : Rot.RR, Rot.RR: Rot.R2, Rot.R2: Rot.RL, Rot.RL: Rot.R0 }
const ROT_COUNTERCLOCKWISE = { Rot.R0 : Rot.RL, Rot.RL: Rot.R2, Rot.R2: Rot.RR, Rot.RR: Rot.R0 }

func calc_tetro_abs_coords(origin, piece, rot):
	var res = []
	for b in TETROS_REL[piece].get(rot):
		res.append(origin + b)
	return res
	pass

func calc_tetro_rel_coords(piece, rot):
	var res = []
	for b in TETROS_REL[piece].get(rot):
		res.append(b)
	return res
	pass
