extends Area3D

var playerInRange:=false;
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_button: MeshInstance3D = $MainButton

@export var terminal:PackedScene

@export_group("MODE (SELECT ONLY ONE)")
@export var laserGame:=false
@export var terminalGame:=false

signal buttonPressed(body:CharacterBody3D)
@onready var label_3d: Label3D = $Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(laserGame):
		label_3d.text="Press E To Disable Lasers"
	elif (terminalGame):
		label_3d.text="Press E TO Access Terminal"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(playerInRange and Input.is_key_pressed(KEY_E)):
			buttonPressed.emit()
			playerInRange=false
	#if (laserGame):
		#
		#
	#
	#elif (terminalGame):
		#
		#if(playerInRange and Input.is_key_pressed(KEY_E)):
			#print("Terminal Enabled")
			#get_tree().current_scene.add_child(terminal.instantiate())
			#playerInRange=false
		

func _on_body_entered(body: CharacterBody3D) -> void:
	playerInRange=true
	animation_player.play("ButtonGlow")
	#main_button.get_surface_override_material(0).e


func _on_body_exited(body: CharacterBody3D) -> void:
	animation_player.play("ButtonGlow_off")
	playerInRange=false

	
	


func _on_button_pressed():
	if terminalGame:
		print("Terminal Enabled")
		# Instantiate the terminal
		var terminal_instance = terminal.instantiate()
		# Add it to the main scene
		get_tree().current_scene.add_child(terminal_instance)
	elif laserGame:
		print("LASERS DISABLED")
