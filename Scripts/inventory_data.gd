extends Resource
class_name InventoryData

signal inventory_updated(inventory_data: InventoryData)

@export var slot_datas: Array[SlotData]

func pick_up_slot_data(slot_data: SlotData) -> bool:
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
		
	return false
