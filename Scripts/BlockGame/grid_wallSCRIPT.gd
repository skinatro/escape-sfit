extends Node3D

var shrink:=true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(shrink and scale.x>=0):
		scale.x-=.1*delta
	else:
		queue_free()
