# CameraWatch.gd (Autoload this in Project Settings → Autoload)
extends Node

var _last: Camera3D

func _process(_dt: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam != _last:
		_last = cam
		var path := cam and cam.get_path()
		print("[CAMERA SWITCH] current =", cam, " path=", path)
