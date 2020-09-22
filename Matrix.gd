extends Node2D


export var tick_interval = 0.5
var state = Dictionary()
var size = Vector2(10,45)
var tetro_prefab
var pieces = []
var current_player = Game.Player.RIGHT
var spawn_points = [Vector2(5,1), Vector2(5,41)]
var debug_block_prefab
var debug_blocks = Dictionary()


signal piece_lock_down_started
signal piece_lock_down_cancelled


func debug_render():
	for db in debug_blocks.keys():
		debug_blocks[db].get_node("Solid").visible = (state[db] == 1)
	pass


func is_colliding(self_blocks, base_coord, blocks_to_check, check_self = true):
	var tetro = []
	for b in self_blocks:
		tetro.append(b+base_coord)
	for c in blocks_to_check: 
		if check_self:
			if state[c] > 0 and not tetro.has(c):
				return true
		else:
			if state[c] > 0:
				return true
	return false
	pass


func is_out_of_bounds(blocks_to_check):
	for c in blocks_to_check:
		if c.x < 0 or c.x >= size.x:
			return true
		if c.y < 0 or c.y >= size.y:
			return true
	return false


func rotate_tetro(tetro, is_clockwise):
	var rot_table = Game.ROT_CLOCKWISE if is_clockwise else Game.ROT_COUNTERCLOCKWISE
	var target_blocks_abs = Game.calc_tetro_abs_coords(tetro.coord, tetro.piece, rot_table[tetro.rot])
	if is_out_of_bounds(target_blocks_abs):
		return
	if is_colliding(tetro.rel_blocks, tetro.coord, target_blocks_abs):
		return
	for b in tetro.rel_blocks:
		state[tetro.coord+b] = 0
	tetro.rel_blocks = Game.calc_tetro_rel_coords(tetro.piece, rot_table[tetro.rot])
	for b in tetro.rel_blocks:
		state[tetro.coord+b] = 1
	tetro.rot = rot_table[tetro.rot]
	debug_render()
	pass


func shift_tetro(tetro, dir, player):
	var target_blocks = [] 
	for b in tetro.rel_blocks:
		target_blocks.append(tetro.coord+b+Game.SHIFTS[dir])
	if is_out_of_bounds(target_blocks):
		return
	if is_colliding(tetro.rel_blocks, tetro.coord, target_blocks):
		if (player == Game.Player.LEFT and dir == Game.Dir.D) or (player == Game.Player.RIGHT and dir == Game.Dir.U):
			tetro.lockdown_started()
		return
	if tetro.lock_countdown:
		tetro.lockdown_cancelled()
	for b in tetro.rel_blocks:
		state[tetro.coord+b] = 0
	tetro.coord += Game.SHIFTS[dir]
	for b in tetro.rel_blocks:
		state[tetro.coord+b] = 1
	debug_render()
	pass


func spawn(origin, player, piece):
	var new_tetro = tetro_prefab.instance()
	new_tetro.coord = origin
	new_tetro.piece = piece
	new_tetro.rot = Game.Rot.R0 if player == Game.Player.LEFT else Game.Rot.R2
	new_tetro.rel_blocks = Game.calc_tetro_rel_coords(new_tetro.piece, new_tetro.rot)
	var target_blocks = Game.calc_tetro_abs_coords(new_tetro.coord, new_tetro.piece, new_tetro.rot)
	if is_colliding(new_tetro.rel_blocks, new_tetro.coord, target_blocks, false):
		print("game over")
		return 
	add_child(new_tetro)
	for b in new_tetro.rel_blocks:
		state[origin+b] = 1
	if pieces[player] is Node:
		pieces[player].queue_free()
	pieces[player] = new_tetro
	debug_render()
	pass


func _ready():
	$TickTimer.wait_time = tick_interval
	pieces = [0,0]
	tetro_prefab = load("Tetro.tscn")
	debug_block_prefab = load("DebugBlock.tscn")
	for row in range(0,45):
		for col in range(0,10):
			state[Vector2(col, row)] = 0
			debug_blocks[Vector2(col, row)] = debug_block_prefab.instance()
			$DebugGrid.add_child(debug_blocks[Vector2(col, row)])
			debug_blocks[Vector2(col, row)].position = Vector2(col, row) * 16
			debug_blocks[Vector2(col, row)].get_node("Solid").visible = false
	spawn(spawn_points[Game.Player.LEFT], Game.Player.LEFT, Game.Piece.J)
	spawn(spawn_points[Game.Player.RIGHT], Game.Player.RIGHT, Game.Piece.J)
	debug_render()
	pass


func _process(delta):
	if Input.is_action_just_released("ui_select"):
		pieces[current_player].lockdown_completed()
		spawn(spawn_points[current_player], current_player, Game.Piece.J)
		return
	if Input.is_action_just_released("ui_left"):
		rotate_tetro(pieces[current_player], true)
	if Input.is_action_just_released("ui_right"):
		shift_tetro(pieces[current_player], Game.Dir.D, current_player)
	if Input.is_action_just_released("ui_down"):
		shift_tetro(pieces[current_player], Game.Dir.L, current_player)
	if Input.is_action_just_released("ui_up"):
		shift_tetro(pieces[current_player], Game.Dir.R, current_player)
	pass


func _on_TickTimer_timeout():
	for i in range(0,2):
		if pieces[i].locked:
			spawn(spawn_points[i], i, Game.Piece.J)
		elif not pieces[i].locked:
			shift_tetro(pieces[i], Game.Dir.D if i == Game.Player.LEFT else Game.Dir.U, i)
	pass

