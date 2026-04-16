extends Node
class_name GameManager

signal state_changed
signal message_emitted(text: String)

@export var cargos: Array[CargoData] = []
@export var rigs: Array[RigData] = []
@export var mechanisms: Array[MechanismData] = []

var progress: PlayerProgress
var selected_cargo_id: String = "crate"
var in_attempt: bool = false

enum AttemptState { IDLE, LIFTING, OVERHEATED, FAILED }
var attempt_state: AttemptState = AttemptState.IDLE
var debug_status: String = "init"

var cargo_map: Dictionary = {}
var rig_map: Dictionary = {}
var mech_map: Dictionary = {}

var heat_system := HeatSystem.new()
var lift_controller := LiftController.new()
var durability_system := DurabilitySystem.new()
var reward_system := RewardSystem.new()

func _ready() -> void:
	_build_maps()
	progress = SaveManager.load_progress()
	_ensure_valid_progress_defaults()
	debug_status = "ready"
	state_changed.emit()

func _process(delta: float) -> void:
	if not in_attempt:
		return
	var cargo := get_selected_cargo()
	var rig := get_selected_rig()
	var mech := get_selected_mechanism()
	if cargo == null or rig == null or mech == null:
		return

	heat_system.process(delta, mech.heat_cool_rate, mech.overheat_threshold)
	var is_overheated := heat_system.state == HeatSystem.HeatState.OVERHEATED
	if is_overheated:
		attempt_state = AttemptState.OVERHEATED

	lift_controller.process(
		delta,
		cargo,
		rig,
		mech,
		heat_system.get_heat_factor(mech.overheat_threshold),
		is_overheated
	)

	durability_system.process(delta, rig, mech, cargo, lift_controller.current_height, lift_controller.hold_time, heat_system.current_heat)
	if lift_controller.current_height > 0.0:
		progress.money += reward_system.money_per_sec(cargo, rig, mech, lift_controller.current_height) * delta

	if durability_system.current_durability <= 0.0:
		_fail_attempt()

	if in_attempt and not is_overheated:
		attempt_state = AttemptState.LIFTING

	debug_status = "height=%.2f heat=%.1f state=%s" % [lift_controller.current_height, heat_system.current_heat, get_state_name()]
	state_changed.emit()

func _build_maps() -> void:
	for c in cargos:
		cargo_map[c.id] = c
	for r in rigs:
		rig_map[r.id] = r
	for m in mechanisms:
		mech_map[m.id] = m

func _ensure_valid_progress_defaults() -> void:
	if progress.unlocked_cargos.is_empty():
		progress.unlocked_cargos.append("crate")
	selected_cargo_id = "crate"
	progress.selected_rig = "rope"
	progress.selected_mechanism = "beam"
	if not progress.purchased_rigs.has("rope"):
		progress.purchased_rigs.append("rope")
	if not progress.purchased_mechanisms.has("beam"):
		progress.purchased_mechanisms.append("beam")

func get_selected_cargo() -> CargoData:
	return cargo_map.get(selected_cargo_id)

func get_selected_rig() -> RigData:
	return rig_map.get(progress.selected_rig)

func get_selected_mechanism() -> MechanismData:
	return mech_map.get(progress.selected_mechanism)

func start_attempt() -> bool:
	var cargo := get_selected_cargo()
	var rig := get_selected_rig()
	if cargo == null or rig == null:
		message_emitted.emit("Не удалось начать попытку")
		return false
	if cargo.weight > rig.max_weight:
		message_emitted.emit("Слишком тяжелый груз")
		return false
	in_attempt = true
	attempt_state = AttemptState.LIFTING
	lift_controller.reset()
	heat_system.current_heat = 0.0
	heat_system.state = HeatSystem.HeatState.NORMAL
	durability_system.reset(rig.durability_max)
	debug_status = "attempt started"
	print("[DEBUG] start_attempt")
	state_changed.emit()
	return true

func click_lift() -> void:
	if not in_attempt:
		if not start_attempt():
			return
	var mech := get_selected_mechanism()
	if mech == null:
		return
	if heat_system.state == HeatSystem.HeatState.OVERHEATED:
		attempt_state = AttemptState.OVERHEATED
		message_emitted.emit("Перегрев: подъем временно заблокирован")
		debug_status = "lift click blocked by overheat"
		print("[DEBUG] click_lift blocked")
		state_changed.emit()
		return
	lift_controller.on_click(mech.click_power)
	heat_system.on_click(mech.heat_gain_per_click, mech.heat_max)
	attempt_state = AttemptState.LIFTING
	debug_status = "lift click accepted"
	print("[DEBUG] click_lift accepted")
	state_changed.emit()

func end_attempt_button() -> void:
	if in_attempt:
		_end_attempt(true)
		return
	if attempt_state == AttemptState.FAILED:
		_reset_attempt_runtime()
		attempt_state = AttemptState.IDLE
		debug_status = "failed attempt cleared"
		state_changed.emit()

func _end_attempt(success: bool) -> void:
	var cargo := get_selected_cargo()
	if cargo == null:
		in_attempt = false
		state_changed.emit()
		return
	in_attempt = false
	var best_height := float(progress.best_heights.get(cargo.id, 0.0))
	var new_record := lift_controller.current_height > best_height
	if new_record:
		progress.best_heights[cargo.id] = lift_controller.current_height
		message_emitted.emit("Новый рекорд")
	progress.reputation += reward_system.reputation_reward(cargo, success, new_record)
	SaveManager.save_progress(progress)
	_reset_attempt_runtime()
	attempt_state = AttemptState.IDLE
	debug_status = "attempt ended"
	print("[DEBUG] end_attempt success=%s" % success)
	state_changed.emit()

func _fail_attempt() -> void:
	in_attempt = false
	attempt_state = AttemptState.FAILED
	message_emitted.emit("Попытка провалена")
	progress.reputation += reward_system.reputation_reward(get_selected_cargo(), false, false)
	SaveManager.save_progress(progress)
	_reset_attempt_runtime()
	debug_status = "attempt failed"
	print("[DEBUG] fail_attempt")
	state_changed.emit()

func _reset_attempt_runtime() -> void:
	lift_controller.reset()
	heat_system.current_heat = 0.0
	heat_system.state = HeatSystem.HeatState.NORMAL
	var rig := get_selected_rig()
	if rig != null:
		durability_system.reset(rig.durability_max)

func get_state_name() -> String:
	match attempt_state:
		AttemptState.IDLE:
			return "Idle"
		AttemptState.LIFTING:
			return "Lifting"
		AttemptState.OVERHEATED:
			return "Overheated"
		AttemptState.FAILED:
			return "Failed"
	return "Idle"
