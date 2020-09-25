extends Node2D


export var tick_interval = 0.5
var state = Dictionary()
var size = Vector2(20,34)
var tetro_prefab
var pieces = []
var current_player = Game.Player.RIGHT
var lines = 0
var spawn_points = [Vector2(10,1), Vector2(10,32)]
var debug_block_prefab
var debug_blocks = Dictionary()
var is_updating = false
var grid_origin


signal piece_lock_down_started
signal piece_lock_down_cancelled


func get_completed_rows():
	var complete_rows = []
	for r in range(0, size.y):
		var is_line_complete = true
		for c in range(0, size.x):
			if state[Vector2(c,r)] == 0:
				is_line_complete = false
				break
		if is_line_complete:
			complete_rows.append(r)
	return complete_rows





func debug_render():
	for db in debug_blocks.keys():
		debug_blocks[db].get_node("Solid").visible = (state[db] == 1)
	pass


func is_colliding_blocks(target_blocks, self_blocks = [], other_piece = null):
	for tb in target_blocks:
		if state[tb] == 1:
			return true
		if other_piece != null and other_piece.get_abs_blocks().has(tb):
			return true
	return false
	pass


func is_colliding_scenario(self_blocks, base_coord, blocks_to_check, check_self = true):
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
	if is_colliding_blocks(target_blocks_abs, tetro.get_abs_blocks()):
		return
	tetro.rel_blocks = Game.calc_tetro_rel_coords(tetro.piece, rot_table[tetro.rot])
	tetro.rot = rot_table[tetro.rot]
	pass


func shift_tetro(tetro, dir, player):
	var target_blocks = tetro.get_abs_blocks() 
	for b in tetro.rel_blocks:
		target_blocks.append(tetro.coord+b+Game.SHIFTS[dir])
	if is_out_of_bounds(target_blocks):
		return
	if is_colliding_blocks(target_blocks, tetro.get_abs_blocks(), pieces[Game.Player.LEFT if player == Game.Player.RIGHT else Game.Player.RIGHT]):
		if not tetro.locking:
			tetro.lockdown_started()
		return
	if tetro.locking:
		tetro.lockdown_cancelled()
#
##	just started touching the bottom of the piece
#		if (player == Game.Player.LEFT and dir == Game.Dir.D) or (player == Game.Player.RIGHT and dir == Game.Dir.U):
#			if not tetro.locking:
#				tetro.lockdown_started()
	move_tetro(tetro, dir)
	debug_render()
	pass


func move_tetro(tetro, dir):
	tetro.coord += Game.SHIFTS[dir]
	pass


func spawn(origin, player, piece):
	var new_tetro = tetro_prefab.instance()
	new_tetro.coord = origin
	new_tetro.piece = piece
	new_tetro.rot = Game.Rot.R0 if player == Game.Player.LEFT else Game.Rot.R2
	new_tetro.rel_blocks = Game.calc_tetro_rel_coords(new_tetro.piece, new_tetro.rot)
	new_tetro.player = player
	var target_blocks = Game.calc_tetro_abs_coords(new_tetro.coord, new_tetro.piece, new_tetro.rot)
	if is_colliding_blocks(target_blocks):
		print("game over")
		return 
	$Grid.add_child(new_tetro)
	pieces[player] = new_tetro
	pass


func block_locked(player):
	is_updating = true
	for b in pieces[player].get_abs_blocks():
		state[b] = 1
	pieces[player].queue_free()
	update_score()
	spawn(spawn_points[player], player, Game.Piece.J)
	debug_render()
	is_updating = false


func _ready():
	Input.add_joy_mapping("00000000000000000000000000000000,XInput Controller,a:b0,b:b1,back:b6,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,guide:b10,leftshoulder:b4,leftstick:b8,lefttrigger:a2,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b9,righttrigger:a5,rightx:a3,righty:a4,start:b7,x:b2,y:b3,platform:Android,", true)
	$TickTimer.wait_time = tick_interval
	pieces = [0,0]
	tetro_prefab = load("Tetro.tscn")
	debug_block_prefab = load("DebugBlock.tscn")
	grid_origin = Vector2()
	grid_origin.x = (ProjectSettings.get_setting("display/window/size/width") - (size.y * Game.FTILE))/2
	grid_origin.y = (ProjectSettings.get_setting("display/window/size/height") + (size.x * Game.FTILE))/2
	$Grid.position = grid_origin
	for row in range(0,size.y):
		for col in range(0,size.x):
			state[Vector2(col, row)] = 0
			debug_blocks[Vector2(col, row)] = debug_block_prefab.instance()
			$Grid.add_child(debug_blocks[Vector2(col, row)])
			debug_blocks[Vector2(col, row)].position = Vector2(col, row) * 16
			debug_blocks[Vector2(col, row)].get_node("Solid").visible = false
	spawn(spawn_points[Game.Player.LEFT], Game.Player.LEFT, Game.Piece.J)
	spawn(spawn_points[Game.Player.RIGHT], Game.Player.RIGHT, Game.Piece.J)
	pass


func update_score():
	var rows = get_completed_rows()
	if rows.size() == 0:
		return
	$Tween.interpolate_property($Grid, "position", grid_origin + Vector2(0, rows.size()*8), grid_origin, .4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	for r in rows:
		lines += 1
		if r < size.y / 2:
			for s in range(r, 1, -1):
				for c in range(0, size.x):
					state[Vector2(c,s)] = state[Vector2(c,s-1)] if s>0 else 0
		else: 
			for s in range(r, size.y-1, 1):
				for c in range(0, size.x):
					state[Vector2(c,s)] = state[Vector2(c,s+1)] if s<size.y else 0
	print("lines: ", lines)
	pass


func _input(ev):
	if ev is InputEventMouseButton or ev is InputEventJoypadButton:
		OS.window_fullscreen = true
	pass

func _process(delta):
	pieces[0].render()
	pieces[1].render()
	
	if is_updating:
		return
	if Input.is_action_just_released("pl_rot_c"):
		rotate_tetro(pieces[Game.Player.LEFT], true)
	if Input.is_action_just_released("pl_rot_cc"):
		rotate_tetro(pieces[Game.Player.LEFT], false)
	if Input.is_action_just_released("pl_up"):
		shift_tetro(pieces[Game.Player.LEFT], Game.Dir.R, Game.Player.LEFT)
	if Input.is_action_just_released("pl_down"):
		shift_tetro(pieces[Game.Player.LEFT], Game.Dir.L, Game.Player.LEFT)
	if Input.is_action_just_released("pl_drop_soft"):
		shift_tetro(pieces[Game.Player.LEFT], Game.Dir.D, Game.Player.LEFT)
		
	if Input.is_action_just_released("pr_rot_c"):
		rotate_tetro(pieces[Game.Player.RIGHT], true)
	if Input.is_action_just_released("pr_rot_cc"):
		rotate_tetro(pieces[Game.Player.RIGHT], false)
	if Input.is_action_just_released("pr_up"):
		shift_tetro(pieces[Game.Player.RIGHT], Game.Dir.R, Game.Player.RIGHT)
	if Input.is_action_just_released("pr_down"):
		shift_tetro(pieces[Game.Player.RIGHT], Game.Dir.L, Game.Player.RIGHT)
	if Input.is_action_just_released("pr_drop_soft"):
		shift_tetro(pieces[Game.Player.RIGHT], Game.Dir.U, Game.Player.RIGHT)
	pass


func _on_TickTimer_timeout():
	if is_updating:
		return
	for i in range(0,2):
		shift_tetro(pieces[i], Game.Dir.D if i == Game.Player.LEFT else Game.Dir.U, i)
	pass

