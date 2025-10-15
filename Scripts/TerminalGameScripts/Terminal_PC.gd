extends Node3D
@export var is_working=false
@export var terminal:PackedScene
@export var cutSceneCam:Camera3D
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
	if is_working and inRange and !terminalUsed and Input.is_action_pressed("interact"):
		terminalUsed = true
		
		var parent = get_parent().get_parent().get_parent().get_parent().get_parent()
		var animPlayer: AnimationPlayer = parent.get_node("AnimationPlayer")
		
		# 🎬 Enable cutscene cam
		if cutSceneCam:
			cutSceneCam.current = true
		
		animPlayer.play("TerminalFocus")
		
		await get_tree().create_timer(3).timeout
		
		# 🧩 Spawn terminal
		if terminal:
			get_tree().current_scene.add_child(terminal.instantiate())
			
			# ❌ Disable and remove cutscene camera
			if cutSceneCam:
				cutSceneCam.current = false
				cutSceneCam.queue_free()
				print("TerminalCam Removed")
			
			# 🎥 Switch back to player camera
			var player_cam = find_camera_by_path_fragment("ProtoController/Head")
			if player_cam:
				player_cam.current = true
				print("Switched to Player Camera:", player_cam.get_path())
			else:
				print("Player camera not found!")

			animPlayer.play("RESET")
			print_all_cameras()


func _process(delta: float) -> void:
	if cutSceneCam and !initialSet:
		cutSceneCam.current = false
		initialSet = true


func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if is_working:
		inRange = true


func _on_area_3d_body_exited(body: CharacterBody3D) -> void:
	if is_working:
		inRange = false


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
