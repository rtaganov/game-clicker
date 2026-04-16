extends Resource
class_name PlayerProgress

var money: float = 0.0
var reputation: float = 0.0
var unlocked_cargos: Array[String] = ["crate"]
var purchased_upgrades: Array[String] = []
var purchased_rigs: Array[String] = ["rope"]
var purchased_mechanisms: Array[String] = ["beam"]
var best_heights: Dictionary = {}
var selected_rig: String = "rope"
var selected_mechanism: String = "beam"

func to_dict() -> Dictionary:
	return {
		"money": money,
		"reputation": reputation,
		"unlocked_cargos": unlocked_cargos,
		"purchased_upgrades": purchased_upgrades,
		"purchased_rigs": purchased_rigs,
		"purchased_mechanisms": purchased_mechanisms,
		"best_heights": best_heights,
		"selected_rig": selected_rig,
		"selected_mechanism": selected_mechanism,
	}

func from_dict(data: Dictionary) -> void:
	money = data.get("money", 0.0)
	reputation = data.get("reputation", 0.0)
	unlocked_cargos = Array(data.get("unlocked_cargos", ["crate"]), TYPE_STRING, "", null)
	purchased_upgrades = Array(data.get("purchased_upgrades", []), TYPE_STRING, "", null)
	purchased_rigs = Array(data.get("purchased_rigs", ["rope"]), TYPE_STRING, "", null)
	purchased_mechanisms = Array(data.get("purchased_mechanisms", ["beam"]), TYPE_STRING, "", null)
	best_heights = data.get("best_heights", {})
	selected_rig = data.get("selected_rig", "rope")
	selected_mechanism = data.get("selected_mechanism", "beam")
