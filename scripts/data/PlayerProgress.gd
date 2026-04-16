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
	unlocked_cargos = _to_string_array(data.get("unlocked_cargos", ["crate"]), ["crate"])
	purchased_upgrades = _to_string_array(data.get("purchased_upgrades", []), [])
	purchased_rigs = _to_string_array(data.get("purchased_rigs", ["rope"]), ["rope"])
	purchased_mechanisms = _to_string_array(data.get("purchased_mechanisms", ["beam"]), ["beam"])
	best_heights = data.get("best_heights", {})
	selected_rig = data.get("selected_rig", "rope")
	selected_mechanism = data.get("selected_mechanism", "beam")

func _to_string_array(value: Variant, fallback: Array[String]) -> Array[String]:
	if value is not Array:
		return fallback.duplicate()
	var result: Array[String] = []
	for entry in value:
		if entry is String:
			result.append(entry)
	return result
