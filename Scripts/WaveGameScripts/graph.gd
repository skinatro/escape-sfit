extends Control  # instead of Node2D

@onready var parent = get_parent().get_parent()
@onready var console = get_parent().get_parent()

var player_wave_alpha := 1.0  # 1.0 = fully visible, 0.0 = invisible
var is_fading_out := false
const FADE_SPEED := 0.5  # Adjust as needed (units per second)

signal playerWaveVanished

func _ready() -> void:
	console.PlayerWon.connect(_on_playerWon)
	
func _process(delta: float) -> void:
	if is_fading_out:
		player_wave_alpha = max(player_wave_alpha - delta * FADE_SPEED, 0.0)
		queue_redraw()  # Redraw the waveform with updated alpha

func _draw():
	var width = size.x
	var height = size.y
	var center_y = height / 2

	# --- Target (AI) waveform (optional) ---
	var prev_t = Vector2(0, center_y)
	for x in range(width):
		var t = x / 100.0
		var y = center_y - sin(t * parent.target_freq + parent.target_phase) * parent.target_gain * 50
		# Uncomment if you want to see AI wave:
		# draw_line(prev_t, Vector2(x, y), Color(1, 0, 0, 0.6), 2)
		prev_t = Vector2(x, y)

	# --- Player waveform with strong glow ---
	prev_t = Vector2(0, center_y)
	for x in range(width):
		var t = x / 100.0
		var noise_offset = randf_range(-console.noise * 20.0, console.noise * 20.0)
		var y = center_y - sin(t * console.player_wave.freq + console.player_wave.phase) * console.player_wave.gain * 50 + noise_offset
		var current_t = Vector2(x, y)

		## Outer halo — very soft but wide
		#draw_line(prev_t, current_t, Color(1, 1, 0, 0.25), 36)
#
		## Mid glow — more visible
		#draw_line(prev_t, current_t, Color(1, 1, 0, 0.35), 26)
#
		## Inner glow — bright and tighter
		#draw_line(prev_t, current_t, Color(1, 1, 0, 0.45), 16)
#
		## Core beam — crisp and intense
		#draw_line(prev_t, current_t, Color(1, 1, 0, 1.0), 6)
		
		# Inner glow with fading alpha
		draw_line(prev_t, current_t, Color(1, 1, 0, 0.25 * player_wave_alpha), 36)
		draw_line(prev_t, current_t, Color(1, 1, 0, 0.35 * player_wave_alpha), 26)
		draw_line(prev_t, current_t, Color(1, 1, 0, 0.45 * player_wave_alpha), 16)
		draw_line(prev_t, current_t, Color(1, 1, 0, 1.0 * player_wave_alpha), 6)

		prev_t = current_t
		
		if(player_wave_alpha==0):
			emit_signal("playerWaveVanished")

func _on_playerWon():
	is_fading_out=true


	
