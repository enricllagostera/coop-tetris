extends Node2D

export var random_pitch_min = 0.85
export var random_pitch_max = 1.25

func play_sfx(sfx:AudioStreamPlayer):
	sfx.pitch_scale = rand_range(random_pitch_min, random_pitch_max)
	sfx.play()


func play_solo(sfx:AudioStreamPlayer):
	for s in get_children():
		if s.name == "Music":
			s.pitch_scale = 0.5
		else:
			s.stop()
	sfx.play()
	pass
