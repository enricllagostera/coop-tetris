extends Node2D

onready var tick = $TickTimer
export var tick_interval = 1.0

var state = Dictionary()
var size = Vector2(10,45)
var debug_block_prefab
var debug_blocks = Dictionary()
var pieces = []
var tetro_prefab

func _ready():
	pieces = []
	tetro_prefab = load("Tetro.tscn")
	debug_block_prefab = load("DebugBlock.tscn")
#	tick.wait_time = tick_interval
	for row in range(0,45):
		for col in range(0,10):
			state[Vector2(col, row)] = 0
			debug_blocks[Vector2(col, row)] = debug_block_prefab.instance()
			$DebugGrid.add_child(debug_blocks[Vector2(col, row)])
			debug_blocks[Vector2(col, row)].position = Vector2(col, row) * 16
			debug_blocks[Vector2(col, row)].get_node("Solid").visible = false
	spawn(Vector2(5,1), Game.SHIFTS[Game.Dir.D], Game.Piece.J)
	debug_render()
	pass

func is_out_of_bounds(blocks_to_check):
	for c in blocks_to_check:
		if c.x < 0 or c.x >= size.x:
			return true
		if c.y < 0 or c.y >= size.y:
			return true
	return false


func is_colliding(self_blocks, base_coord, blocks_to_check):
	var tetro = []
	for b in self_blocks:
		tetro.append(b+base_coord)
	for c in blocks_to_check: 
		if state[c] == 1 and not tetro.has(c):
			return true
	return false
	pass


func shift_tetro(tetro, dir):
	var target_blocks = [] 
	for b in tetro.rel_blocks:
		target_blocks.append(tetro.coord+b+Game.SHIFTS[dir])
	if is_out_of_bounds(target_blocks):
		return
	if is_colliding(tetro.rel_blocks, tetro.coord, target_blocks):
		return

	for b in tetro.rel_blocks:
		state[tetro.coord+b] = 0
	tetro.coord += Game.SHIFTS[dir]
	for b in tetro.rel_blocks:
		state[tetro.coord+b] = 1
	debug_render()
	pass

func spawn(origin, down_direction, piece):
	var new_tetro = tetro_prefab.instance()
	add_child(new_tetro)
	new_tetro.coord = origin
	new_tetro.piece = piece
	new_tetro.rot = Game.Rot.R0
	new_tetro.rel_blocks = Game.calc_tetro_rel_coords(new_tetro.piece, new_tetro.rot)
	for b in new_tetro.rel_blocks:
		state[origin+b] = 1
	pieces.clear()
	pieces.append(new_tetro)
	debug_render()
	pass

func debug_render():
	for db in debug_blocks.keys():
		debug_blocks[db].get_node("Solid").visible = (state[db] == 1)
	pass

func _process(delta):
	if Input.is_action_just_released("ui_select"):
		spawn(Vector2(5,1), Game.SHIFTS[Game.Dir.D], Game.Piece.J)
	if Input.is_action_just_released("ui_down"):
		shift_tetro(pieces[0], Game.Dir.D)
	if Input.is_action_just_released("ui_left"):
		shift_tetro(pieces[0], Game.Dir.L)
	if Input.is_action_just_released("ui_right"):
		shift_tetro(pieces[0], Game.Dir.R)
	pass


func _on_TickTimer_timeout():
#	print("tick")
	pass # Replace with function body.
