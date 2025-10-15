#extends Area3D
#
#@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
#@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
#@export_group("LIFETIME")
#@export var life:=0.5 
#
#@export_group("RespawnPoint")
#@export var respawnPoint:Area3D
#
#@export_group("EMISSION DIRECTIONS (ONLY ONE)")
#@export var left := false
#@export var right := false
#@export var front := false
#@export var back := false
#
## === CONFIGURATION ===
#@export var leak_duration := 2.0      # seconds leak stays ON
#@export var pause_duration := 3.0     # seconds between leaks
#@export var max_amount := 200         # peak particle count
#@export var gravity_strength := 10.0  # max gravity in leak direction
#@export var smooth_speed := 5.0       # higher = faster fade
#
#var timer := 0.0
#var target_amount := 0
#var target_gravity := Vector3.ZERO
#
#func _ready() -> void:
	##gpu_particles_3d.lifetime=life
	#pass
	#
#func _process(delta: float) -> void:
	#timer += delta
	#
	## Determine phase
	#if timer <= leak_duration:
		#leakStart()
	#elif timer > leak_duration and timer <= leak_duration + pause_duration:
		#leakStop()
	#else:
		#timer = 0.0
	#
	## --- Smooth transitions ---
	## Gradually interpolate current values toward target values
	#var pm := gpu_particles_3d.process_material
	#pm.gravity = pm.gravity.lerp(target_gravity, delta * smooth_speed)
	#gpu_particles_3d.amount = lerp(gpu_particles_3d.amount, target_amount, int(delta * smooth_speed))
#
#
#func leakStart():
	#collision_shape_3d.disabled = false
	#target_amount = max_amount
#
	## Pick leak direction
	#if right:
		#target_gravity = Vector3(gravity_strength, 0, 0)
	#elif left:
		#target_gravity = Vector3(-gravity_strength, 0, 0)
	#elif front:
		#target_gravity = Vector3(0, 0, gravity_strength)
	#elif back:
		#target_gravity = Vector3(0, 0, -gravity_strength)
#
#
#func leakStop():
	#collision_shape_3d.disabled = true
	#target_amount = 0
	#target_gravity = Vector3.ZERO
#
#
#func _on_body_entered(body:CharacterBody3D) -> void:
	#print(body.name)
	#body.position=respawnPoint.position
	
extends Area3D

# === Nodes ===
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

# === LIFETIME ===
@export_group("LIFETIME")
@export var life: float = 0.5

# === Respawn Point ===
@export_group("RespawnPoint")
@export var respawnPoint: Node3D  # Assign a Node3D as respawn point per instance

# === Emission Directions (ONLY ONE) ===
@export_group("EMISSION DIRECTIONS (ONLY ONE)")
@export var left: bool = false
@export var right: bool = false
@export var front: bool = false
@export var back: bool = false

# === CONFIGURATION ===
@export var leak_duration: float = 2.0   # seconds leak stays ON
@export var pause_duration: float = 3.0  # seconds between leaks
@export var max_amount: int = 200        # peak particle count
@export var gravity_strength: float = 10.0  # max gravity in leak direction
@export var smooth_speed: float = 5.0    # higher = faster fade

# === INTERNAL VARIABLES ===
var timer: float = 0.0
var target_amount: float = 0
var target_gravity: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Connect signal to self
	self.body_entered.connect(_on_body_entered)
	# Disable collision initially
	collision_shape_3d.disabled = true
	# Set particle lifetime
	gpu_particles_3d.lifetime = life

func _process(delta: float) -> void:
	timer += delta

	# Determine leak phase
	if timer <= leak_duration:
		leakStart()
	elif timer <= leak_duration + pause_duration:
		leakStop()
	else:
		timer = 0.0

	# Smooth transitions
	var pm := gpu_particles_3d.process_material
	pm.gravity = pm.gravity.lerp(target_gravity, delta * smooth_speed)
	gpu_particles_3d.amount = lerp(float(gpu_particles_3d.amount), target_amount, delta * smooth_speed)

func leakStart() -> void:
	collision_shape_3d.disabled = false
	target_amount = max_amount

	# Pick leak direction
	if right:
		target_gravity = Vector3(gravity_strength, 0, 0)
	elif left:
		target_gravity = Vector3(-gravity_strength, 0, 0)
	elif front:
		target_gravity = Vector3(0, 0, gravity_strength)
	elif back:
		target_gravity = Vector3(0, 0, -gravity_strength)

func leakStop() -> void:
	collision_shape_3d.disabled = true
	target_amount = 0
	target_gravity = Vector3.ZERO

func _on_body_entered(body: CharacterBody3D) -> void:
	if respawnPoint:
		body.global_transform.origin = respawnPoint.global_transform.origin
