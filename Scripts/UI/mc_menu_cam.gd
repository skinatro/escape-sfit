extends Node3D

@onready var menu_cam: Camera3D = $MenuCam
var rotation_speed = 25

func _process(delta: float) -> void:
	menu_cam.rotation.y += delta * deg_to_rad(rotation_speed)

func _ready() -> void:
	menu_cam.current = true
