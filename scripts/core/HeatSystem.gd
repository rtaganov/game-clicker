extends RefCounted
class_name HeatSystem

enum HeatState { NORMAL, OVERHEATED }

var current_heat: float = 0.0
var state: HeatState = HeatState.NORMAL

func on_click(heat_gain_per_click: float, heat_max: float) -> void:
	current_heat = clamp(current_heat + heat_gain_per_click, 0.0, heat_max)

func process(delta: float, cool_rate: float, overheat_threshold: float) -> void:
	current_heat = max(0.0, current_heat - cool_rate * delta)
	if state == HeatState.NORMAL and current_heat >= overheat_threshold:
		state = HeatState.OVERHEATED
	elif state == HeatState.OVERHEATED and current_heat <= overheat_threshold * 0.65:
		state = HeatState.NORMAL

func get_heat_factor(overheat_threshold: float) -> float:
	var safe_limit := overheat_threshold * 0.6
	if current_heat <= safe_limit:
		return 1.0
	var t := inverse_lerp(safe_limit, overheat_threshold, current_heat)
	return lerpf(1.0, 0.25, clamp(t, 0.0, 1.0))
