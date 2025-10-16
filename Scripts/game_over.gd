# ReadyArea.gd — attach to your Area3D
extends Area3D

const REQUIRED_COUNT := 1
var _present: = {}   # player_id(string) -> true

func _ready() -> void:
	# Ensure signals are connected (or wire in editor)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	# Server is the single source of truth
	if not multiplayer.is_server():
		return
	var pid := _extract_player_id(body)
	if pid == "":
		return
	_present[pid] = true
	if _present.size() == REQUIRED_COUNT:
		# Tell all peers (and self) reliably
		rpc("announce_hello_world")

func _on_body_exited(body: Node) -> void:
	if not multiplayer.is_server():
		return
	var pid := _extract_player_id(body)
	if pid == "":
		return
	_present.erase(pid)

@rpc("any_peer", "call_local", "reliable")
func announce_hello_world() -> void:
	print("helloworld")

func _extract_player_id(n: Node) -> String:
	# Your spawner names players "1","2","3"... at the scene root
	# Colliders are usually children; climb up to the player node.
	var cur := n
	while cur:
		if _looks_like_player_name(cur.name):
			return String(cur.name)
		cur = cur.get_parent()
	return ""

func _looks_like_player_name(name: String) -> bool:
	# Accept purely numeric names (e.g., "1", "23")
	for i in name.length():
		var c := name.unicode_at(i)
		if c < 0x30 or c > 0x39:
			return false
	return name.length() > 0
