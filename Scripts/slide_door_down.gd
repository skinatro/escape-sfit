extends CSGBox3D

var toggle_state := false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var door_cutscene: AnimationPlayer = $"../DoorCutscene"
@onready var cutscene_camera: Camera3D = $"../CutsceneCamera"
@onready var player_camera: Camera3D = $"../../PlayerController/Head/PlayerCamera"

func _on_door_toggle_body_entered(_body: Node3D) -> void:
	toggle_state = !toggle_state
	cutscene_camera.current = true

	door_cutscene.play("cutscene_cam_pre")
	await door_cutscene.animation_finished

	door_cutscene.play("cutscene_cam_peri")

	if toggle_state:
		animation_player.play("slide_open")
	else:
			animation_player.play("slide_close")
	await animation_player.animation_finished

	player_camera.current = true
