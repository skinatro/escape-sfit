extends Control
@onready var v_box_container: VBoxContainer = $ColorRect/VBoxContainer
@onready var inputField: TextEdit = $TextEdit

var commandSequence:=["scan","ps","kill","nano","systemct1","shutdown"]

signal terminalEnabled
signal terminalDisabled

var linkedPlayer:CharacterBody3D=null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#terminalEnabled.emit()
	initialPush()
	checkValidity(" ")
	
func _exit_tree() -> void:
	terminalDisabled.emit()
	

var canAdd:=true #ensure only one label is added at a time
var expectedCommand=0
func _process(_delta: float) -> void:
	
	if(Input.is_action_pressed("enter") and canAdd):
		if(inputField.get_line(0)!=""):
			var input = getInputLine()
		
			addTextLable(input) #Add label with that text
			inputField.clear()
			checkValidity(input)
			canAdd=false
			
		elif(inputField.get_line(0)==""):
			inputField.clear()
			canAdd=false
			
	elif (Input.is_action_just_released("enter")):
		canAdd=true
		
	if(Input.is_key_pressed(KEY_ESCAPE)):
		pass
		#var player=find_node_of_type(CharacterBody3D.new()).get_tree().current_scene.get_node("ProtoController")
	#print("SearchingPlayer")

		#player.ristrictMovement=false
		
		var player_cam =find_camera_by_path_fragment("/Head")
			#print(player_cam.get_path())
		if player_cam:
			player_cam.current = true
		queue_free()

		


func addTextLable(text:String):
	#textlabel setup
	var textLabel = RichTextLabel.new()
	textLabel.bbcode_enabled = true
	textLabel.fit_content = true
	#assigh text to label
	textLabel.text = "[font_size=30][b][color=green]EnemyAi@win:~"+text+"[/color][/b][/font_size]"
	#display textlabel
	v_box_container.add_child(textLabel)

func getInputLine():
	var input = inputField.get_line(0) #get text from input field
	input =input.replace(" ","")#Remove White Spaces
	return input.to_lower()
	

func initialPush():
	addTextLable("")
	
var isInitialPush:=true
func checkValidity(input:String):
	if(input==commandSequence[expectedCommand]):
		print("Correct")
		expectedCommand+=1
		
		#Player Wins
		if expectedCommand>5:
			for i in range(200):
				var text = [
	"..........---===---..........",
	"ughdeudbjwkadg",
	"jgdldvdvdehj",
	"utibfdt............uidgOWDIDGIHD",
	"IUAGDLIDGQW...UIGAYDVahj=-=-=-=",
	"---/////---/////---/////",
	"==--==--==--==--==--==--",
	"..::..::..::..::..::..::",
	"###@@@###@@@###@@@###",
	"__--__--__--__--__--__--",
	"..--==[ERROR]===--..",
	"||>>-->>..<<--<<||",
	"....LOADING...0xFFF....",
	"%%$$##!!??>>--<<++==",
	"[[[[[[[[[]]]]]]]]]",
	"//\\//\\//\\//\\//\\//\\",
	"000111000111000111",
	"!!@@##$$%%^^&&**((",
	"....../..../..../....",
	"::DATA_CORRUPT::",
	"|||||||||||||||||||",
	"==-=--=---=--=-==--=",
	"....--===>REBOOT<===--....",
	"^_^_^_^_^_^_^_^_^_^_^_",
	"{{{[[[<<<>>>]]]}}}",
	"::::SYSTEM::::BREACH::::",
	"---...---...---...---...",
	"@@##@@##@@##@@##@@##",
	"<<>>><<>>><<>>><<>>",
	"0xADFF--0x9EF3--0x77C9",
	"..::..::UPLINK LOST::..::..",
	"----[SIGNAL NOISE]----",
	"==//==\\==//==\\==//==",
	"||||\\||||/||||\\||||/",
	"......::::::......::::::",
	"---CRITICAL FAILURE---",
	"///\\\\///\\\\///\\\\",
	"##==##==##==##==##==##",
	"--==[RETRYING CONNECTION]==--",
	"==--==--==--==--==--==--",
	"..........////..........",
	"......--SYSTEM OVERRIDE--......",
	"!!##@@$$%%^^&&**((()))",
	"===>>> TRANSMISSION LOST <<<===",
	".................:::::................."
	].pick_random()
				addTextLable(text)
				await get_tree().create_timer(.005).timeout
				
			Ai.ReduceHealth()
			
			#var player
			#for obj in get_tree().current_scene.get_children():
				#if obj is CharacterBody3D:
					#player=obj
					#break
			linkedPlayer.ristrictMovement=false
			queue_free()
	
	else:
		expectedCommand=0
		if(!isInitialPush):
			addTextLable("Start Again You Fool :)")	
			#Wait for 1 seconds
			await get_tree().create_timer(1).timeout
		
		
		#reset terminal
		resetTerminal()
		initialPush()
		isInitialPush=false

func resetTerminal():
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)
		child.free()
		
# 🔍 Utility: Print all cameras
func print_all_cameras() -> void:
	var cameras = get_all_cameras()
	print("---- All Cameras in Scene ----")
	for cam in cameras:
		print(cam.get_path())
	print("------------------------------")


# 🔍 Utility: Get all cameras recursively
func get_all_cameras() -> Array:
	var cameras: Array = []
	var root = get_tree().current_scene
	if root:
		_find_cameras_recursive(root, cameras)
	return cameras


# Recursive helper
func _find_cameras_recursive(node: Node, cameras: Array) -> void:
	if node is Camera3D:
		cameras.append(node)
	for child in node.get_children():
		_find_cameras_recursive(child, cameras)


func find_camera_by_path_fragment(fragment: String) -> Camera3D:
	for cam in get_all_cameras():
		if fragment in str(cam.get_path()):
			return cam
	return null
