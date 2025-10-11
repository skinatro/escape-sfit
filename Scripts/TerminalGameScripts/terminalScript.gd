extends Control
@onready var v_box_container: VBoxContainer = $ColorRect/VBoxContainer
@onready var inputField: TextEdit = $TextEdit

var commandSequence:=["scan","ps","kill","nano","systemct1","shutdown"]

signal terminalEnabled
signal terminalDisabled


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terminalEnabled.emit()
	initialPush()
	
	checkValidity(" ")
	
func _exit_tree() -> void:
	terminalDisabled.emit()
	

var canAdd:=true #ensure only one label is added at a time
var expectedCommand=0
func _process(delta: float) -> void:
	
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
func checkValidity(input:String):
	
	if(input==commandSequence[expectedCommand]):
		print("Correct")
		expectedCommand+=1
		
		#Player Wins
		if expectedCommand>5:
			addTextLable("YOU WON :)")
			queue_free()
	
	else:
		expectedCommand=0
		addTextLable("Start Again You Fool :)")	
		#Wait for 1 seconds
		await get_tree().create_timer(1).timeout
		
		#reset terminal
		resetTerminal()
		initialPush()

func resetTerminal():
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)
		child.free()
		
