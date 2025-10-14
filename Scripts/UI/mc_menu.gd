extends VBoxContainer

const DEBUG = preload("uid://b82mkktpex7se")
const MAIN = preload("uid://d2f3sn771t0f5")

var stored_password: String = ""
var user_password: String = ""
var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_get_completed"))
	
	$NewGame.disabled = true
	$"../PasswordMenu".visible = false  # Hide password menu initially
	
	var toast_label = get_node("../ToastCont/Toast")
	toast_label.visible = false

func _on_new_game_pressed() -> void:
	if $NewGame.disabled:
		show_toast("Enter password first!")
	else:
		get_tree().change_scene_to_packed(DEBUG)

func _on_password_pressed() -> void:
	$"../PasswordMenu".visible = true
	$NewGame.visible = false
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
			print("Parsed JSON data:", data)  # Print entire JSON content here

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
	if user_password == stored_password and stored_password != "":
		show_toast("Password correct! You may start a new game.")
		$NewGame.disabled = false
		$"../PasswordMenu".visible = false
		$NewGame.visible = true
		$Network.visible = true
		$Password.visible = true
		$Quit.visible = true
	else:
		show_toast("Wrong password. Try again.")
		$NewGame.disabled = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_network_pressed() -> void:
	$"../NetworkMenu".visible = true

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


func _on_host_pressed() -> void:
	$"../NetworkMenu/JoinCont".visible = false


func _on_join_pressed() -> void:
	$"../NetworkMenu/HostCont".visible = false


func _on_back_pressed() -> void:
	$"../NetworkMenu/JoinCont".visible = false
	$"../NetworkMenu/HostCont".visible = false
	$"../NetworkMenu".visible = false
