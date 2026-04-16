extends Node
class_name GameManager

signal state_changed
signal message_emitted(text: String)

@export var cargos: Array[CargoData] = []
@export var rigs: Array[RigData] = []
@export var mechanisms: Array[MechanismData] = []
@export var upgrades: Array[UpgradeData] = []

var progress: PlayerProgress
var selected_cargo_id: String = "crate"
var in_attempt: bool = false

var cargo_map: Dictionary = {}
var rig_map: Dictionary = {}
var mech_map: Dictionary = {}
var upgrade_map: Dictionary = {}

var heat_system := HeatSystem.new()
var lift_controller := LiftController.new()
var durability_system := DurabilitySystem.new()
var reward_system := RewardSystem.new()
var upgrade_system := UpgradeSystem.new()

func _ready() -> void:
	_build_maps()
	progress = SaveManager.load_progress()
	_refresh_unlocks()
	upgrade_system.rebuild(progress.purchased_upgrades, upgrade_map)
	if not progress.unlocked_cargos.has(selected_cargo_id):
		selected_cargo_id = progress.unlocked_cargos[0]
	state_changed.emit()

func _process(delta: float) -> void:
	if not in_attempt:
		return
	var cargo := get_selected_cargo()
	var rig := get_selected_rig()
	var mech := get_selected_mechanism()
	if cargo == null or rig == null or mech == null:
		return

	var effective_mech := _effective_mechanism(mech)
	heat_system.process(delta, effective_mech.heat_cool_rate, effective_mech.overheat_threshold)
	var is_overheated := heat_system.state == HeatSystem.HeatState.OVERHEATED
	if is_overheated and int(heat_system.current_heat) == int(effective_mech.overheat_threshold):
		message_emitted.emit("Перегрев")

	var lift_data := lift_controller.process(
		delta,
		cargo,
		_effective_rig(rig),
		effective_mech,
		heat_system.get_heat_factor(effective_mech.overheat_threshold),
		is_overheated,
		1.0 + upgrade_system.modifiers["safe_handling_bonus"]
	)

	durability_system.process(delta, _effective_rig(rig), effective_mech, cargo, lift_controller.current_height, lift_controller.hold_time, heat_system.current_heat)
	progress.money += reward_system.money_per_sec(cargo, _effective_rig(rig), effective_mech, lift_controller.current_height, upgrade_system.modifiers["hold_income_bonus"]) * delta

	if durability_system.current_durability <= 0.0:
		_end_attempt(false)
		message_emitted.emit("Попытка провалена")

	state_changed.emit()

func _build_maps() -> void:
	for c in cargos:
		cargo_map[c.id] = c
	for r in rigs:
		rig_map[r.id] = r
	for m in mechanisms:
		mech_map[m.id] = m
	for u in upgrades:
		upgrade_map[u.id] = u

func _refresh_unlocks() -> void:
	for cargo in cargos:
		if progress.reputation >= cargo.unlock_reputation and not progress.unlocked_cargos.has(cargo.id):
			progress.unlocked_cargos.append(cargo.id)
			message_emitted.emit("Груз открыт: %s" % cargo.name_ru)

func get_selected_cargo() -> CargoData:
	return cargo_map.get(selected_cargo_id)

func get_selected_rig() -> RigData:
	return rig_map.get(progress.selected_rig)

func get_selected_mechanism() -> MechanismData:
	return mech_map.get(progress.selected_mechanism)

func start_attempt() -> bool:
	var cargo := get_selected_cargo()
	var rig := get_selected_rig()
	if cargo.weight > _effective_rig(rig).max_weight:
		message_emitted.emit("Слишком тяжелый груз для текущей оснастки")
		return false
	in_attempt = true
	lift_controller.reset()
	heat_system.current_heat = 0.0
	heat_system.state = HeatSystem.HeatState.NORMAL
	durability_system.reset(_effective_rig(rig).durability_max)
	state_changed.emit()
	return true

func click_lift() -> void:
	if not in_attempt:
		if not start_attempt():
			return
	var mech := _effective_mechanism(get_selected_mechanism())
	lift_controller.on_click(mech.click_power)
	heat_system.on_click(mech.heat_gain_per_click, mech.heat_max)
	state_changed.emit()

func end_attempt_button() -> void:
	if in_attempt:
		_end_attempt(true)

func _end_attempt(success: bool) -> void:
	var cargo := get_selected_cargo()
	in_attempt = false
	var best_height := float(progress.best_heights.get(cargo.id, 0.0))
	var new_record := lift_controller.current_height > best_height
	if new_record:
		progress.best_heights[cargo.id] = lift_controller.current_height
		message_emitted.emit("Новый рекорд")
	progress.reputation += reward_system.reputation_reward(cargo, success, new_record, upgrade_system.modifiers["reputation_bonus"])
	_refresh_unlocks()
	SaveManager.save_progress(progress)
	state_changed.emit()

func buy_rig(rig_id: String) -> void:
	if progress.purchased_rigs.has(rig_id):
		progress.selected_rig = rig_id
		state_changed.emit()
		return
	var rig: RigData = rig_map.get(rig_id)
	if rig and progress.money >= rig.cost:
		progress.money -= rig.cost
		progress.purchased_rigs.append(rig_id)
		progress.selected_rig = rig_id
		SaveManager.save_progress(progress)
		state_changed.emit()

func buy_mechanism(mech_id: String) -> void:
	if progress.purchased_mechanisms.has(mech_id):
		progress.selected_mechanism = mech_id
		state_changed.emit()
		return
	var mech: MechanismData = mech_map.get(mech_id)
	if mech and progress.money >= mech.cost:
		progress.money -= mech.cost
		progress.purchased_mechanisms.append(mech_id)
		progress.selected_mechanism = mech_id
		SaveManager.save_progress(progress)
		state_changed.emit()

func select_cargo(cargo_id: String) -> void:
	if progress.unlocked_cargos.has(cargo_id):
		selected_cargo_id = cargo_id
		state_changed.emit()

func buy_upgrade(upgrade_id: String) -> void:
	if progress.purchased_upgrades.has(upgrade_id):
		return
	var up: UpgradeData = upgrade_map.get(upgrade_id)
	if up and progress.money >= up.cost:
		progress.money -= up.cost
		progress.purchased_upgrades.append(upgrade_id)
		upgrade_system.rebuild(progress.purchased_upgrades, upgrade_map)
		SaveManager.save_progress(progress)
		state_changed.emit()

func _effective_rig(rig: RigData) -> RigData:
	var clone := RigData.new()
	clone.id = rig.id
	clone.name_ru = rig.name_ru
	clone.max_weight = rig.max_weight
	clone.stability = rig.stability + upgrade_system.modifiers["stability_bonus"]
	clone.durability_max = rig.durability_max + upgrade_system.modifiers["durability_bonus"]
	clone.wear_resistance = rig.wear_resistance
	clone.hold_bonus = rig.hold_bonus + upgrade_system.modifiers["hold_bonus_bonus"]
	clone.cost = rig.cost
	return clone

func _effective_mechanism(mech: MechanismData) -> MechanismData:
	var clone := MechanismData.new()
	clone.id = mech.id
	clone.name_ru = mech.name_ru
	clone.lift_speed_base = mech.lift_speed_base + upgrade_system.modifiers["speed_bonus"]
	clone.click_power = mech.click_power + upgrade_system.modifiers["click_power_bonus"]
	clone.heat_max = mech.heat_max
	clone.heat_gain_per_click = mech.heat_gain_per_click * upgrade_system.modifiers["heat_gain_mult"]
	clone.heat_cool_rate = mech.heat_cool_rate + upgrade_system.modifiers["cooling_bonus"]
	clone.overheat_threshold = mech.overheat_threshold
	clone.hold_efficiency = mech.hold_efficiency
	clone.cost = mech.cost
	return clone
