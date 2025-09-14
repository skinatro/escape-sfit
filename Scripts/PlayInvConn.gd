extends Node3D

@onready var player_controller: CharacterBody3D = $PlayerController
@onready var inventory_interface: Control = $HUD/InventoryInterface

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory_interface.set_player_inventory_data(player_controller.inventory_data)
