extends Node3D
@export var is_working=false
@export var terminal:PackedScene
@export var cutSceneCam:Camera3D
var active_player: CharacterBody3D = null
var overlapping_player: CharacterBody3D = null
var inRange=false
var terminalUsed=false
var initialSet=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _unhandled_input(event: InputEvent) -> void:
	#if(is_working and inRange and !terminalUsed and Input.is_action_pressed("interact")):
		#terminalUsed=true
		#
		#var parent=get_parent().get_parent().get_parent().get_parent().get_parent()
		#if(cutSceneCam!=null): cutSceneCam.current=true
		#
		#var animPlayer:AnimationPlayer=parent.get_node("AnimationPlayer")
		#animPlayer.play("TerminalFocus")
		#
		#await get_tree().create_timer(3).timeout
		#
		#if(terminal!=null):
			#get_tree().current_scene.add_child(terminal.instantiate())
			#if(cutSceneCam!=null):cutSceneCam.current=false
			#animPlayer.play("RESET")
			#cutSceneCam.queue_free()
			#print("TerminalCam Removed")
			#
			#print_all_cameras()
			##cutSceneCam=null

#func print_all_cameras() -> void:
	#var cameras = get_all_cameras()
	#print("---- All Cameras in Scene ----")
	#for cam in cameras:
		#print(cam.get_path())  # or cam.name for just the name
	#print("------------------------------")
#
#
#func get_all_cameras() -> Array:
	#var cameras: Array = []
	#var root = get_tree().current_scene
	#if root:
		#_find_cameras_recursive(root, cameras)
	#return cameras
#
#
#func _find_cameras_recursive(node: Node, cameras: Array) -> void:
	#if node is Camera3D:
		#cameras.append(node)
	#for child in node.get_children():
		#_find_cameras_recursive(child, cameras)
		
#func _unhandled_input(event: InputEvent) -> void:
	#if is_working and inRange and !terminalUsed and Input.is_action_pressed("interact"):
		#terminalUsed = true
		#
		#var parent = get_parent().get_parent().get_parent().get_parent().get_parent()
		#var animPlayer: AnimationPlayer = parent.get_node("AnimationPlayer")
		#
		## 🎬 Start cutscene camera
		#if cutSceneCam:
			#cutSceneCam.current = true
		#
		#animPlayer.play("TerminalFocus")
		#
		#await get_tree().create_timer(3).timeout
		#
		## 🧩 Spawn terminal
		#if terminal:
			#get_tree().current_scene.add_child(terminal.instantiate())
			#
			## ❌ Disable cutscene cam
			#if cutSceneCam:
				#cutSceneCam.current = false
				#cutSceneCam.queue_free()
				#print("TerminalCam Removed")
			#
			## 🎥 Switch back to player camera
			#var player_cam = find_camera_by_path_fragment("ProtoController/Head")
			#if player_cam:
				#player_cam.current = true
				#print("Switched to Player Camera:", player_cam.get_path())
			#else:
				#print("Player camera not found!")
#
			#animPlayer.play("RESET")
#
			##print_all_cameras()

#func find_camera_by_path_fragment(fragment: String) -> Camera3D:
	#for cam in get_all_cameras():
		#if fragment in cam.get_path():
			#return cam
	#return null
#
#
#func _process(delta: float) -> void:
	#if(cutSceneCam!=null and !initialSet):
		#cutSceneCam.current=false
		#initialSet=true
#
#
#func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	#if(is_working):inRange=true
		#
#
#
#func _on_area_3d_body_exited(body: Node3D) -> void:
	#if(is_working):inRange=false
#extends Node3D
#
#@export var is_working = true
#@export var terminal: PackedScene
#@export var cutSceneCam: Camera3D
#var inRange = false
#var terminalUsed = false
#var initialSet = false
#
#
#func _ready() -> void:
	#pass


func _unhandled_input(event: InputEvent) -> void:
	if is_working and inRange and !terminalUsed:
		if overlapping_player and overlapping_player.get_multiplayer_authority() == multiplayer.get_unique_id():
			if Input.is_action_pressed("interact"):
				terminalUsed = true
				active_player=overlapping_player
				
				
				var parent = get_parent().get_parent().get_parent().get_parent().get_parent()
				var animPlayer: AnimationPlayer = parent.get_node("AnimationPlayer")
				
				# 🎬 Enable cutscene cam
				if cutSceneCam:
					cutSceneCam.current = true
				
				animPlayer.play("TerminalFocus")
				
				await get_tree().create_timer(3).timeout
				active_player.get_node("Model/Head/Camera3D").current=true
				
				# 🧩 Spawn terminal
				if terminal:
					var terminalInstance=terminal.instantiate()
					get_tree().current_scene.add_child(terminalInstance)
					terminalInstance.linkedPlayer=active_player
					
					# ❌ Disable and remove cutscene camera
					if cutSceneCam:
						cutSceneCam.current = false
						cutSceneCam.queue_free()
						print("TerminalCam Removed")
					
					# 🎥 Switch back to player camera
					#var player_cam = find_camera_by_path_fragment("/Head")
					#if player_cam:
						#player_cam.current = true
						#print("Switched to Player Camera:", player_cam.get_path())
					#else:
						#print("Player camera not found!")

					animPlayer.play("RESET")
				#print_all_cameras()


func _process(delta: float) -> void:
	if cutSceneCam and !initialSet:
		cutSceneCam.current = false
		initialSet = true


func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if body is CharacterBody3D and is_working:
		inRange = true
		overlapping_player = body


func _on_area_3d_body_exited(body: CharacterBody3D) -> void:
	if body == overlapping_player:
		inRange = false
		overlapping_player = null


## 🔍 Utility: Print all cameras
#func print_all_cameras() -> void:
	#var cameras = get_all_cameras()
	#print("---- All Cameras in Scene ----")
	#for cam in cameras:
		#print(cam.get_path())
	#print("------------------------------")


## 🔍 Utility: Get all cameras recursively
#func get_all_cameras() -> Array:
	#var cameras: Array = []
	#var root = get_tree().current_scene
	#if root:
		#_find_cameras_recursive(root, cameras)
	#return cameras
#
#
## Recursive helper
#func _find_cameras_recursive(node: Node, cameras: Array) -> void:
	#if node is Camera3D:
		#cameras.append(node)
	#for child in node.get_children():
		#_find_cameras_recursive(child, cameras)
#
#
#func find_camera_by_path_fragment(fragment: String) -> Camera3D:
	#for cam in get_all_cameras():
		#if fragment in str(cam.get_path()):
			#return cam
	#return null
