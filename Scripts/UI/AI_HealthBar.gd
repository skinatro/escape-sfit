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
extends Node

@export var progress_bar: ProgressBar
var health: int = 100

func _ready() -> void:
	progress_bar = get_tree().current_scene.get_node_or_null("CanvasLayer/ProgressBar")
	update_progress_bar()

func update_progress_bar():
	if progress_bar and is_instance_valid(progress_bar):
		progress_bar.value = health

@rpc("authority")  # Clients call this -> server executes
func request_reduce_health():
	ReduceHealth()

func ReduceHealth():
	health -= 25
	rpc("sync_health", health)
	update_progress_bar()

@rpc("any_peer")  # Server calls this -> all peers receive
func sync_health(new_health: int):
	health = new_health
	update_progress_bar()
