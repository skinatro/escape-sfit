extends PanelContainer

const Slot = preload("res://Scenes/slot.tscn")
@onready var grid_container: GridContainer = $MarginContainer/GridContainer

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#var inv_data = preload("res://GameResources/test-inv.tres")
	#populate_item_grid(inv_data.slot_datas)
	
func populate_item_grid(inventory_data: InventoryData) -> void:
	for child in grid_container.get_children():
		child.queue_free()
	
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instantiate()
		grid_container.add_child(slot)
	
		if slot_data:
			slot.set_slot_data(slot_data)
