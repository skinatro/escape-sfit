extends Control


@onready var freq_slider: HSlider = $ColorRect/VBoxContainer/HBoxContainer/VBoxContainer/freq_slider
@onready var freq_rotor: TextureButton = $FreqRotor

@onready var gain_slider: HSlider = $ColorRect/VBoxContainer/HBoxContainer/VBoxContainer3/gain_slider
@onready var amp_rotor: TextureButton = $AmpRotor

@onready var graph: Control = $ColorRect/Graph
@onready var feedback: Label = $ColorRect/Label

@onready var camera: Camera2D = $Camera2D


var shake_strength := 0.0
var shake_decay := 3.0
var noise := 0.0


var target_wave = {}
var player_wave = {}

# parameters
var target_freq := 2.0
var target_phase := 0.0
var target_gain := 1.0

var phase:float
var freq:float=0
var amplitude:float=0
#var diff 
var missAlignTimer:=0.0
var miss_alligned=false;


var using_FreqRotor=false
var using_AmpRotor=false
var canChange:=true

func _ready():
	randomize()
	# randomize target wave
	target_freq = int(randf_range(1.0, 25.0))
	target_phase = randf_range(0, TAU)
	target_gain = int(randf_range(0.5, 10))
	update_player()
	graph.queue_redraw()

func _process(_delta):

	update_player()
	graph.queue_redraw()
	var diff=give_feedback()
	phase=_updatePhase(_delta)
	
	# Update camera shake based on diff
	shake_strength = lerp(shake_strength, diff * 2.0, 0.1)  # smoother transitions
	_apply_camera_shake(_delta,diff)
	
	# Update noise intensity for graph
	noise = lerp(noise, diff * 0.1, 0.1)

	
	#Wave reset logic:
	if(!miss_alligned and Input.is_key_pressed(KEY_E)):
		#WIN CASE
		amplitude=amplitude*-1
	elif(miss_alligned and Input.is_key_pressed(KEY_E)):
		resetWave()
		
	
	#ROTOR LOGICS
	if(using_FreqRotor):
		freq_rotor.scale=Vector2(.36,.36)
		amp_rotor.scale=Vector2(.4,.4)
		freq_rotor.modulate.a=1
		amp_rotor.modulate.a=0.4
		if(Input.is_action_pressed("Right_arrow") or Input.is_action_pressed("right")):
			freq+=.05
			freq_rotor.rotation+=.5*_delta

		elif(Input.is_action_pressed("Left_arrow") or Input.is_action_pressed("left")):
			freq-=.05
			freq_rotor.rotation-=.5*_delta
			
	elif(using_AmpRotor):
		amp_rotor.scale=Vector2(.36,.36)
		freq_rotor.scale=Vector2(.4,.4)
		amp_rotor.modulate.a=1
		freq_rotor.modulate.a=0.4
		if(Input.is_action_pressed("Right_arrow") or Input.is_action_pressed("right")):
			amplitude+=.05
			amp_rotor.rotation+=.5*_delta

		elif(Input.is_action_pressed("Left_arrow") or Input.is_action_pressed("left")):
			amplitude-=.05
			amp_rotor.rotation-=.5*_delta
	
	

func update_player():
	player_wave = {
		"freq": abs(freq),
		"phase": phase,
		"gain": abs(amplitude)
	}

func give_feedback():
	var diff = abs(target_wave_diff())
	if diff < 0.1:
		feedback.text = "Aligned! Phase out to destroy."
		feedback.modulate = Color.GREEN
		miss_alligned=false
	elif diff < 0.2:
		feedback.text = "Almost there..."
		feedback.modulate = Color.YELLOW
		miss_alligned=false
	else:
		feedback.text = "Misaligned..."
		feedback.modulate = Color.RED
		miss_alligned=true
	return diff

func target_wave_diff() -> float:
	# compute normalized diff between player and target
	var f_diff = abs(target_freq - player_wave.freq) / 5.0
	#var p_diff = abs(wrapf(target_phase - player_wave.phase, -PI, PI)) / PI
	var g_diff = abs(target_gain - player_wave.gain) / 2.0
	#return (f_diff + p_diff + g_diff) / 3.0
	return (f_diff + g_diff) / 2.0

func amp_Difference()->float:
	var g_diff = abs(target_gain - player_wave.gain) / 2.0
	return g_diff
	
func freq_Difference()->float:
	var f_diff = abs(target_freq - player_wave.freq) / 5.0
	return f_diff

func _updatePhase(delta):
	if(player_wave.phase>=-100):
		player_wave.phase-= 2* delta
	else:
		player_wave.phase=0
	
	return float(player_wave.phase)

func resetWave():
	missAlignTimer = 0
	# Randomize new AI (target) wave instead of player wave
	target_freq = randi_range(1.0, 25.0)
	target_phase = randi_range(0, TAU)
	target_gain = randi_range(0.5, 10.0)
	
	# Optionally, also scramble player sliders
	freq = randi_range(1.0, 25.0)
	amplitude = randi_range(0.5, 10.0)
	
	# reset phase
	phase = 0
	
	feedback.text = "AI scrambled console!"
	feedback.modulate = Color.ORANGE

#func _apply_camera_shake(delta):
	#if camera:
		#if shake_strength > 0.01:
			#var offset = Vector2(
				#randf_range(-shake_strength, shake_strength),
				#randf_range(-shake_strength, shake_strength)
			#)
			#camera.offset = offset
			#shake_strength = max(shake_strength - shake_decay * delta, 0)
		#else:
			#camera.offset = Vector2.ZERO
var time_passed:=0.0
func _apply_camera_shake(delta, diff):
	if camera:
		time_passed += delta * 2.0  # Controls overall shake speed

		# Get individual normalized differences (0 to ~1)
		var amp_diff = amp_Difference()
		var freq_diff = freq_Difference()
		
		# Invert intensity so smaller difference = less shake
		var amp_intensity = pow(clamp(amp_diff, 0.0, 1.0), 1.0) * 20.0
		var freq_intensity = pow(clamp(freq_diff, 0.0, 1.0), 1.0) * 20.0

		# Add some smooth oscillation (sin/cos waves)
		var x_offset = sin(time_passed * 15.0) * freq_intensity
		var y_offset = cos(time_passed * 20.0) * amp_intensity

		# Smoothly interpolate camera offset to prevent harsh jumps
		camera.offset = camera.offset.lerp(Vector2(x_offset, y_offset), delta * 10.0)





func _on_button_pressed() -> void:#FREQUENCTY ROTOR
	using_FreqRotor=true
	using_AmpRotor=false
	get_viewport().set_input_as_handled()
	


func _on_amp_rotor_pressed() -> void:
	using_FreqRotor=false
	using_AmpRotor=true
	get_viewport().set_input_as_handled()
