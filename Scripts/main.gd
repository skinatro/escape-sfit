extends Node3D

var peer=ENetMultiplayerPeer.new()
@export var playerScene:PackedScene
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@export var Spawnpoint:Area3D

func _on_host_pressed() -> void:
	Ai.set_progress_bar($CanvasLayer/ProgressBar)
	peer.create_server(1027)
	multiplayer.multiplayer_peer=peer
	multiplayer.peer_connected.connect(add_Player)
	add_Player()
	canvas_layer.get_node("Host").hide()
	canvas_layer.get_node("Join").hide()

func _on_join_pressed() -> void:
	#Ai.showBar=true
	Ai.set_progress_bar($CanvasLayer/ProgressBar)
	peer.create_client("127.0.0.1",1027)
	multiplayer.multiplayer_peer=peer
	canvas_layer.get_node("Host").hide()
	canvas_layer.get_node("Join").hide()
	
func add_Player(id=1):
	var player= playerScene.instantiate();
	player.global_position=Spawnpoint.global_position
	player.name=str(id)
	call_deferred("add_child",player)
	
func delete_Player(id):
	rpc("_delete_Player",id)
	
@rpc("any_peer","call_local")
func _delete_Player(id):
	get_node(str(id)).queue_free()
	
func exit(id):
	multiplayer.peer_disconnected.connect(delete_Player)
	delete_Player(id)
