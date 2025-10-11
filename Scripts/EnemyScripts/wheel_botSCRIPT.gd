extends Node3D
@onready var animation_player: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_0):
		animation_player.play("Idle")
	elif(Input.is_key_pressed(KEY_1)):
		animation_player.play("Forward")
	elif(Input.is_key_pressed(KEY_2)):
		animation_player.play("Attack1")
	elif(Input.is_key_pressed(KEY_3)):
		animation_player.play("Attack2")
	elif(Input.is_key_pressed(KEY_4)):
		animation_player.play("Death")
	pass
