extends Node3D

@export var blockss:Array[Node3D]   # These are the parent nodes that have the block script attached
var blocks:Array[Node3D] = []

var hasWon := false
var puzzleStarted := false
var tolerance_deg: float = 5.0


func _ready() -> void:
	# ✅ Just store references to the parent nodes directly
	# (You don’t need to fetch "Area3D/CSGPolygon3D" here)
	blocks = blockss.duplicate()


func _process(delta: float) -> void:
	if blocks.is_empty():
		return
	
	var allBlocksAlligned: bool = true

	for block in blocks:
		# ✅ Detect if player has interacted (based on block script state)
		if block.blockSelected or block.rotating:
			puzzleStarted = true

		# ✅ Normalize rotation from the block script
		var currentRot: float = fmod(block.currentRotation, 360.0)
		if currentRot < 0.0:
			currentRot += 360.0

		var aligned: bool = false
		for targetRot in block.correctRotationDegree:  # Array[int] expected
			var targetRotClamped: float = fmod(float(targetRot), 360.0)
			if targetRotClamped < 0.0:
				targetRotClamped += 360.0

			var diff: float = abs(currentRot - targetRotClamped)
			if diff > 180.0:
				diff = 360.0 - diff

			if diff <= tolerance_deg:
				aligned = true
				break

		if not aligned:
			allBlocksAlligned = false
			break

	# ✅ Trigger win only after player starts interacting
	if puzzleStarted and allBlocksAlligned and not hasWon:
		hasWon = true
		Ai.ReduceHealth()
		print("YOU WINNNNNNNNNNNNNNNNNNNNNNNNNNNNN")
		for block in blocks:
			block.get_node("Area3D/CSGPolygon3D/Label3D").text = "WIN"
			await get_tree().create_timer(0.1).timeout
	elif not allBlocksAlligned:
		hasWon = false
