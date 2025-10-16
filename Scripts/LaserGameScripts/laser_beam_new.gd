extends Area3D
var init_positon_y:=0.0
var init_positon_z:=0.0

@export_group("MODES(SEE EDITOR DESCRIPTION)")
@export var up_down:=true
@export var left_right:=false
@export var Rotate:=false

@export_group("Initial Side?")
@export var isMovingUp:=true
@export var isMovingLeft:=false

@export_group("ATTRIBUTES")
@export var Rangee:=50
@export var moveSpeed:=10.0
@export var rotateSpeed:=1.0

@export var spawnPoint: Area3D#= load("res://Scenes/LaserGame/spawn_point.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set initial positions
	init_positon_y=position.y
	init_positon_z=position.z
	
	#set animationSpeed
	animation_player.speed_scale=rotateSpeed
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(up_down):				#ONLY VERTICAL
		UpDown(delta)
	elif left_right:			#ONLY HORIZONTAL
		LeftRight(delta)
	elif Rotate:  			#ONLY ROTATE
		rotation.y+=rotateSpeed*delta
	pass


func UpDown(delta:float):
	if(Rotate): #ROTATE WITH UPDOWN 
		#animation_player.play("RotateLaser")
		rotation.y+=rotateSpeed*delta
	
	if(isMovingUp):   #Up movement
		if(position.y< init_positon_y+Rangee):
			position.y+=moveSpeed*delta
		elif(position.y>= init_positon_y+Rangee):
			isMovingUp=false
			init_positon_y=position.y
	else:			#Down MOvement
		if(position.y> init_positon_y-Rangee):
			position.y-= moveSpeed*delta
		elif(position.y<= init_positon_y-Rangee):
			isMovingUp=true
			init_positon_y=position.y
			
			
			
			

func LeftRight(delta:float):
	if(Rotate):
		rotation.y+=rotateSpeed*delta
		#animation_player.play("RotateLaser")
	
	
	if !isMovingLeft:  #Right Movement
		if position.z<init_positon_z+Rangee:
			position.z+=moveSpeed*delta
		elif position.z>= init_positon_z+Rangee:
			isMovingLeft=true
			init_positon_z=position.z
	else:               #lEFT Movement
		if position.z>init_positon_z-Rangee:
			position.z-=moveSpeed*delta
		elif position.z<= init_positon_z-Rangee:
			isMovingLeft=false
			init_positon_z=position.z
			





func _on_body_entered(body: Node3D) -> void:
	print(body.name)
	call_deferred("_teleport_body", body)

func _teleport_body(body: Node3D) -> void:
	body.position = spawnPoint.position
		
	
