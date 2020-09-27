extends Node2D


export var tick_interval = 0.5
export var tick_interval_base = 0.5
var state = Dictionary()
var size = Vector2(20,30)
var tetro_prefab
var pieces = []
var current_player = Game.Player.RIGHT
var lines = 0
var spawn_points = [Vector2(10,1), Vector2(10,28)]
var debug_block_prefab
var debug_blocks = Dictionary()
var is_updating = false
var grid_origin
var bags = {}
var is_game_over = false


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


func is_horizontally_out_of_bounds(blocks_to_check):
	for c in blocks_to_check:
		if c.x < 0 or c.x >= size.x:
			return true
	return false
	
func is_vertically_out_of_bounds(blocks_to_check):
	for c in blocks_to_check:
		if c.y < 0 or c.y >= size.y:
			return true
	return false


func rotate_tetro(tetro, is_clockwise):
	var rot_table = Game.ROT_CLOCKWISE if is_clockwise else Game.ROT_COUNTERCLOCKWISE
	var target_blocks_abs = Game.calc_tetro_abs_coords(tetro.coord, tetro.piece, rot_table[tetro.rot])
	if is_horizontally_out_of_bounds(target_blocks_abs):
		return
	if is_vertically_out_of_bounds(target_blocks_abs):
		is_game_over = true
		return
	if is_colliding_blocks(target_blocks_abs, tetro.get_abs_blocks()):
		return
	tetro.rot = rot_table[tetro.rot]
	tetro.rel_blocks = Game.calc_tetro_rel_coords(tetro.piece, tetro.rot)
	pass


func shift_tetro(tetro, dir, player):
	var target_blocks = tetro.get_abs_blocks() 
	for b in tetro.rel_blocks:
		target_blocks.append(tetro.coord+b+Game.SHIFTS[dir])
	if is_horizontally_out_of_bounds(target_blocks):
		return
	if is_vertically_out_of_bounds(target_blocks):
		is_game_over = true
		return
	if is_colliding_blocks(target_blocks, tetro.get_abs_blocks(), pieces[Game.Player.LEFT if player == Game.Player.RIGHT else Game.Player.RIGHT]):
		if not tetro.locking:
			tetro.lockdown_started()
			$Tween.interpolate_property(tetro, "position", tetro.position + Vector2(0, 8), tetro.position, .2, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
			$Tween.start()
		return
	if tetro.locking:
		tetro.lockdown_cancelled()
	move_tetro(tetro, dir)
	debug_render()
	pass


func move_tetro(tetro, dir):
	tetro.coord += Game.SHIFTS[dir]
	pass


func spawn(origin, player):
	var new_tetro = tetro_prefab.instance()
	new_tetro.coord = origin
	new_tetro.piece = bags[player].pop_next()
	new_tetro.rot = Game.Rot.R0 if player == Game.Player.LEFT else Game.Rot.R2
	new_tetro.rel_blocks = Game.calc_tetro_rel_coords(new_tetro.piece, new_tetro.rot)
	new_tetro.player = player
	var target_blocks = Game.calc_tetro_abs_coords(new_tetro.coord, new_tetro.piece, new_tetro.rot)
	if is_colliding_blocks(target_blocks):
		print("game over")
		is_game_over = true
		return 
	$Grid.add_child(new_tetro)
	pieces[player] = new_tetro
	update_preview(player)
	pass


func block_locked(player):
	is_updating = true
	for b in pieces[player].get_abs_blocks():
		state[b] = 1
	pieces[player].queue_free()
	$Tween.interpolate_property($Grid, "position", grid_origin + Vector2(0, 4), grid_origin, .1, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	update_score()
	spawn(spawn_points[player], player)
	debug_render()
	is_updating = false


func _ready():
	tick_interval = tick_interval_base
	$TickTimer.wait_time = tick_interval
	bags = {
		Game.Player.LEFT: PieceBag.new(),
		Game.Player.RIGHT: PieceBag.new()
	}
	pieces = [-1,-1]
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
	spawn(spawn_points[Game.Player.LEFT], Game.Player.LEFT)
	spawn(spawn_points[Game.Player.RIGHT], Game.Player.RIGHT)
	pass


func update_preview(player):
	var preview_tetro = $TetroPreviewLeft if player == Game.Player.LEFT else $TetroPreviewRight
	var target_tetro = bags[player].view_next()
	preview_tetro.piece = target_tetro
	preview_tetro.rot = Game.Rot.R0 if player == Game.Player.LEFT else Game.Rot.R2
	preview_tetro.rel_blocks = Game.calc_tetro_rel_coords(preview_tetro.piece, preview_tetro.rot)
	preview_tetro.render_for_ui()
	pass



func update_score():
	var rows = get_completed_rows()
	if rows.size() == 0:
		return
	$Tween.interpolate_property($Grid, "position", grid_origin + Vector2(0, rows.size()*16), grid_origin, .2, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
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
	if is_game_over:
		if Input.is_action_just_released("restart"):
			get_tree().reload_current_scene()
		return
	
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
	if is_updating or is_game_over:
		return
	for i in range(0,2):
		shift_tetro(pieces[i], Game.Dir.D if i == Game.Player.LEFT else Game.Dir.U, i)
#	Speed increase as more lines are made
	tick_interval = tick_interval_base * clamp(1-lines*0.005, 0.5, 1.0)
	$TickTimer.wait_time = tick_interval
	pass

