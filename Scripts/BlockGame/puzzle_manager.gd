extends Node3D

@export var blockss: Array[Node3D]
var blocks: Array[Node3D] = []

var hasWon: bool = false
var puzzleStarted: bool = false
var tolerance_deg: float = 5.0


func _ready() -> void:
	blocks = blockss.duplicate()


func _process(delta: float) -> void:
	if blocks.is_empty():
		return

	var allBlocksAlligned: bool = true

	for block in blocks:
		# Detect when player starts rotating or selecting blocks
		if block.blockSelected or block.rotating:
			puzzleStarted = true

		# Normalize current rotation
		var currentRot: float = fmod(block.currentRotation, 360.0)
		if currentRot < 0.0:
			currentRot += 360.0

		# Get target rotation from the block script
		var targetRot: float = fmod(float(block.correctRotationDegree), 360.0)
		if targetRot < 0.0:
			targetRot += 360.0

		# Compute angular difference (account for wrap-around)
		var diff: float = abs(currentRot - targetRot)
		if diff > 180.0:
			diff = 360.0 - diff

		# Check alignment
		if diff > tolerance_deg:
			allBlocksAlligned = false
			break

	# Trigger win only after puzzle has started and ALL blocks are aligned
	if puzzleStarted and allBlocksAlligned and not hasWon:
		hasWon = true
		print("YOU WINNNNNNNNNNNNNNNNNNNNNNNNNNNNN")
		Ai.ReduceHealth()

	elif not allBlocksAlligned:
		hasWon = false
