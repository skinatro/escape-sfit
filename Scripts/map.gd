extends Node3D

const DEFAULT_PORT: int = 42069
const MAX_CLIENTS: int = 4

@export var player_scene: PackedScene
@export var min_players_to_start: int = 0

# --- UI (adjust paths to match your scene) ---
@onready var host_mnu: CanvasLayer = $Hosting
@onready var host_btn: Button     = $Hosting/Host
@onready var join_btn: Button     = $Hosting/Join
@onready var start_btn: Button    = $Hosting/Start
@onready var ip_edit: LineEdit    = $Hosting/IP
@onready var host_label: Label    = $Hosting/ShowIP
@onready var players_label: Label = $Hosting/Players
@onready var game_over: CanvasLayer = $GameOver
@onready var video_cutscene: CanvasLayer = $CutsceneVideo
@onready var video_cutscene_player: VideoStreamPlayer = $CutsceneVideo/VideoStreamPlayer

#Set Menu Cam
@onready var wanted_cam: Camera3D = $Menu

# --- Scene anchors ---
@onready var players_root: Node3D = $Players
@onready var spawn_area: Area3D   = (get_node_or_null("Gamespawn") as Area3D)

var _enet := ENetMultiplayerPeer.new()


# Connected peers known to this instance (id -> true)
var _connected_ids: Dictionary = {}
# Remember spawn positions to resync late joiners (id -> Vector3)
var _spawn_pos: Dictionary = {}

func _ready() -> void:
	start_btn.disabled = true
	wanted_cam.current = true
	# Wire UI signals safely (avoid duplicate connects)
	if host_btn and not host_btn.pressed.is_connected(_on_host_pressed):
		host_btn.pressed.connect(_on_host_pressed)
	if join_btn and not join_btn.pressed.is_connected(_on_join_pressed):
		join_btn.pressed.connect(_on_join_pressed)
	if start_btn and not start_btn.pressed.is_connected(_on_start_pressed):
		start_btn.pressed.connect(_on_start_pressed)

	# Multiplayer signals (guarded)
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if not multiplayer.connected_to_server.is_connected(_on_connected_ok):
		multiplayer.connected_to_server.connect(_on_connected_ok)
	if not multiplayer.connection_failed.is_connected(_on_connected_fail):
		multiplayer.connection_failed.connect(_on_connected_fail)
	if not multiplayer.server_disconnected.is_connected(_on_server_drop):
		multiplayer.server_disconnected.connect(_on_server_drop)

	video_cutscene.visible = false
	host_label.text = "Not host"
	start_btn.disabled = true
	_update_player_count()
	
	game_over.visible = false

# ---------------------------
# Hosting / Joining
# ---------------------------
func _on_host_pressed() -> void:
	var err := _enet.create_server(DEFAULT_PORT, MAX_CLIENTS)
	if err != OK:
		push_error("Server create failed: %s" % err)
		return

	multiplayer.multiplayer_peer = _enet
	_connected_ids.clear()
	_connected_ids[multiplayer.get_unique_id()] = true
	_update_player_count()

	var ips := IP.get_local_addresses()
	var ip_text := get_ipv4_address()
	host_label.text = "Host: %s:%d" % [ip_text, DEFAULT_PORT]

	_connected_ids[1] = true
	_update_player_count()

	# Let tree settle before first spawn (prevents race conditions)
	await get_tree().process_frame
	_server_spawn_for(multiplayer.get_unique_id())

func _on_join_pressed() -> void:
	var ip := ip_edit.text.strip_edges()
	if ip.is_empty():
		push_warning("Enter IP")
		return

	var err := _enet.create_client(ip, DEFAULT_PORT)
	if err != OK:
		push_error("Client create failed: %s" % err)
		return

	multiplayer.multiplayer_peer = _enet
	host_label.text = "Client: connecting…"

func _on_connected_ok() -> void:
	host_label.text = "Client: connected (id %d)" % multiplayer.get_unique_id()
	# Ask server to spawn us
	_request_spawn.rpc_id(1, multiplayer.get_unique_id())

func _on_connected_fail() -> void:
	host_label.text = "Client: connection failed"

func _on_server_drop() -> void:
	host_label.text = "Disconnected from server"
	_cleanup_all_players()

# ---------------------------
# Connection bookkeeping
# ---------------------------
func _on_peer_connected(id: int) -> void:
	_connected_ids[id] = true
	_update_player_count()

	if multiplayer.is_server():
		# 1) Inform newcomer about all existing players
		for existing_id in _connected_ids.keys():
			if existing_id == id:
				continue
			var pos: Vector3 = _spawn_pos.get(existing_id, _find_existing_player_pos(existing_id))
			_spawn_player_all.rpc_id(id, existing_id, pos)  # send only to newcomer

		# 2) Spawn newcomer for everyone
		_server_spawn_for(id)

func _on_peer_disconnected(id: int) -> void:
	_connected_ids.erase(id)
	_spawn_pos.erase(id)
	_update_player_count()
	_despawn_player_everywhere(id)

func _update_player_count() -> void:
	if players_label:
		players_label.text = "Players: %d" % _connected_ids.size()
	start_btn.disabled = !multiplayer.is_server() or _connected_ids.size() < min_players_to_start

# ---------------------------
# Spawning
# ---------------------------

# Client -> Server: please spawn me
@rpc("reliable", "any_peer")
func _request_spawn(peer_id: int) -> void:
	if !multiplayer.is_server():
		return
	_server_spawn_for(peer_id)

func _server_spawn_for(peer_id: int) -> void:
	var pos := _choose_spawn_position()
	_spawn_pos[peer_id] = pos
	_spawn_player_all.rpc(peer_id, pos)  # broadcast to all peers

# All peers create the same player subtree
@rpc("reliable", "call_local")
func _spawn_player_all(peer_id: int, pos: Vector3) -> void:
	if players_root == null:
		await get_tree().process_frame

	var name := "P_%d" % peer_id
	if players_root.has_node(name):
		return

	var p := player_scene.instantiate()
	p.name = name
	p.set_multiplayer_authority(peer_id)
	players_root.add_child(p, true)     # ensure in-tree first
	(p as Node3D).global_position = pos # then set world position

	if peer_id == multiplayer.get_unique_id():
		# promote *local* player's camera after the node is fully alive
		p.call_deferred("make_camera_current_deferred")

func _despawn_player_everywhere(leaver_id: int) -> void:
	_despawn_player_all.rpc(leaver_id)

@rpc("reliable", "call_local")
func _despawn_player_all(leaver_id: int) -> void:
	var name := "P_%d" % leaver_id
	if players_root.has_node(name):
		players_root.get_node(name).queue_free()

func _cleanup_all_players() -> void:
	for c in players_root.get_children():
		c.queue_free()
	_connected_ids.clear()
	_spawn_pos.clear()
	_update_player_count()

func _choose_spawn_position() -> Vector3:
	# Single spawn area: use its origin; fallback to map origin if missing
	if spawn_area:
		return spawn_area.global_transform.origin
	return global_transform.origin

func _find_existing_player_pos(peer_id: int) -> Vector3:
	var name := "P_%d" % peer_id
	if players_root and players_root.has_node(name):
		return (players_root.get_node(name) as Node3D).global_position
	return _choose_spawn_position()

# ---------------------------
# Start button (gate to your game)
# ---------------------------
func _on_start_pressed() -> void:
	if !multiplayer.is_server():
		return
	_game_start_all.rpc()
	_enable_movement_locally.rpc() 

@rpc("reliable", "call_local")
func _game_start_all() -> void:
	host_mnu.visible = false

func get_ipv4_address() -> String:
	var ipv4_candidates: Array[String] = []

	for ip in IP.get_local_addresses():
		# Skip anything that's not IPv4
		if ":" in ip:
			continue
		# Skip loopback, link-local, and "0.0.0.0"
		if ip.begins_with("127.") or ip.begins_with("169.254.") or ip == "0.0.0.0":
			continue
		ipv4_candidates.append(ip)

	# Prefer private networks (RFC1918)
	for ip in ipv4_candidates:
		if ip.begins_with("192.168.") or ip.begins_with("10.") or (ip.begins_with("172.") and _is_private_172(ip)):
			return ip

	# If nothing found, return first IPv4 or "unknown"
	return ipv4_candidates[0] if ipv4_candidates.size() > 0 else "unknown"

func _is_private_172(ip: String) -> bool:
	var parts := ip.split(".")
	if parts.size() < 2:
		return false
	var second_octet: int = int(parts[1])
	return second_octet >= 16 and second_octet <= 31

@rpc("reliable", "call_local")
func _enable_movement_locally() -> void:
	for p in players_root.get_children():
		if p.has_method("set_multiplayer_authority") and p.get_multiplayer_authority() == 0:
			# ignore stray nodes; not required, just defensive
			pass
		if p.has_method("set_movement_enabled"):
			p.set_movement_enabled(true)
				
