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
@onready var cutscene_camera: Camera3D = $"../Cutscene"
@onready var anim_player: AnimationPlayer = $"../Cutscene/AnimationPlayer"

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
	
	#if health <= 0:
		#cutscene_camera.current = true

@rpc("any_peer") 
func sync_health(new_health: int):
	health = new_health
	update_progress_bar()
