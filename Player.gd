extends Node2D

var down_direction = Vector2(1,0)
var has_active_piece = false
export var tetro_prefabs = []
var next_tetros = []
var current_tetro


# Called when the node enters the scene tree for the first time.
func _ready():
	reset_queue()
	pass # Replace with function body.

func reset_queue():
	next_tetros = Array()
	tetro_prefabs.shuffle()
	for b in tetro_prefabs:
		next_tetros.append("Block"+b+".tscn") 
	pass

func spawn_next_tetro():
	has_active_piece = true
	current_tetro = load(next_tetros[0]).instance()
	next_tetros.remove(0)
	if next_tetros.size() == 0:
		reset_queue()
	current_tetro.position = self.position
	current_tetro.down_direction = down_direction
	get_parent().add_child(current_tetro)
	current_tetro.connect("block_locked", self, "_on_block_locked")
	pass


func _on_TickTimer_timeout():
	if not has_active_piece:
		print("spawn")
		spawn_next_tetro()
	else:
		current_tetro.move()
	pass # Replace with function body.
	
func _on_block_locked():
	print("locked")
	has_active_piece = false
