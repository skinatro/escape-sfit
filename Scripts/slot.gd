extends PanelContainer
@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect

func set_slot_data(slot_data: SlotData) -> void:
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	label.text = "%s" % item_data.name
	label.show()
	
