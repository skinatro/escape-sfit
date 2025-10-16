# ReadyArea.gd
extends Area3D

@export var REQUIRED_COUNT: int = 4  # set as needed

# Path to your Game Over UI. Defaults to a sibling named "GameOver".
@onready var game_over: CanvasLayer = $"../GameOver"

# peer_id -> true (tracks unique players inside the area)
var _present: Dictionary = {}
var _announced: bool = false

var _game_over_node: Node

func _ready() -> void:
	# Cache the GameOver node (if present)

	# Ensure the Area is monitoring bodies
	monitoring = true
	monitorable = true

	# Wire signals (safe even if already connected)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	print("ReadyArea armed. Waiting for players...")

# -----------------------
# Signal handlers
# -----------------------
func _on_body_entered(body: Node) -> void:
	if not _is_server_safe():
		return

	var player := _get_player_root(body)
	if player == null:
		return

	# Avoid double-counting (multi-collider players)
	if not bool(player.get_meta("ready_area_inside", false)):
		player.set_meta("ready_area_inside", true)

		var pid: int = player.get_multiplayer_authority()
		_present[pid] = true

		# Clean up if the player despawns without firing body_exited
		if not player.tree_exited.is_connected(_on_player_tree_exited):
			player.tree_exited.connect(_on_player_tree_exited.bind(player), CONNECT_ONE_SHOT)

		print("Player ENTER:", player.name, " pid=", pid, " count=", _present.size())

		if not _announced and _present.size() >= REQUIRED_COUNT:
			print("All required players present. Announcing…")
			announce_hello_world.rpc()  # show on every peer locally

func _on_body_exited(body: Node) -> void:
	if not _is_server_safe():
		return

	var player := _get_player_root(body)
	if player == null:
		return

	if bool(player.get_meta("ready_area_inside", false)):
		player.set_meta("ready_area_inside", false)
		var pid: int = player.get_multiplayer_authority()
		_present.erase(pid)
		print("Player EXIT :", player.name, " pid=", pid, " count=", _present.size())

# Handles despawn/disconnect cases where body_exited may not fire
func _on_player_tree_exited(player: Node) -> void:
	# This can run during teardown; guard hard
	if not _is_server_safe():
		return
	if bool(player.get_meta("ready_area_inside", false)):
		player.set_meta("ready_area_inside", false)
		var pid: int = player.get_multiplayer_authority()
		_present.erase(pid)
		print("Player DESPAWN:", player.name, " pid=", pid, " count=", _present.size())

# -----------------------
# RPC
# -----------------------
@rpc("any_peer", "call_local", "reliable")
func announce_hello_world() -> void:
	if _announced:
		return
	_announced = true
	_show_game_over_ui()

# -----------------------
# Helpers
# -----------------------
func _get_player_root(n: Node) -> Node:
	# Walk up until we find a node in the "players" group
	var cur := n
	while cur:
		if cur.is_in_group("players"):
			return cur
		cur = cur.get_parent()
	return null

func _is_server_safe() -> bool:
	if not is_inside_tree():
		return false
	var tree: SceneTree = get_tree()
	if tree == null:
		return false
	var mp: MultiplayerAPI = tree.get_multiplayer()
	if mp == null:
		return false
	return mp.is_server()

func _show_game_over_ui() -> void:
	game_over.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	return
