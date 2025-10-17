extends Node

@export var progress_bar: ProgressBar
var health: int = 100
var showBar := true
var tp=false
@onready var cutscene_camera: Camera3D = get_tree().root.get_node("Map/Cutscene")
@onready var anim_player: AnimationPlayer = get_tree().root.get_node("Map/Cutscene/AnimationPlayer")

func _ready() -> void:
	call_deferred("_assign_progress_bar")
	#ReduceHealth()
func _assign_progress_bar() -> void:
	var map_node = get_tree().root.get_node("Map")
	if map_node:
		progress_bar = map_node.get_node("AIHealth")  # Adjust if nested deeper inside Map
		if progress_bar and is_instance_valid(progress_bar):
			update_progress_bar()
		else:
			print("ProgressBar not found under Map node!")
	else:
		print("Map node not found at root!")

func set_progress_bar(bar: ProgressBar) -> void:
	progress_bar = bar
	update_progress_bar()

func update_progress_bar() -> void:
	if progress_bar and is_instance_valid(progress_bar):
		progress_bar.value = health
	else:
		print("Warning: progress_bar is null or invalid!")

# ------------------ Health / Cutscene ------------------

@rpc("authority")  # Clients call this -> server executes
func request_reduce_health() -> void:
	ReduceHealth()

func ReduceHealth() -> void:
	health -= 25
	rpc("sync_health", health)
	update_progress_bar()

	if health <= 0:
		play_cutscene()  # broadcast below

@rpc("any_peer")
func sync_health(new_health: int) -> void:
	health = new_health
	update_progress_bar()

# ------------------ Cutscene + VFX trigger ------------------

@rpc("any_peer")
func play_cutscene() -> void:
	print("--- CUTSCENE START ---")
	print(get_tree().root.get_children())
	# 🔶 Start dust + quake on every peer (local on each machine)
	_trigger_vfx_all(true)   # dust ON + quake start
	
	# Switch to cutscene camera and play animation
	cutscene_camera.current = true
	anim_player.play("ai_defeated")

	# Keep cutscene on for a moment (adjust as needed)
	await get_tree().create_timer(1.0).timeout

	# Return to player camera
	cutscene_camera.current = false
	var player_cam := find_camera_by_path_fragment("Head")  # Adjust if needed
	if player_cam:
		player_cam.current = true
		print("✅ Switched to player camera:", player_cam.get_path())
	else:
		print("❌ Player camera not found!")

	# Optional: stop particles after cutscene, or keep them on if you prefer
	_trigger_vfx_all(false)  # dust OFF (quake ends by itself)
	var bg_player := get_tree().root.get_node("AudioStreamPlayer")  # adjust path if needed
	if bg_player:
		if bg_player.playing:
			bg_player.stop()  # stop current track first
		bg_player.stream = load("res://music/gameduo.mp3")
		bg_player.volume_db = -4.0
		bg_player.play()
	# Reset your cutscene animation if desired
	anim_player.play("RESET")

# --- Utility: enumerate cameras ---

func get_all_cameras() -> Array:
	var cameras: Array = []
	var root = get_tree().current_scene
	if root:
		_find_cameras_recursive(root, cameras)
	return cameras

func _find_cameras_recursive(node: Node, cameras: Array) -> void:
	if node is Camera3D:
		cameras.append(node)
	for child in node.get_children():
		_find_cameras_recursive(child, cameras)

func find_camera_by_path_fragment(fragment: String) -> Camera3D:
	for cam in get_all_cameras():
		if fragment in str(cam.get_path()):
			return cam
	return null

# ========================== VFX (Dust + Quake) ==========================
# These helpers are network-safe and run locally on each peer.

# Server helper: broadcast VFX to everyone; clients ask server to broadcast
func _trigger_vfx_all(dust_active: bool) -> void:
	if multiplayer.is_server():
		_rpc_set_dust.rpc(dust_active)
		# Start a mild quake on all peers. Tune parameters if needed.
		_rpc_start_quake.rpc(0.03, 1.5, 8.0, 0.015, 1.2)
	else:
		rpc_id(1, "_rpc_set_dust", dust_active)
		rpc_id(1, "_rpc_start_quake", 0.03, 1.5, 8.0, 0.015, 1.2)

# Runs locally on every peer: toggles the"res://music/menu.mp3" local player's dust emission
@rpc("reliable", "call_local")
func _rpc_set_dust(active: bool) -> void:
	var player := _get_local_player()
	if player:
		if player.has_method("set_particles_emitting"):
			player.set_particles_emitting(active)
		else:
			# Fallback: try common path "DustShader/GPUParticles3D"
			var p := player.get_node_or_null("DustShader/GPUParticles3D")
			if p is GPUParticles3D:
				p.emitting = active

# Runs locally on every peer: starts a camera shake on their local player
@rpc("reliable", "call_local")
func _rpc_start_quake(
	meters_amplitude: float,
	seconds_duration: float,
	frequency: float,
	rot_radians_amplitude: float,
	decay_power: float
) -> void:
	var player := _get_local_player()
	if player and player.has_method("start_quake"):
		# Set infinite=True for continuous shaking
		player.start_quake(meters_amplitude, seconds_duration, frequency, rot_radians_amplitude, decay_power, true)
	

# Find the local player's node.
# Prefers group "player"; falls back to first CharacterBody3D with a camera under "Model/Head".
func _get_local_player() -> Node:
	# If your player joins "player" group (recommended), this resolves cleanly.
	var g := get_tree().get_nodes_in_group("player")
	if g.size() > 0:
		# If there are multiple (split-screen), you could refine by authority, but usually first is fine.
		return g[0]

	# Fallback heuristic: search current scene for a CharacterBody3D with a Head/Camera
	var root := get_tree().current_scene
	if not root:
		return null
	for n in root.get_children():
		if n is CharacterBody3D and (n as Node).has_node("Model/Head/Camera3D"):
			return n
	return null

#func _unhandled_input(event: InputEvent) -> void:
	#if(Input.is_key_pressed(KEY_0)):
		#ReduceHealth()
