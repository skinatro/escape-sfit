##extends Area3D
##
##var playerInRange:=false;
##@onready var animation_player: AnimationPlayer = $AnimationPlayer
##@onready var main_button: MeshInstance3D = $MainButton
##
##@export var terminal:PackedScene
##@export var Console:PackedScene
##
##@export_group("MODE (SELECT ONLY ONE)")
##@export var laserGame:=false
##@export var terminalGame:=false
##@export var waveGame:=false
##
##signal buttonPressed(body:CharacterBody3D)
##@onready var label_3d: Label3D = $Label3D
##
### Called when the node enters the scene tree for the first time.
##func _ready() -> void:
	##if(laserGame):
		##label_3d.text="Press E To Disable Lasers"
	##elif (terminalGame):
		##label_3d.text="Press E TO Access Terminal"
	##elif (waveGame):
		##label_3d.text="Press E TO Access Console"
##
##
### Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta: float) -> void:
	##
	##if(playerInRange and Input.is_key_pressed(KEY_E)):
			##buttonPressed.emit()
			##playerInRange=false
	###if (laserGame):
		###
		###
	###
	###elif (terminalGame):
		###
		###if(playerInRange and Input.is_key_pressed(KEY_E)):
			###print("Terminal Enabled")
			###get_tree().current_scene.add_child(terminal.instantiate())
			###playerInRange=false
		##
##
##func _on_body_entered(body: CharacterBody3D) -> void:
	##playerInRange=true
	##animation_player.play("ButtonGlow")
	###main_button.get_surface_override_material(0).e
##
##
##func _on_body_exited(body: CharacterBody3D) -> void:
	##animation_player.play("ButtonGlow_off")
	##playerInRange=false
##
	##
	##
##
##
##func _on_button_pressed():
	##if terminalGame:
		##print("Terminal Enabled")
		### Instantiate the terminal
		##var terminal_instance = terminal.instantiate()
		### Add it to the main scene
		##get_tree().current_scene.add_child(terminal_instance)
	##elif laserGame:
		##Ai.ReduceHealth()
		##print("LASERS DISABLED")
	##elif waveGame:
		##var console_instance = Console.instantiate()
		##get_tree().current_scene.add_child(console_instance)
		#
extends Area3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_button: MeshInstance3D = $MainButton
@onready var label_3d: Label3D = $Label3D
@export var lazers:Node3D
var used=false
@export var terminal: PackedScene
@export var Console: PackedScene

@export_group("MODE (SELECT ONLY ONE)")
@export var laserGame := false
@export var terminalGame := false
@export var waveGame := false

var active_player: CharacterBody3D = null
var overlapping_player: CharacterBody3D = null
var player_in_range := false
var current_player: CharacterBody3D = null

func _ready() -> void:
	if laserGame:
		label_3d.text = "Press E to Disable Lasers"
	elif terminalGame:
		label_3d.text = "Press E to Access Terminal"
	elif waveGame:
		label_3d.text = "Press E to Access Console"

func _process(delta: float) -> void:
	if !used and overlapping_player and overlapping_player.get_multiplayer_authority() == multiplayer.get_unique_id():
		
		if player_in_range and Input.is_action_just_pressed("interact") :
			used=true
			if multiplayer.is_server():
				# If this player is the host, act directly
				_handle_button_press(multiplayer.get_unique_id())
			else:
				# Send an RPC to the server so it decides
				rpc_id(1, "request_press_button", multiplayer.get_unique_id())

func _on_body_entered(body: CharacterBody3D) -> void:

	if body is CharacterBody3D:
		player_in_range = true
		overlapping_player = body
		current_player = body
		animation_player.play("ButtonGlow")

func _on_body_exited(body: CharacterBody3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false
		overlapping_player = null
		current_player = null
		animation_player.play("ButtonGlow_off")

# Called on the server when any peer requests a press
@rpc("any_peer")
func request_press_button(sender_id: int):
	if not player_in_range:
		return
	_handle_button_press(sender_id)

# Internal logic (runs only on the server)
func _handle_button_press(sender_id: int):
	if laserGame:
		print("Player ", sender_id, " disabled lasers.")
		Ai.ReduceHealth()  # Runs server-side only
		lazers.queue_free()
	elif terminalGame:
		print("Player ", sender_id, " opened terminal.")
		rpc_id(sender_id, "open_terminal_ui")
	elif waveGame:
		print("Player", sender_id, "opened console.")
		rpc_id(sender_id, "open_console_ui")

# UI spawns locally for the player who pressed it
@rpc("any_peer", "call_local")
func open_terminal_ui():
	if terminal:
		if(!get_tree().current_scene.has_node("Terminal")):
			var terminal_instance = terminal.instantiate()
			get_tree().current_scene.add_child(terminal_instance)

@rpc("any_peer", "call_local")
func open_console_ui():
	if Console:
		var console_instance = Console.instantiate()
		get_tree().current_scene.add_child(console_instance)
		
		
		


var initialVelo
func _on_jump_disabler_body_entered(body: CharacterBody3D) -> void:
	initialVelo=body.jump_velocity
	body.jump_velocity=0


func _on_jump_disabler_body_exited(body: CharacterBody3D) -> void:
	body.jump_velocity=initialVelo
