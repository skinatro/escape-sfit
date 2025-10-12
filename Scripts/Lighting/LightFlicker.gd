extends SpotLight3D

@onready var tube: CSGBox3D = $"../Sketchfab_Scene/Sketchfab_model/root/GLTF_SceneRootNode/Cube_005_3/tube"

func _ready():
	# Duplicate the material so this tube has its own instance
	if tube.material:
		tube.material = tube.material.duplicate()
	
	# Start flickering
	flash()


func flash():
	var rand_intensity = randf_range(0.2, 1.0)
	
	# Light flicker
	light_energy = rand_intensity * 3.0
	
	# Tube emissive flicker
	if tube.material and tube.material is StandardMaterial3D:
		var mat: StandardMaterial3D = tube.material
		mat.emission_enabled = true
		mat.emission = Color(1, 1, 0.8) * rand_intensity  # warm glow
		mat.emission_energy_multiplier = rand_intensity * 2.0
	
	await get_tree().create_timer(randf_range(0.05, 0.1)).timeout
	flash()
