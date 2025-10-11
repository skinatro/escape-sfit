extends Node3D
@export var blocks:Array[Node3D]

var allBlocksAlligned:=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	allBlocksAlligned=true
	for block in blocks:
		var csgBlock:CSGPolygon3D=block.get_node("Area3D/CSGPolygon3D")
		# Check if this block is not aligned
		if csgBlock.rotation_degrees.z != block.correctRotationDegree:
			allBlocksAlligned = false
			break  # no need to check further
	
	if(allBlocksAlligned):
		#print("WIN")
		for block in blocks:
			block.get_node("Area3D/CSGPolygon3D/Label3D").text="Win"
