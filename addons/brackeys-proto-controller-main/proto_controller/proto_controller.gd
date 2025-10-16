# ProtoController v1.0 by Brackeys (trimmed/fixed for multiplayer)
extends CharacterBody3D

@export_group("Camera")
@export var base_fov: float = 75.0
@export var sprint_fov: float = 85.0
@export var fov_change_speed: float = 6.0
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer
var current_animation: String = ""
@onready var particles: GPUParticles3D = $DustShader/GPUParticles3D
@onready var head: Node3D = $Model/Head
@onready var collider: CollisionShape3D = $Collider
@onready var cam: Camera3D = $Model/Head/Camera3D

@export var can_move : bool = true
@export var has_gravity : bool = true
@export var can_jump : bool = true
@export var can_sprint : bool = true
@export var can_freefly : bool = false
@export var movement_enabled: bool = false

@export_group("Speeds")
@export var look_speed : float = 0.002
@export var base_speed : float = 7.0
@export var jump_velocity : float = 4.5
@export var sprint_speed : float = 10.0
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"
@export var input_sprint : String = "sprint"
@export var input_freefly : String = "freefly"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

var active_block_count := 0
var ristrictMovement := false

const MAX_STEP_HEIGHT = 0.34
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor := -INF

var blockGameActive := false

# --- Quake (camera shake) state ---
var _shake_t: float = 0.0
var _shake_dur: float = 0.0
var _base_xform: Transform3D
var _pos_amp: float = 0.0       # meters
var _rot_amp: float = 0.0       # radians
var _freq: float = 0.0          # Hz-like
var _decay: float = 1.0         # >= 1.0
var _noise := FastNoiseLite.new()

# ❌ REMOVE this; it breaks host authority when name is "P_1" etc.
# func _enter_tree() -> void:
# 	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	# Particles off at start
	if particles:
		particles.emitting = false

	# Groups for lookup from cutscene/controller
	add_to_group("players")
	add_to_group("player")

	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

	# Ensure prefab never hijacks camera on other peers
	if cam:
		cam.current = false
		cam.add_to_group("player_cameras")

	# Quake baseline + noise config
	_base_xform = cam.transform
	_noise.seed = randi()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = 1.0

func _unhandled_input(event: InputEvent) -> void:
	# ✅ Local-only input
	if not is_multiplayer_authority():
		return

	if not movement_enabled:
		return

	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !blockGameActive:
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	if event.is_action_pressed("interact"):
		do_interact_animation()

	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

	# Toggle freefly
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	# ✅ Local-only movement
	if not is_multiplayer_authority():
		return

	if not movement_enabled:
		return

	if ristrictMovement:
		velocity.x = 0
		velocity.z = 0
		return

	update_animation()

	var target_fov: float = base_fov
	if can_sprint and Input.is_action_pressed(input_sprint):
		target_fov = sprint_fov
	var w: float = clamp(fov_change_speed * delta, 0.0, 1.0)
	if cam:
		cam.fov = lerp(cam.fov, target_fov, w)

	if is_on_floor():
		_last_frame_was_on_floor = Engine.get_physics_frames()

	checkForTerminal()

	# Freefly
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return

	# Gravity
	if has_gravity and not is_on_floor():
		velocity += get_gravity() * delta * 2.3

	# Jump
	if can_jump and Input.is_action_just_pressed(input_jump) and is_on_floor():
		velocity.y = jump_velocity

	# Sprint / base speed + FOV adjust already above
	move_speed = sprint_speed if (can_sprint and Input.is_action_pressed(input_sprint)) else base_speed

	# Movement
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0

	if not _snap_up_stairs_check(delta):
		move_and_slide()
		_snap_down_to_stairs_check()

func _process(delta: float) -> void:
	# Camera shake driver
	if _shake_t < _shake_dur:
		_shake_t += delta
		var t := _shake_t
		var norm := clamp(1.0 - (t / _shake_dur), 0.0, 1.0)
		var envelope := pow(norm, _decay)  # exponential falloff

		var n1 := _noise.get_noise_2d(t * _freq, 37.0)
		var n2 := _noise.get_noise_2d(91.0, t * _freq)
		var n3 := _noise.get_noise_2d(t * _freq * 0.77, 153.0)

		var pos_offset := Vector3(n1, n2, 0.0) * (_pos_amp * envelope)
		var rot_offset := Vector3(n2, n3, 0.0) * (_rot_amp * envelope)  # pitch,yaw,roll

		var basis := Basis()
		basis = basis.rotated(Vector3.RIGHT,  rot_offset.x)
		basis = basis.rotated(Vector3.UP,     rot_offset.y)
		basis = basis.rotated(Vector3.FORWARD,rot_offset.z)

		cam.transform = Transform3D(
			basis * _base_xform.basis,
			_base_xform.origin + pos_offset
		)
	elif _shake_dur > 0.0 and cam.transform != _base_xform:
		# snap back when finished
		cam.transform = _base_xform

func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction for " + input_left); can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction for " + input_right); can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction for " + input_forward); can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction for " + input_back); can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction for " + input_jump); can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction for " + input_sprint); can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction for " + input_freefly); can_freefly = false

func checkForTerminal():
	if get_tree().current_scene.has_node("Terminal") or get_tree().current_scene.has_node("SignalConsole"):
		ristrictMovement = true
		release_mouse()
	else:
		ristrictMovement = false

func is_surface_too_steep(normal:Vector3)-> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func _run_body_test_motion(from:Transform3D, motion:Vector3, result=null)->bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func play_animation(anim_name: String) -> void:
	if current_animation == anim_name: return
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
		current_animation = anim_name

func update_animation():
	if not is_on_floor():
		if velocity.y > 0.1:
			play_animation("Jump_Start")
		elif velocity.y < -0.1:
			play_animation("Jump_Land")
	else:
		var speed = Vector3(velocity.x, 0, velocity.z).length()
		if speed > sprint_speed * 0.7:
			play_animation("Jog_Fwd")
		elif speed > 0.1:
			play_animation("Walk")
		else:
			play_animation("Idle")

func do_interact_animation():
	play_animation("Interact")

# 🔹 Called by Map.gd only for the local player's instance
func make_camera_current_deferred() -> void:
	await get_tree().process_frame
	if cam:
		cam.current = false  # ensure clean
		cam.current = true
		var c := get_viewport().get_camera_3d()
		print("[Player] promoted camera; viewport has:", c, " path=", c and c.get_path())

@rpc("reliable", "call_local")
func set_movement_enabled(state: bool) -> void:
	movement_enabled = state
	if state:
		capture_mouse()
	else:
		release_mouse()
		velocity = Vector3.ZERO

# --- VFX hooks used by cutscene/controller RPCs -------------------------------

func set_particles_emitting(active: bool) -> void:
	if particles:
		particles.emitting = active

func start_quake(
	meters_amplitude: float = 0.03,
	seconds_duration: float = 1.5,
	frequency: float = 8.0,
	rot_radians_amplitude: float = 0.015,
	decay_power: float = 1.2
) -> void:
	_pos_amp = meters_amplitude
	_rot_amp = rot_radians_amplitude
	_freq = frequency
	_shake_dur = max(0.0001, seconds_duration)
	_decay = max(1.0, decay_power)
	_shake_t = 0.0
	_base_xform = cam.transform

# --- Stair snapping helpers ---------------------------------------------------

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	var was_on_floor_last_frame := Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	var floor_below: bool = %StairsBelowRayCast3D.is_colliding() and not is_surface_too_steep(%StairsBelowRayCast3D.get_collision_normal())
	if not is_on_floor() and velocity.y < 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result := PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
	_snapped_to_stairs_last_frame = did_snap

func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	if self.velocity.y > 0 or (self.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT: return false
		%StairsAheadRayCast3D.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		%StairsAheadRayCast3D.force_raycast_update()
		if %StairsAheadRayCast3D.is_colliding() and not is_surface_too_steep(%StairsAheadRayCast3D.get_collision_normal()):
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false
