extends StaticBody3D

var toggle := false
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func interact():
	toggle = !toggle
	if toggle:
		animation_player.play("door_open")
	else:
		animation_player.play("door_close")
