extends RefCounted
class_name LiftController

var current_height: float = 0.0
var hold_time: float = 0.0
var click_boost: float = 0.0

func on_click(click_power: float) -> void:
	click_boost += click_power

func process(delta: float, cargo: CargoData, rig: RigData, mechanism: MechanismData, heat_factor: float, overheated: bool, hold_income_mult: float = 1.0) -> Dictionary:
	click_boost = max(0.0, click_boost - delta * 1.2)
	var weight_ratio := cargo.weight / max(rig.max_weight, 0.001)
	var weight_penalty := clamp(weight_ratio * 0.35, 0.0, 0.35)
	var current_lift_speed := (mechanism.lift_speed_base + click_boost) * (1.0 - weight_penalty) * heat_factor
	var hold_drop_per_sec := max(0.05, cargo.instability * 0.9 - rig.hold_bonus - mechanism.hold_efficiency * 0.4)
	var net_speed := current_lift_speed
	if overheated:
		net_speed = -hold_drop_per_sec * 3.0
	elif click_boost <= 0.01:
		net_speed = current_lift_speed - hold_drop_per_sec
	current_height = max(0.0, current_height + net_speed * delta)
	if current_height > 0.0:
		hold_time += delta * hold_income_mult
	return {
		"current_lift_speed": current_lift_speed,
		"weight_ratio": weight_ratio,
		"hold_drop_per_sec": hold_drop_per_sec,
	}

func reset() -> void:
	current_height = 0.0
	hold_time = 0.0
	click_boost = 0.0
