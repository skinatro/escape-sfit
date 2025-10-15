extends Node3D

var peer := ENetMultiplayerPeer.new()
@export var playerScene: PackedScene
@export var Spawnpoint: Area3D
@onready var canvas_layer: CanvasLayer = $Hosting
@onready var ai_health_bar = $AIHealth
@onready var host_ip_label = canvas_layer.get_node("ShowIP")
@onready var join_ip_input = canvas_layer.get_node("IP")
@onready var host_button = canvas_layer.get_node("Host")
@onready var join_button = canvas_layer.get_node("Join")
@onready var player_count_label = canvas_layer.get_node("Players")
@onready var start_button = canvas_layer.get_node("Start")

var connected_players := 0

func _ready():
	start_button.disabled = true  
	if ai_health_bar:
		ai_health_bar.visible = false 

func _update_player_count():
	player_count_label.text = "Players: %d" % connected_players
	# Enable start if host and 4 or more players joined
	if multiplayer.get_unique_id() == 1 and connected_players >= 0: #change to 4 during actual game
		start_button.disabled = false
	else:
		start_button.disabled = true


func _on_host_pressed() -> void:
	Ai.set_progress_bar(ai_health_bar)
	
	var err = peer.create_server(1027)
	if err != OK:
		host_ip_label.text = "Failed to create server"
		return
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	add_Player(multiplayer.get_unique_id())

	var ips = IP.get_local_addresses()
	var lan_ip = ""
	for ip in ips:
		if ip.find(":") == -1:   # IPv4 only
			if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172."):
				# Exclude Docker ranges: Docker usually uses 172.17.x.x and 172.18.x.x etc.
				if ip.begins_with("172.16.") or ip.begins_with("172.31."):
					lan_ip = ip
					break
				if !(ip.begins_with("172.17.") or ip.begins_with("172.18.")):
					lan_ip = ip
					break

	if lan_ip != "":
		host_ip_label.text = "Your LAN IP: " + lan_ip
	else:
		host_ip_label.text = "LAN IP not found"


	host_button.hide()
	join_button.hide()
	join_ip_input.hide()

	connected_players = 1  # Host counts as connected player
	_update_player_count()

func _on_join_pressed() -> void:
	Ai.set_progress_bar(ai_health_bar)
	var ip = join_ip_input.text.strip_edges()
	if ip == "":
		ip = "127.0.0.1"
	var err = peer.create_client(ip, 1027)
	if err != OK:
		host_ip_label.text = "Failed to connect"
		return
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	host_ip_label.text = "Connecting to: " + ip

	host_button.hide()
	join_button.hide()
	join_ip_input.hide()

func _on_peer_connected(id: int) -> void:
	connected_players += 1
	_update_player_count()
	add_Player(id)

func _on_peer_disconnected(id: int) -> void:
	connected_players = max(connected_players - 1, 0)
	_update_player_count()
	delete_Player(id)

func add_Player(id: int) -> void:
	if has_node(str(id)):
		return
	var player = playerScene.instantiate()
	player.name = str(id)
	add_child(player)
	player.global_position = Spawnpoint.global_position 
	print(player)

func delete_Player(id: int) -> void:
	var node_name = str(id)
	if has_node(node_name):
		get_node(node_name).queue_free()

func _on_start_pressed() -> void:
	canvas_layer.visible = false
	rpc("_set_game_started", true)
	_show_ai_health_bar()

func _show_ai_health_bar():
	if ai_health_bar:
		ai_health_bar.visible = true

@rpc("any_peer")
func _set_game_started(started: bool):
	if started:
		_show_ai_health_bar()
