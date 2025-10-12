extends ProgressBar

@export var max_health: float = 100.0

var health: float = 0.0

# one-time hit gates per boss spawn
var area1_hit := false
var area2_hit := false
var area3_hit := false
var area4_hit := false

func _ready() -> void:
	visible = false
	health = 0.0
	value = 0.0
	max_value = max_health

# -------------------------
# Boss spawn (client asks, server sets & broadcasts)
# -------------------------
func _on_boss_created_body_entered(_body: Node3D) -> void:
	# Ask server to (re)initialize boss health & flags
	rpc_id(1, "request_boss_spawn")

@rpc("authority") # runs on server
func request_boss_spawn() -> void:
	health = max_health
	area1_hit = false
	area2_hit = false
	area3_hit = false
	area4_hit = false
	# broadcast fresh state to everyone (including server itself)
	rpc("sync_state", health, area1_hit, area2_hit, area3_hit, area4_hit, true)

# -------------------------
# Damage areas (client asks, server validates, broadcasts)
# -------------------------
func _on_boss_dmg_1_body_entered(_body: Node3D) -> void:
	if health <= 0.0 or area1_hit: return
	rpc_id(1, "request_area_hit", 1)

func _on_boss_dmg_2_body_entered(_body: Node3D) -> void:
	if health <= 0.0 or area2_hit: return
	rpc_id(1, "request_area_hit", 2)

func _on_boss_dmg_3_body_entered(_body: Node3D) -> void:
	if health <= 0.0 or area3_hit: return
	rpc_id(1, "request_area_hit", 3)

func _on_boss_dmg_4_body_entered(_body: Node3D) -> void:
	if health <= 0.0 or area4_hit: return
	rpc_id(1, "request_area_hit", 4)

@rpc("authority") # server-only
func request_area_hit(idx: int) -> void:
	if health <= 0.0:
		return

	match idx:
		1:
			if area1_hit: return
			area1_hit = true
		2:
			if area2_hit: return
			area2_hit = true
		3:
			if area3_hit: return
			area3_hit = true
		4:
			if area4_hit: return
			area4_hit = true
		_:
			return

	# reduce health (25 each time, or compute from max_health/4.0)
	var dmg := max_health / 4.0
	health = max(0.0, health - dmg)

	var vis := health > 0.0
	rpc("sync_state", health, area1_hit, area2_hit, area3_hit, area4_hit, vis)

# -------------------------
# Replication (runs on all peers)
# -------------------------
@rpc("any_peer", "call_local") 
func sync_state(h: float, a1: bool, a2: bool, a3: bool, a4: bool, vis: bool) -> void:
	health = h
	area1_hit = a1
	area2_hit = a2
	area3_hit = a3
	area4_hit = a4

	visible = vis
	max_value = max_health
	value = health
