extends Node3D
#@onready var animation_player: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer
#var animationPlaying=false

@export var is_working=true
@export var terminal:PackedScene
@export var cutSceneCam:Camera3D

var active_player: CharacterBody3D = null
var overlapping_player: CharacterBody3D = null
var inRange=false
var terminalUsed=false
var initialSet=false
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		#print_all_cameras()
	var player_cam =find_camera_by_path_fragment("/Head")
	#print(player_cam.get_path())
	if player_cam:
		player_cam.current = true
	
	#playAnimation()
	pass
# 🔍 Utility: Print all cameras
func print_all_cameras() -> void:
	var cameras = get_all_cameras()
	print("---- All Cameras in Scene ----")
	for cam in cameras:
		print(cam.get_path())
	print("------------------------------")


# 🔍 Utility: Get all cameras recursively
func get_all_cameras() -> Array:
	var cameras: Array = []
	var root = get_tree().current_scene
	if root:
		_find_cameras_recursive(root, cameras)
	return cameras


# Recursive helper
func _find_cameras_recursive(node: Node, cameras: Array) -> void:
	if node is Camera3D:
		cameras.append(node)
	for child in node.get_children():
		_find_cameras_recursive(child, cameras)


func find_camera_by_path_fragment(fragment: String) -> Camera3D:
	for cam in get_all_cameras():
		if fragment in str(cam.get_path()):
			return cam
	return null


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event: InputEvent) -> void:
	if(is_working and inRange and !terminalUsed):
		if overlapping_player and overlapping_player.get_multiplayer_authority() == multiplayer.get_unique_id():
			if Input.is_action_pressed("interact"):
				terminalUsed=true
				active_player=overlapping_player
				var parent=get_parent().get_parent()
				
				if(cutSceneCam!=null): cutSceneCam.current=true
				
				var animPlayer:AnimationPlayer=parent.get_node("AnimationPlayer")
				#print(animPlayer.get)
				animPlayer.play("ConsoleFoucs")
				
				await get_tree().create_timer(3).timeout
				#print("NAMEEEEEEEEEEEEEE: "+str(active_player.get_node("Model/Head/Camera3D").name))
				active_player.get_node("Model/Head/Camera3D").current=true
				if(terminal!=null):
					#print("NOTNULL__________________________________________")
					var console=terminal.instantiate()
					get_tree().current_scene.add_child(console)
					console.linkedPlayer=active_player
					
					#print(console.get_path())
					if(cutSceneCam!=null):cutSceneCam.current=false
					animPlayer.play("RESET")
					cutSceneCam.queue_free()
				###############################
				#var player_cam =find_camera_by_path_fragment("/Head")
				##print(player_cam.get_path())
				#if player_cam:
					#player_cam.current = true
					#######################################
				#print_all_cameras()
			#print("__________________________________________NULLL")
			
func _process(delta: float) -> void:
	if(cutSceneCam!=null and !initialSet):
		cutSceneCam.current=false
		initialSet=true
		

func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	player=body
	if body is CharacterBody3D and is_working:
		inRange = true
		overlapping_player = body


func _on_area_3d_body_exited(body: CharacterBody3D) -> void:
	if body == overlapping_player:
		inRange = false
		overlapping_player = null
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
