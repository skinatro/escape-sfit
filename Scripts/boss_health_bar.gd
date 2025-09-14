extends ProgressBar

@export var max_health: float = 100.0
var health: float = 0.0
#boss damage triggers
# should be triggered once per boss spawn
var area1_hit := false
var area2_hit := false
var area3_hit := false
var area4_hit := false

func _ready() -> void:
	visible = false
	health = 0.0
	value = 0.0

func _on_boss_created_body_entered(_body: Node3D) -> void:
	max_value = max_health
	health = max_health
	value = health
	visible = true
	area1_hit = false
	area2_hit = false
	area3_hit = false
	area4_hit = false

func _on_boss_dmg_1_body_entered(_body: Node3D) -> void:
	if area1_hit or health <= 0.0: return
	area1_hit = true
	health = max(0.0, health - 25.0)
	value = health
	if health <= 0.0: visible = false

func _on_boss_dmg_2_body_entered(_body: Node3D) -> void:
	if area2_hit or health <= 0.0: return
	area2_hit = true
	health = max(0.0, health - 25.0)
	value = health
	if health <= 0.0: visible = false

func _on_boss_dmg_3_body_entered(_body: Node3D) -> void:
	if area3_hit or health <= 0.0: return
	area3_hit = true
	health = max(0.0, health - 25.0)
	value = health
	if health <= 0.0: visible = false

func _on_boss_dmg_4_body_entered(_body: Node3D) -> void:
	if area4_hit or health <= 0.0: return
	area4_hit = true
	health = max(0.0, health - 25.0)
	value = health
	if health <= 0.0: visible = false
