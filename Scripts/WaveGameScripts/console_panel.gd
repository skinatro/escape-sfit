extends Node3D
#@onready var animation_player: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer
#var animationPlaying=false

@export var is_working=true
@export var terminal:PackedScene
@export var cutSceneCam:Camera3D
var inRange=false
var terminalUsed=false
var initialSet=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#playAnimation()
	pass



	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event: InputEvent) -> void:
	if(is_working and inRange and !terminalUsed and Input.is_action_pressed("interact")):
		terminalUsed=true
		var parent=get_parent().get_parent()
		var playerCam=parent.get_parent().get
		if(cutSceneCam!=null): cutSceneCam.current=true
		
		var animPlayer:AnimationPlayer=parent.get_node("AnimationPlayer")
		#print(animPlayer.get)
		animPlayer.play("ConsoleFoucs")
		
		await get_tree().create_timer(3).timeout
		
		if(terminal!=null):
			get_tree().current_scene.add_child(terminal.instantiate())
			if(cutSceneCam!=null):cutSceneCam.current=false
			animPlayer.play("RESET")
			cutSceneCam.queue_free()
			#for c in get_children():
				#if c is Camera3D:
					#c.queue_free()
			print("ConsoleCam Removed")
			
func _process(delta: float) -> void:
	if(cutSceneCam!=null and !initialSet):
		cutSceneCam.current=false
		initialSet=true
		

func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if(is_working):inRange=true


func _on_area_3d_body_exited(body: CharacterBody3D) -> void:
	if(is_working):inRange=false
#extends Node3D
#
#@export var is_working = true
#@export var terminal: PackedScene
#@export var cutSceneCam: Camera3D
#
#var inRange = false
#var terminalUsed = false
#var initialSet = false
#var prev_camera: Camera3D = null
#
#@export var playerCam: Camera3D
#func _unhandled_input(event: InputEvent) -> void:
	#if is_working and inRange and not terminalUsed and Input.is_action_pressed("interact"):
		#terminalUsed = true
		#var parent = get_parent().get_parent()
		#
		## Activate this cutscene camera
		#if cutSceneCam:
			#cutSceneCam.current = true
		#
		#var animPlayer: AnimationPlayer = parent.get_node("AnimationPlayer")
		#animPlayer.play("ConsoleFoucs")
		#
		#await get_tree().create_timer(3).timeout
		#
		#if terminal:
			#get_tree().current_scene.add_child(terminal.instantiate())
		#
		## Disable cutscene cam and restore player control
		#if cutSceneCam:
			#cutSceneCam.current = false
		#
		#if playerCam:
			#playerCam.current = true  # ✅ Force player camera active
		#
		#animPlayer.play("RESET")
#
#
#func _process(delta: float) -> void:
	#if cutSceneCam and not initialSet:
		#cutSceneCam.current = false
		#initialSet = true
#
#
#func _on_area_3d_body_entered(body) -> void:
	#if is_working and body is CharacterBody3D:
		#inRange = true
#
#
#func _on_area_3d_body_exited(body) -> void:
	#if is_working and body is CharacterBody3D:
		#inRange = false
