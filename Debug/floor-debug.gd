extends CSGBox3D

@export var tex_path: String = "res://Scenes/owari.png"
@export var uv_scale: Vector3 = Vector3(2, 2, 2)  # increase to tile more

func _ready() -> void:
	pass
	#var tex: Texture2D = load(tex_path)
	#if tex == null:
		#push_error("Texture not found: %s" % tex_path)
		#return
	#
	#var mat := StandardMaterial3D.new()
	#mat.albedo_texture = tex
	#mat.texture_repeat = true   # allow repeating/tiling
	#mat.uv1_scale = uv_scale    # control how often the texture tiles
#
	#material = mat
