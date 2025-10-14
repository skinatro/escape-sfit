extends Node3D
@export var is_working=false
@export var terminal:PackedScene
@export var cutSceneCam:Camera3D
var inRange=false
var terminalUsed=false
var initialSet=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event: InputEvent) -> void:
	if(is_working and inRange and !terminalUsed and Input.is_action_pressed("interact")):
		terminalUsed=true
		
		var parent=get_parent().get_parent().get_parent().get_parent().get_parent()
		if(cutSceneCam!=null): cutSceneCam.current=true
		
		var animPlayer:AnimationPlayer=parent.get_node("AnimationPlayer")
		animPlayer.play("TerminalFocus")
		
		await get_tree().create_timer(3).timeout
		
		if(terminal!=null):
			get_tree().current_scene.add_child(terminal.instantiate())
			if(cutSceneCam!=null):cutSceneCam.current=false
			animPlayer.play("RESET")

func _process(delta: float) -> void:
	if(cutSceneCam!=null and !initialSet):
		cutSceneCam.current=false
		initialSet=true


func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if(is_working):inRange=true
		


func _on_area_3d_body_exited(body: Node3D) -> void:
	if(is_working):inRange=false
