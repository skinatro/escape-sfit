extends Node3D
var canSelectBlocks=false
var canDo=true
var is_blockSelected=false
var Player
@export var is_working=true
@export var terminal:PackedScene
@export var cutSceneCam:Camera3D
var inRange=false
var terminalUsed=false
var initialSet=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_cam = find_camera_by_path_fragment("/Head")
	if player_cam:
		player_cam.current = true
		print("Switched to Player Camera:", player_cam.get_path())
	else:
		print("Player camera not found!")
	 # Loop through all children
	pass

#func _unhandled_input(event: InputEvent) -> void:
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(canDo):
		for child in get_children():
			if child is Node3D and child.name.contains("Puzzle"):
				child.parent_node = self
				canDo=false
	if cutSceneCam and !initialSet:
		cutSceneCam.current = false
		initialSet = true
		
	if is_working and inRange and !terminalUsed :
		terminalUsed = true
		
		var parent = get_parent().get_parent().get_parent()
		var animPlayer: AnimationPlayer = parent.get_node("AnimationPlayer")
		
		# 🎬 Enable cutscene cam
		if cutSceneCam:
			cutSceneCam.current = true

		animPlayer.play("BlockAnim")

		
		await get_tree().create_timer(3).timeout
		
		# 🧩 Spawn terminal
		#if terminal:
			#get_tree().current_scene.add_child(terminal.instantiate())
			
			# ❌ Disable and remove cutscene camera
		if cutSceneCam:
			cutSceneCam.current = false
			cutSceneCam.queue_free()
			print("TerminalCam Removed")
			
			# 🎥 Switch back to player camera
			var player_cam = find_camera_by_path_fragment("/Head")
			if player_cam:
				player_cam.current = true
				print("Switched to Player Camera:", player_cam.get_path())
			else:
				print("Player camera not found!")

			animPlayer.play("RESET")
			print_all_cameras()



func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if is_working:
		inRange = true
	Player=body
	if body.is_class("CharacterBody3D"):
		#body.enter_block()   # block the player
		body.blockGameActive = true
		body.release_mouse()
		canSelectBlocks = true
		print("Entered block: Player blocked")


func _on_area_3d_body_exited(body:CharacterBody3D ) -> void:
	Player=null
	if is_working:
		inRange = false
	if body.is_class("CharacterBody3D"):
		body.exit_block()    # unblock if no other blocks
		body.blockGameActive = false
		canSelectBlocks = false
		print("Exited block: Player unblocked")

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
