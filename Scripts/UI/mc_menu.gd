extends VBoxContainer
const DEBUG = preload("uid://b82mkktpex7se")
const MAIN = preload("uid://d2f3sn771t0f5")


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(DEBUG)
	



func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_network_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN)
