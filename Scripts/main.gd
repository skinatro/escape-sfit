#extends Node3D
#
#var peer := ENetMultiplayerPeer.new()
#
#@export var playerScene: PackedScene        # assign in Inspector
#@export var Spawnpoint: Node3D              # any Node3D/Area3D/Marker3D
#
#@onready var spawner: MultiplayerSpawner = $MultiplayerSpawner
#@onready var canvas_layer: CanvasLayer = $Hosting
#@onready var ai_health_bar: Control  = $AIHealth
#@onready var host_ip_label: Label    = canvas_layer.get_node("ShowIP")
#@onready var join_ip_input: LineEdit = canvas_layer.get_node("IP")
#@onready var host_button: Button     = canvas_layer.get_node("Host")
#@onready var join_button: Button     = canvas_layer.get_node("Join")
#@onready var player_count_label: Label = canvas_layer.get_node("Players")
#@onready var start_button: Button      = canvas_layer.get_node("Start")
#
#var _ids: PackedInt32Array = []        # host-only roster
#var connected_players := 0             # mirrored everywhere via RPC
#
#func _ready() -> void:
	#start_button.disabled = true
	#if ai_health_bar:
		#ai_health_bar.visible = false
#
	## Parent spawns under THIS manager node (..) — or change to a Players node you have.
	#spawner.spawn_path = NodePath("..")
	#spawner.spawn_function = Callable(self, "_spawn_player_from_data")
#
	#multiplayer.peer_connected.connect(_on_peer_connected)
	#multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	#multiplayer.connected_to_server.connect(_on_connected_to_server)
	#multiplayer.connection_failed.connect(_on_connection_failed)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)
#
	#host_button.pressed.connect(_on_host_pressed)
	#join_button.pressed.connect(_on_join_pressed)
	#start_button.pressed.connect(_on_start_pressed)
#
	## Optional: if you have any map/editor cameras left around, kill their "current"
	#_disable_non_player_cameras_except(null)
#
	#_update_player_count_ui()
#
## ---- MultiplayerSpawner factory (runs on ALL peers) ----
#func _spawn_player_from_data(data: Dictionary) -> Node:
	#var id := int(data.get("peer_id", 1))
	#var parent := spawner.get_node(spawner.spawn_path) as Node
	#if parent == null:
		#push_error("Spawner spawn_path invalid"); return null
	#if playerScene == null:
		#push_error("playerScene is null (assign it)"); return null
#
	#var name := str(id)
	#if parent.has_node(name):
		#return parent.get_node(name)
#
	#var p := playerScene.instantiate()
	#p.name = name
	#parent.add_child(p)                        # <-- parent under spawn_path
#
	## Network authority: the peer with 'id' owns this player
	#p.set_multiplayer_authority(id)
#
	## Always fetch relative to player (no absolute paths)
	#var sync := p.get_node_or_null("MultiplayerSynchronizer")
	#if sync:
		## Defer authority set one frame to avoid any replication race
		#call_deferred("_post_attach_sync_authority", sync, id)
#
	## Position with simple offset
	#if "global_position" in p:
		#p.global_position = _spawn_position_for(id)
#
	## CAMERA & INPUT LOCALITY (fixes camera switching)
	#_configure_player_locality(p)
#
	#return p                                    # <-- return the node
#
#func _post_attach_sync_authority(sync: MultiplayerSynchronizer, id: int) -> void:
	#if is_instance_valid(sync):
		#sync.set_multiplayer_authority(id)
		## Ensure the synchronizer root is "." in the Inspector and all property paths are relative.
#
#func _spawn_position_for(id: int) -> Vector3:
	#var base := Spawnpoint.global_position if Spawnpoint != null else global_transform.origin
	#var ids := _ids.duplicate(); ids.sort()
	#var idx = max(ids.find(id), 0)
	#return base + Vector3(2.5 * idx, 0.5, 0.0)
#
## ---- Host / Join ----
#func _on_host_pressed() -> void:
	#var err := peer.create_server(1027)
	#if err != OK:
		#host_ip_label.text = "Failed to create server"; return
	#multiplayer.multiplayer_peer = peer
#
	#_server_add(multiplayer.get_unique_id())
	#_server_broadcast_count()
	#spawner.spawn({ "peer_id": multiplayer.get_unique_id() })   # HOST ONLY
#
	#_show_lan_ip()
	#host_button.hide(); join_button.hide(); join_ip_input.hide()
#
#func _on_join_pressed() -> void:
	#var ip := join_ip_input.text.strip_edges()
	#if ip == "": ip = "127.0.0.1"
	#var err := peer.create_client(ip, 1027)
	#if err != OK:
		#host_ip_label.text = "Failed to connect"; return
	#multiplayer.multiplayer_peer = peer
	#host_ip_label.text = "Connecting to: " + ip
	#host_button.hide(); join_button.hide(); join_ip_input.hide()
#
## ---- Multiplayer callbacks ----
#func _on_connected_to_server() -> void:
	## This node defines the RPC below, so calling here is valid.
	#rpc_id(1, "_rpc_request_spawn", multiplayer.get_unique_id())
#
#func _on_connection_failed() -> void:
	#host_ip_label.text = "Connection failed"
	#host_button.show(); join_button.show(); join_ip_input.show()
#
#func _on_server_disconnected() -> void:
	#host_ip_label.text = "Disconnected from server"
	#start_button.disabled = true
#
#func _on_peer_connected(id: int) -> void:
	#if multiplayer.is_server():
		#_server_add(id)
		#_server_broadcast_count()
		#spawner.spawn({ "peer_id": id })        # HOST ONLY
#
#func _on_peer_disconnected(id: int) -> void:
	#if multiplayer.is_server():
		#_server_remove(id)
		#_server_broadcast_count()
		#var n := get_node_or_null(str(id))
		#if n: spawner.despawn(n)                # HOST ONLY
#
## ---- Server helpers ----
#func _server_add(id: int) -> void:
	#if not _ids.has(id): _ids.append(id)
#
#func _server_remove(id: int) -> void:
	#if _ids.has(id): _ids.erase(id)
#
#func _server_broadcast_count() -> void:
	#rpc("_rpc_set_player_count", _ids.size())
#
## ---- RPCs ----
#@rpc("authority")
#func _rpc_request_spawn(id: int) -> void:
	#if not multiplayer.is_server(): return
	#_server_add(id)
	#_server_broadcast_count()
	#spawner.spawn({ "peer_id": id })           # HOST ONLY; mirrors to all peers
#
#@rpc("any_peer", "reliable", "call_local")
#func _rpc_set_player_count(count: int) -> void:
	#connected_players = count
	#_update_player_count_ui()
#
## ---- UI / Start ----
#func _update_player_count_ui() -> void:
	#player_count_label.text = "Players: %d" % connected_players
	#start_button.disabled = not (multiplayer.is_server() and connected_players >= 2)
#
#func _on_start_pressed() -> void:
	#if multiplayer.is_server():
		#rpc("_rpc_game_started", true)
		#start_print_fn()
#
#@rpc("any_peer", "reliable", "call_local")
#func _rpc_game_started(started: bool) -> void:
	#if started:
		#if is_instance_valid(canvas_layer): canvas_layer.visible = false
		#if ai_health_bar: ai_health_bar.visible = true
#
## ---- Camera & locality helpers ----
#func _configure_player_locality(p: Node) -> void:
	#var is_local := p.is_multiplayer_authority()
#
	## Find the first Camera3D inside the player (direct or nested)
	#var cam := _find_first_camera(p)
	#if cam:
		#cam.current = false
		#if is_local:
			#cam.make_current()
#
#
#
	## Only the local player should process input/physics on this peer
	#if "set_process_input" in p:
		#p.set_process_input(is_local)
	#if "set_physics_process" in p:
		#p.set_physics_process(is_local)
#
	## Extra guard: ensure no stray non-player cameras are current here
	#if is_local:
		#_disable_non_player_cameras_except(cam)
#
#func _find_first_camera(n: Node) -> Camera3D:
	#if n is Camera3D:
		#return n as Camera3D
	#for c in n.get_children():
		#var found := _find_first_camera(c)
		#if found: return found
	#return null
#
#func _disable_non_player_cameras_except(keep: Camera3D) -> void:
	#var root := get_tree().current_scene
	#if root == null: return
	#_disable_cameras_recursive(root, keep)
#
#func _disable_cameras_recursive(node: Node, keep: Camera3D) -> void:
	#if node is Camera3D and node != keep:
		#(node as Camera3D).current = false
	#for child in node.get_children():
		#_disable_cameras_recursive(child, keep)
#
## ---- Misc ----
#func _show_lan_ip() -> void:
	#var ip := ""
	#for a in IP.get_local_addresses():
		#if a.find(":") != -1: continue
		#if a.begins_with("10.") or a.begins_with("192.168."): ip = a; break
		#if a.begins_with("172."):
			#if a.begins_with("172.17.") or a.begins_with("172.18."): continue
			#var o2 := int(a.split(".")[1]); if o2 >= 16 and o2 <= 31: ip = a; break
	#if ip != "":
		#host_ip_label.text = "Your LAN IP: " + ip
	#else:
		#host_ip_label.text = "LAN IP not found"
#
#@rpc("any_peer")
#func start_print_fn():
	#print("Shaun Free Hai")
	#var player_cam = find_camera_by_path_fragment("/Head")
	#if player_cam:
		#player_cam.current = true
#
## 🔍 Utility: Print all cameras
#func print_all_cameras() -> void:
	#var cameras = get_all_cameras()
	#print("---- All Cameras in Scene ----")
	#for cam in cameras:
		#print(cam.get_path())
	#print("------------------------------")
#
## 🔍 Utility: Get all cameras recursively
#func get_all_cameras() -> Array:
	#var cameras: Array = []
	#var root = get_tree().current_scene
	#if root:
		#_find_cameras_recursive(root, cameras)
	#return cameras
#
## Recursive helper
#func _find_cameras_recursive(node: Node, cameras: Array) -> void:
	#if node is Camera3D:
		#cameras.append(node)
	#for child in node.get_children():
		#_find_cameras_recursive(child, cameras)
#
#func find_camera_by_path_fragment(fragment: String) -> Camera3D:
	#for cam in get_all_cameras():
		#if fragment in str(cam.get_path()):
			#return cam
	#return null












#
#extends Node3D
#
#var peer := ENetMultiplayerPeer.new()
#@export var playerScene: PackedScene
#@export var Spawnpoint: Area3D
#@onready var canvas_layer: CanvasLayer = $Hosting
#@onready var ai_health_bar = $AIHealth
#@onready var host_ip_label = canvas_layer.get_node("ShowIP")
#@onready var join_ip_input = canvas_layer.get_node("IP")
#@onready var host_button = canvas_layer.get_node("Host")
#@onready var join_button = canvas_layer.get_node("Join")
#@onready var player_count_label = canvas_layer.get_node("Players")
#@onready var start_button = canvas_layer.get_node("Start")
#
#var connected_players := 0
#
#func _ready():
	#start_button.disabled = true  
	#if ai_health_bar:
		#ai_health_bar.visible = false 
#
#func _update_player_count():
	#player_count_label.text = "Players: %d" % connected_players
	## Enable start if host and 4 or more players joined
	#if multiplayer.get_unique_id() == 1 and connected_players >= 2: #change to 4 during actual game
		#start_button.disabled = false
	#else:
		#start_button.disabled = true
#
#
#func _on_host_pressed() -> void:
	#Ai.set_progress_bar(ai_health_bar)
	#
	#var err = peer.create_server(1027)
	#if err != OK:
		#host_ip_label.text = "Failed to create server"
		#return
	#multiplayer.multiplayer_peer = peer
#
	#multiplayer.peer_connected.connect(_on_peer_connected)
	#multiplayer.peer_disconnected.connect(_on_peer_disconnected)
#
	#add_Player(multiplayer.get_unique_id())
#
	#var ips = IP.get_local_addresses()
	#var lan_ip = ""
	#for ip in ips:
		#if ip.find(":") == -1:   # IPv4 only
			#if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172."):
				## Exclude Docker ranges: Docker usually uses 172.17.x.x and 172.18.x.x etc.
				#if ip.begins_with("172.16.") or ip.begins_with("172.31."):
					#lan_ip = ip
					#break
				#if !(ip.begins_with("172.17.") or ip.begins_with("172.18.")):
					#lan_ip = ip
					#break
#
	#if lan_ip != "":
		#host_ip_label.text = "Your LAN IP: " + lan_ip
	#else:
		#host_ip_label.text = "LAN IP not found"
#
#
	#host_button.hide()
	#join_button.hide()
	#join_ip_input.hide()
#
	#connected_players = 1  # Host counts as connected player
	#_update_player_count()
#
#func _on_join_pressed() -> void:
	#Ai.set_progress_bar(ai_health_bar)
	#var ip = join_ip_input.text.strip_edges()
	#if ip == "":
		#ip = "127.0.0.1"
	#var err = peer.create_client(ip, 1027)
	#if err != OK:
		#host_ip_label.text = "Failed to connect"
		#return
	#multiplayer.multiplayer_peer = peer
#
	#multiplayer.peer_connected.connect(_on_peer_connected)
	#multiplayer.peer_disconnected.connect(_on_peer_disconnected)
#
	#host_ip_label.text = "Connecting to: " + ip
#
	#host_button.hide()
	#join_button.hide()
	#join_ip_input.hide()
#
#func _on_peer_connected(id: int) -> void:
	#connected_players += 1
	#_update_player_count()
	#add_Player(id)
#
#func _on_peer_disconnected(id: int) -> void:
	#connected_players = max(connected_players - 1, 0)
	#_update_player_count()
	#delete_Player(id)
#
#func add_Player(id: int) -> void:
	#if has_node(str(id)):
		#return
	#var player = playerScene.instantiate()
	#player.name = str(id)
	#add_child(player)
	#player.global_position = Spawnpoint.global_position 
#
#
#func delete_Player(id: int) -> void:
	#var node_name = str(id)
	#if has_node(node_name):
		#get_node(node_name).queue_free()
#
#func _on_start_pressed() -> void:
	#canvas_layer.visible = false
	#rpc("_set_game_started", true)
	#_show_ai_health_bar()
	#StartButton()
#
#func _show_ai_health_bar():
	#if ai_health_bar:
		#ai_health_bar.visible = true
#
#@rpc("any_peer")
#func _set_game_started(started: bool):
	#if started:
		#_show_ai_health_bar()
#
#@rpc("any_peer")
#func StartButton():
	#var player_cam =find_camera_by_path_fragment("/Head")
	##print(player_cam.get_path())
	#if player_cam:
		#player_cam.current = true
		#
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
	
	
extends Node3D

var peer := ENetMultiplayerPeer.new()

@export var playerScene: PackedScene
@export var Spawnpoint: Node3D

@onready var canvas_layer: CanvasLayer = $Hosting
@onready var ai_health_bar: Control = $AIHealth
@onready var host_ip_label: Label = canvas_layer.get_node("ShowIP")
@onready var join_ip_input: LineEdit = canvas_layer.get_node("IP")
@onready var host_button: Button = canvas_layer.get_node("Host")
@onready var join_button: Button = canvas_layer.get_node("Join")
@onready var player_count_label: Label = canvas_layer.get_node("Players")
@onready var start_button: Button = canvas_layer.get_node("Start")

var connected_players: int = 0
var player_nodes := {} # peer_id -> player node

func _ready():
	start_button.disabled = true
	if ai_health_bar:
		ai_health_bar.visible = false

	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	start_button.pressed.connect(_on_start_pressed)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


# ------------------------
# UI helpers
# ------------------------
func _update_player_count():
	player_count_label.text = "Players: %d" % connected_players
	start_button.disabled = not (multiplayer.is_server() and connected_players >= 2)


func _show_lan_ip():
	var lan_ip := ""
	for ip in IP.get_local_addresses():
		if ip.find(":") != -1:
			continue
		if ip.begins_with("192.168.") or ip.begins_with("10."):
			lan_ip = ip; break
		if ip.begins_with("172."):
			var o2 := int(ip.split(".")[1])
			if o2 >= 16 and o2 <= 31:
				lan_ip = ip; break
	host_ip_label.text = "LAN IP: " + (lan_ip if lan_ip != "" else "Not found")


# ------------------------
# Host / Join
# ------------------------
func _on_host_pressed():
	var err := peer.create_server(1027)
	if err != OK:
		host_ip_label.text = "Failed to create server"
		return
	multiplayer.multiplayer_peer = peer
	var my_id = multiplayer.get_unique_id()
	_spawn_player(my_id)
	connected_players = 1
	_update_player_count()
	_show_lan_ip()
	host_button.hide()
	join_button.hide()
	join_ip_input.hide()


func _on_join_pressed():
	var ip = join_ip_input.text.strip_edges()
	if ip == "": ip = "127.0.0.1"
	var err = peer.create_client(ip, 1027)
	if err != OK:
		host_ip_label.text = "Failed to connect"
		return
	multiplayer.multiplayer_peer = peer
	host_ip_label.text = "Connecting: " + ip
	host_button.hide()
	join_button.hide()
	join_ip_input.hide()
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_connected_to_server():
	host_ip_label.text = "Connected!"
	rpc_id(1, "_rpc_request_spawn", multiplayer.get_unique_id())


# ------------------------
# Multiplayer callbacks
# ------------------------
func _on_peer_connected(id: int):
	if multiplayer.is_server():
		connected_players += 1
		rpc("_rpc_set_player_count", connected_players)
		_update_player_count()
		_spawn_player(id)


func _on_peer_disconnected(id: int):
	if multiplayer.is_server():
		connected_players = max(connected_players - 1, 0)
		rpc("_rpc_set_player_count", connected_players)
		_update_player_count()
		_despawn_player(id)


# ------------------------
# RPCs
# ------------------------
@rpc("any_peer", "reliable")
func _rpc_request_spawn(id: int):
	if multiplayer.is_server():
		_spawn_player(id)


@rpc("any_peer", "reliable", "call_local")
func _rpc_set_player_count(n: int):
	connected_players = n
	_update_player_count()


# ------------------------
# Spawning & despawning
# ------------------------
func _spawn_player(id: int):
	if player_nodes.has(id):
		return
	var player = playerScene.instantiate()
	player.name = str(id)
	player_nodes[id] = player
	add_child(player)
	
	var base = Spawnpoint.global_position if Spawnpoint else global_transform.origin
	var offset = Vector3((player_nodes.size()-1)*2.5, 0, 0)
	player.global_position = base + offset

	var sync = player.get_node_or_null("MultiplayerSynchronizer")
	if sync:
		call_deferred("_set_player_authority", sync, id)

	_configure_local_camera(player)


func _despawn_player(id: int):
	if not player_nodes.has(id):
		return
	player_nodes[id].queue_free()
	player_nodes.erase(id)


# ------------------------
# Camera & input
# ------------------------
func _configure_local_camera(player: Node):
	var cam = _find_camera(player)
	if cam:
		cam.current = false
		if player.is_multiplayer_authority():
			cam.make_current()

	# Only allow input for local player
	if player.has_method("set_process_input"):
		player.set_process_input(player.is_multiplayer_authority())
	if player.has_method("set_physics_process"):
		player.set_physics_process(player.is_multiplayer_authority())


func _find_camera(node: Node) -> Camera3D:
	if node is Camera3D: return node
	for c in node.get_children():
		var found = _find_camera(c)
		if found: return found
	return null


# ------------------------
# Game start
# ------------------------
func _on_start_pressed():
	if multiplayer.is_server():
		rpc("_rpc_game_started", true)
		_game_started()


@rpc("any_peer", "reliable", "call_local")
func _rpc_game_started(started: bool):
	if started:
		_game_started()


func _game_started():
	canvas_layer.visible = false
	if ai_health_bar: ai_health_bar.visible = true
	var me = get_node_or_null(str(multiplayer.get_unique_id()))
	if me:
		var cam = _find_camera(me)
		if cam: cam.make_current()
