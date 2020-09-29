extends Node2D

export var random_pitch_min = 0.85
export var random_pitch_max = 1.25

func play_sfx(sfx:AudioStreamPlayer):
	sfx.pitch_scale = rand_range(random_pitch_min, random_pitch_max)
	sfx.play()
