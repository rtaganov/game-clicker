extends RefCounted
class_name UpgradeSystem

var modifiers := {
	"speed_bonus": 0.0,
	"durability_bonus": 0.0,
	"stability_bonus": 0.0,
	"heat_gain_mult": 1.0,
	"cooling_bonus": 0.0,
	"hold_bonus_bonus": 0.0,
	"hold_income_bonus": 0.0,
	"reputation_bonus": 0.0,
	"click_power_bonus": 0.0,
	"safe_handling_bonus": 0.0,
}

func rebuild(purchased_upgrade_ids: Array[String], upgrade_map: Dictionary) -> void:
	modifiers = {
		"speed_bonus": 0.0,
		"durability_bonus": 0.0,
		"stability_bonus": 0.0,
		"heat_gain_mult": 1.0,
		"cooling_bonus": 0.0,
		"hold_bonus_bonus": 0.0,
		"hold_income_bonus": 0.0,
		"reputation_bonus": 0.0,
		"click_power_bonus": 0.0,
		"safe_handling_bonus": 0.0,
	}
	for id in purchased_upgrade_ids:
		if not upgrade_map.has(id):
			continue
		var up: UpgradeData = upgrade_map[id]
		match up.stat_key:
			"speed_bonus", "durability_bonus", "stability_bonus", "cooling_bonus", "hold_bonus_bonus", "hold_income_bonus", "reputation_bonus", "click_power_bonus", "safe_handling_bonus":
				modifiers[up.stat_key] += up.value
			"heat_gain_mult":
				modifiers[up.stat_key] *= up.value
