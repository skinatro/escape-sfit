extends Area3D

const REQUIRED_COUNT := 2  # For 4 players
var _present: = {}         # player_id(string) -> true

func _ready() -> void:
	# Optional: connect signals if not connected in editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	print("ReadyArea is ready. Waiting for players...")

func _on_body_entered(body: Node) -> void:
	if not multiplayer.is_server():
		return
	var pid := _extract_player_id(body)
	if pid == "":
		print("Entered body is not a player:", body.name)
		return
	_present[pid] = true
	print("Player entered:", pid, "Current count:", _present.size())
	print("_present dict:", _present)
	if _present.size() == REQUIRED_COUNT:
		print("All players present! Announcing…")
		rpc("announce_hello_world")

func _on_body_exited(body: Node) -> void:
	if not multiplayer.is_server():
		return
	var pid := _extract_player_id(body)
	if pid == "":
		print("Exited body is not a player:", body.name)
		return
	_present.erase(pid)
	print("Player exited:", pid, "Current count:", _present.size())
	print("_present dict:", _present)

@rpc("any_peer", "call_local", "reliable")
func announce_hello_world() -> void:
	print("Quitting game now!")
	get_tree().quit()

func _extract_player_id(n: Node) -> String:
	var cur := n
	while cur:
		if _looks_like_player_name(cur.name):
			return String(cur.name)
		cur = cur.get_parent()
	return ""

func _looks_like_player_name(name: String) -> bool:
	for i in name.length():
		var c := name.unicode_at(i)
		if c < 0x30 or c > 0x39:
			return false
	return name.length() > 0
