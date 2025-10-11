extends Area3D
var init_positon_y:=0.0
var init_positon_x:=0.0

@export_group("MODES(SEE EDITOR DESCRIPTION)")
@export var up_down:=true
@export var left_right:=false
@export var Rotate:=false

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
	init_positon_x=position.x
	
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
		animation_player.play("RotateLaser")
	pass

var isMovingUp:=true
func UpDown(delta:float):
	if(Rotate): #ROTATE WITH UPDOWN 
		animation_player.play("RotateLaser")
	
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
			
var isMovingLeft:=false
func LeftRight(delta:float):
	if(Rotate):
		animation_player.play("RotateLaser")
	
	
	if !isMovingLeft:  #Right Movement
		if position.x<init_positon_x+Rangee:
			position.x+=moveSpeed*delta
		elif position.x>= init_positon_x+Rangee:
			isMovingLeft=true
			init_positon_x=position.x
	else:               #lEFT Movement
		if position.x>init_positon_x-Rangee:
			position.x-=moveSpeed*delta
		elif position.x<= init_positon_x-Rangee:
			isMovingLeft=false
			init_positon_x=position.x
			





func _on_body_entered(body: Node3D) -> void:
	print(body.name)
	body.position=spawnPoint.position
		
	
