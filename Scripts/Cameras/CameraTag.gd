# CameraTag.gd
extends Camera3D
@export var label := ""

var _was_current := false

func _ready() -> void:
	if current:
		print("[", label, "] current at _ready: ", get_path())

func _process(_dt: float) -> void:
	var now := is_current()
	if now != _was_current:
		_was_current = now
		print("[%s] %s current: %s" % [label, "BECAME" if now else "LOST", get_path()])
