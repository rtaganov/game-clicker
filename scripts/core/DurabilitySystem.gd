extends RefCounted
class_name DurabilitySystem

var current_durability: float = 100.0

func reset(max_durability: float) -> void:
	current_durability = max_durability

func process(delta: float, rig: RigData, mechanism: MechanismData, cargo: CargoData, current_height: float, hold_time: float, heat: float) -> float:
	var danger_factor := 0.0
	if heat > mechanism.overheat_threshold * 0.9:
		danger_factor += 1.0
	if cargo.weight / max(rig.max_weight, 0.001) > 0.9:
		danger_factor += 1.0
	if current_height > 15.0 and hold_time > 4.0:
		danger_factor += 1.0
	if danger_factor > 0.0:
		var loss := danger_factor * (1.2 / max(rig.wear_resistance, 0.001)) * delta
		current_durability = max(0.0, current_durability - loss)
	return danger_factor
