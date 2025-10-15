extends Node3D
var canSelectBlocks=false
var canDo=true
var is_blockSelected=false
var Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	 # Loop through all children
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(canDo):
		for child in get_children():
			if child is Node3D and child.name.contains("Puzzle"):
				child.parent_node = self
				canDo=false

#func _on_area_3d_body_exited(body: CharacterBody3D) -> void:
	#canSelect=false
	#body.capture_mouse()
	#body.blockGameActive=false

func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	##canSelect=true
	#print(body.name)
	#body.release_mouse()
	#body.blockGameActive=true
	#canSelectBlocks=true
	#
	#if(is_blockSelected):
		#body.ristrictMovement=false
		#print("Movement OPENED "+str(body.ristrictMovement))
	#else:
		#body.ristrictMovement=true
		#print("Movement Blocked "+str(body.ristrictMovement))
	Player=body
	if body.is_class("CharacterBody3D"):
		#body.enter_block()   # block the player
		body.blockGameActive = true
		body.release_mouse()
		canSelectBlocks = true
		print("Entered block: Player blocked")


func _on_area_3d_body_exited(body:CharacterBody3D ) -> void:
	Player=null
	#body.release_mouse()
	#body.blockGameActive=true
	#canSelectBlocks=false
	if body.is_class("CharacterBody3D"):
		body.exit_block()    # unblock if no other blocks
		body.blockGameActive = false
		canSelectBlocks = false
		print("Exited block: Player unblocked")
