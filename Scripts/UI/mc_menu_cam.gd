extends Node3D

@onready var camera_3d: Camera3D = $Camera3D
var rotation_speed = 25

func _process(delta: float) -> void:
	camera_3d.rotation.y += delta * deg_to_rad(rotation_speed)
