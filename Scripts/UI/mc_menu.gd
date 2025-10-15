extends VBoxContainer

var map = preload("res://Scenes/SFIT/Map.tscn")

var stored_password: String = ""
var user_password: String = ""
var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_get_completed"))
	
	$Network.disabled = true 
	$"../PasswordMenu".visible = false
	var toast_label = get_node("../ToastCont/Toast")
	toast_label.visible = false

func _on_password_pressed() -> void:
	$"../PasswordMenu".visible = true
	
	$Network.visible = false
	$Password.visible = false
	$Quit.visible = false
	
	fetch_pw()

func fetch_pw():
	var url = "https://godot-server-7s9t.onrender.com/result"
	var headers = ["Content-Type: application/json"]  # Optional for GET
	var err = http_request.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		show_toast("Password fetch failed: " + str(err))

func _on_get_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var body_text = body.get_string_from_utf8()
		print("Response body:", body_text)

		var json = JSON.new()
		var err = json.parse(body_text)
		if err == OK:
			var data = json.get_data()
			print("Parsed JSON data:", data)

			if data.get("status", "") == "waiting":
				show_toast("Result not ready yet. Please wait.")
				stored_password = ""
			else:
				stored_password = data.get("merged", "")
				print("Fetched Password:", stored_password)
				show_toast("Password fetched. Please validate.")
		else:
			show_toast("Failed to parse password response.")
	else:
		show_toast("Error fetching password: HTTP " + str(response_code))

func _on_validate_pressed() -> void:
	user_password = $"../PasswordMenu".get_node("PasswordEntry").text
	var backup_password = "ladder&67"#IMPORTANT#####################################################
	if (user_password == stored_password and stored_password != "") or user_password == backup_password:
		show_toast("Password correct! You may start a new game.")
		$Network.disabled = false
		$"../PasswordMenu".visible = false
		$Network.visible = true
		$Password.visible = true
		$Quit.visible = true
	else:
		show_toast("Wrong password. Try again.")
		$Network.disabled = true


func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_network_pressed() -> void:
	$".".visible = false
	
	# Store old scene before adding the new one
	var old_scene = get_tree().current_scene

	# Instantiate and add new scene instance
	var map_instance = map.instantiate()
	var root = get_tree().get_root()
	root.add_child(map_instance)

	# Set new instance as current scene
	get_tree().current_scene = map_instance

	# Free old scene if different
	if old_scene and old_scene != map_instance:
		old_scene.queue_free()


	
func show_toast(message: String, duration: float = 2.0):
	var toast_label = get_node("../ToastCont/Toast")
	var toast_timer = get_node("../ToastCont/ToastTimer")
	toast_label.text = message
	toast_label.visible = true
	toast_timer.wait_time = duration
	toast_timer.start()

func _on_ToastTimer_timeout():
	var toast_label = get_node("../ToastCont/Toast")
	toast_label.visible = false
