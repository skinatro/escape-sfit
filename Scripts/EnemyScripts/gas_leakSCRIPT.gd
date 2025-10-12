extends Area3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export_group("EMISSION DIRECTIONS (ONLY ONE)")
@export var left := false
@export var right := false
@export var front := false
@export var back := false

# === CONFIGURATION ===
@export var leak_duration := 2.0      # seconds leak stays ON
@export var pause_duration := 3.0     # seconds between leaks
@export var max_amount := 200         # peak particle count
@export var gravity_strength := 10.0  # max gravity in leak direction
@export var smooth_speed := 5.0       # higher = faster fade

var timer := 0.0
var target_amount := 0
var target_gravity := Vector3.ZERO

func _process(delta: float) -> void:
	timer += delta
	
	# Determine phase
	if timer <= leak_duration:
		leakStart()
	elif timer > leak_duration and timer <= leak_duration + pause_duration:
		leakStop()
	else:
		timer = 0.0
	
	# --- Smooth transitions ---
	# Gradually interpolate current values toward target values
	var pm := gpu_particles_3d.process_material
	pm.gravity = pm.gravity.lerp(target_gravity, delta * smooth_speed)
	gpu_particles_3d.amount = lerp(gpu_particles_3d.amount, target_amount, int(delta * smooth_speed))


func leakStart():
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


func leakStop():
	collision_shape_3d.disabled = true
	target_amount = 0
	target_gravity = Vector3.ZERO


func _on_body_entered(body:CharacterBody3D) -> void:
	print(body.name)
	#body.position.z-=10
