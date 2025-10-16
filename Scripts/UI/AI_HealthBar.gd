extends Node


#extends Node
#
#@export var progress_bar: ProgressBar
#
#var health=100
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
## Wait until the scene tree is fully loaded
	##await get_tree().process_frame   
	#progress_bar = get_tree().current_scene.get_node("CanvasLayer/ProgressBar")
#
#
### Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(_delta: float) -> void:
	##progress_bar.value=health
	#
#func ReduceHealth():
	#health-=25
	#rpc("sync_health", health)  # Call sync_health on all clients (and self)
	#
#@rpc("any_peer")
#func sync_health(new_health: int):
	#health = new_health
	#update_progress_bar()
#
#func update_progress_bar():
	#if progress_bar:
		#progress_bar.value = health

@export var progress_bar: ProgressBar
var health: int = 100
var showBar=true
@onready var cutscene_camera: Camera3D = get_tree().root.get_node("Map/Cutscene")
@onready var anim_player: AnimationPlayer = get_tree().root.get_node("Map/Cutscene/AnimationPlayer")


func _ready():
	call_deferred("_assign_progress_bar")

func _assign_progress_bar():
	var map_node = get_tree().root.get_node("Map")
	if map_node:
		progress_bar = map_node.get_node("AIHealth")  # Adjust if nested deeper inside Map
		if progress_bar and is_instance_valid(progress_bar):
			update_progress_bar()
		else:
			print("ProgressBar not found under Map node!")
	else:
		print("Map node not found at root!")

func set_progress_bar(bar: ProgressBar):
	progress_bar = bar
	update_progress_bar()


func update_progress_bar():
	if progress_bar and is_instance_valid(progress_bar):
		progress_bar.value = health
	else:
		print("Warning: progress_bar is null or invalid!")


@rpc("authority")  # Clients call this -> server executes
func request_reduce_health():
	ReduceHealth()

func ReduceHealth():
	health -= 25
	rpc("sync_health", health)
	update_progress_bar()
	
	if health <= 0:
		play_cutscene()
		
		

@rpc("any_peer") 
func sync_health(new_health: int):
	health = new_health
	update_progress_bar()
	
@rpc("any_peer")
func play_cutscene():
	print("--- CUTSCENE START ---")
	cutscene_camera.current = true
	anim_player.play("ai_defeated")

	await get_tree().create_timer(1).timeout

	cutscene_camera.current = false

	#print("Searching for player camera...")
	#for cam in get_all_cameras():
		#print("Found:", cam.get_path())

	var player_cam = find_camera_by_path_fragment("Head")  # Adjust if needed
	if player_cam:
		player_cam.current = true
		print("✅ Switched to player camera:", player_cam.get_path())
	else:
		print("❌ Player camera not found!")
	
	anim_player.play("RESET")

	
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

#@rpc("any_peer")
#func enableDust():
	#for plyr in get_tree().current_scene.get_children():
		#if plyr is CharacterBody3D:
			#plyr.get_child(1).get_child(0).visible=true
			#break
#
#func _unhandled_input(event: InputEvent) -> void:
	#if(Input.is_key_pressed(KEY_0)):
		#enableDust()
