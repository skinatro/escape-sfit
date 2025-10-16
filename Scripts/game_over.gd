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


#extends Area3D
#
#const REQUIRED_COUNT := 2   # set to 4 for your game
#
#var _present_count: int = 0
#
#func _ready() -> void:
	## Ensure signals are connected (if not wired in the editor)
	#if not body_entered.is_connected(_on_body_entered):
		#body_entered.connect(_on_body_entered)
	#if not body_exited.is_connected(_on_body_exited):
		#body_exited.connect(_on_body_exited)
	#print("ReadyArea armed. Waiting for players...")
#
#func _on_body_entered(body: Node) -> void:
	#if not multiplayer.is_server():
		#return
	#var player := _get_player_root(body)
	#if player == null:
		#return
#
	## Use a meta flag on the player root to avoid double counting
	#if not player.has_meta("ready_area_inside") or not bool(player.get_meta("ready_area_inside")):
		#player.set_meta("ready_area_inside", true)
		#_present_count += 1
		## If the player despawns without firing body_exited, clean up
		#if not player.tree_exited.is_connected(_on_player_tree_exited):
			#player.tree_exited.connect(_on_player_tree_exited.bind(player))
		#print("Player ENTER:", player.name, " count=", _present_count)
		#if _present_count >= REQUIRED_COUNT:
			#rpc("announce_hello_world")
#
#func _on_body_exited(body: Node) -> void:
	#if not multiplayer.is_server():
		#return
	#var player := _get_player_root(body)
	#if player == null:
		#return
#
	#if player.has_meta("ready_area_inside") and bool(player.get_meta("ready_area_inside")):
		#player.set_meta("ready_area_inside", false)
		#_present_count = max(_present_count - 1, 0)
		#print("Player EXIT :", player.name, " count=", _present_count)
#
#func _on_player_tree_exited(player: Node) -> void:
	## Handles despawn/disconnect cases where body_exited may not fire
	#if not multiplayer.is_server():
		#return
	#if player.has_meta("ready_area_inside") and bool(player.get_meta("ready_area_inside")):
		#player.set_meta("ready_area_inside", false)
		#_present_count = max(_present_count - 1, 0)
		#print("Player DESPAWN:", player.name, " count=", _present_count)
#
#@rpc("any_peer", "call_local", "reliable")
#func announce_hello_world() -> void:
	#print("All required players present. Quitting game now!")
	#get_tree().quit()
#
## ----- helpers -----
#
#func _get_player_root(n: Node) -> Node:
	#var cur := n
	#while cur:
		#if _is_player_name_numeric(cur.name):
			#return cur
		#cur = cur.get_parent()
	#return null
#
#func _is_player_name_numeric(name: String) -> bool:
	#if name.is_empty():
		#return false
	#for i in name.length():
		#var c := name.unicode_at(i)
		#if c < 0x30 or c > 0x39: # not '0'..'9'
			#return false
	#return true
