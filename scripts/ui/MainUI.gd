extends Control
class_name MainUI

@onready var game: GameManager = $GameManager
@onready var money_label: Label = %MoneyLabel
@onready var rep_label: Label = %RepLabel
@onready var cargo_label: Label = %CargoLabel
@onready var rig_label: Label = %RigLabel
@onready var mech_label: Label = %MechLabel
@onready var height_label: Label = %HeightLabel
@onready var best_label: Label = %BestLabel
@onready var heat_bar: ProgressBar = %HeatBar
@onready var dur_bar: ProgressBar = %DurabilityBar
@onready var message_label: Label = %MessageLabel
@onready var cargo_select: OptionButton = %CargoSelect
@onready var rig_select: OptionButton = %RigSelect
@onready var mech_select: OptionButton = %MechSelect
@onready var lift_button: Button = %LiftButton
@onready var end_button: Button = %EndButton
@onready var upgrades_box: VBoxContainer = %UpgradesBox

var _message_timer := 0.0

func _ready() -> void:
	if game == null:
		push_error("MainUI: GameManager node not found")
		return
	game.state_changed.connect(_refresh)
	game.message_emitted.connect(_show_message)
	lift_button.pressed.connect(game.click_lift)
	end_button.pressed.connect(game.end_attempt_button)
	cargo_select.item_selected.connect(_on_cargo_selected)
	rig_select.item_selected.connect(_on_rig_selected)
	mech_select.item_selected.connect(_on_mech_selected)
	_rebuild_selectors()
	_rebuild_upgrades()
	_refresh()

func _process(delta: float) -> void:
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0:
			message_label.text = ""

func _rebuild_selectors() -> void:
	cargo_select.clear()
	for c in game.cargos:
		var unlocked := game.progress.unlocked_cargos.has(c.id)
		var suffix := "" if unlocked else " (🔒 %d)" % int(c.unlock_reputation)
		cargo_select.add_item(c.name_ru + suffix)
		cargo_select.set_item_metadata(cargo_select.item_count - 1, c.id)

	rig_select.clear()
	for r in game.rigs:
		var owned := game.progress.purchased_rigs.has(r.id)
		var suffix := "" if owned else " (💰 %d)" % int(r.cost)
		rig_select.add_item(r.name_ru + suffix)
		rig_select.set_item_metadata(rig_select.item_count - 1, r.id)

	mech_select.clear()
	for m in game.mechanisms:
		var owned := game.progress.purchased_mechanisms.has(m.id)
		var suffix := "" if owned else " (💰 %d)" % int(m.cost)
		mech_select.add_item(m.name_ru + suffix)
		mech_select.set_item_metadata(mech_select.item_count - 1, m.id)

func _rebuild_upgrades() -> void:
	for child in upgrades_box.get_children():
		child.queue_free()
	for up in game.upgrades:
		var b := Button.new()
		b.text = "%s [%d]" % [up.name_ru, int(up.cost)]
		b.tooltip_text = up.description
		b.disabled = game.progress.purchased_upgrades.has(up.id)
		b.pressed.connect(func() -> void:
			game.buy_upgrade(up.id)
			_rebuild_upgrades()
		)
		upgrades_box.add_child(b)

func _refresh() -> void:
	_rebuild_selectors()
	_rebuild_upgrades()
	var cargo := game.get_selected_cargo()
	var rig := game.get_selected_rig()
	var mech := game.get_selected_mechanism()
	if cargo == null or rig == null or mech == null:
		message_label.text = "Ошибка данных: проверьте ресурсы грузов/оснастки/механизмов"
		return
	money_label.text = "Деньги: %.1f" % game.progress.money
	rep_label.text = "Репутация: %.1f" % game.progress.reputation
	cargo_label.text = "Груз: %s" % cargo.name_ru
	rig_label.text = "Оснастка: %s" % rig.name_ru
	mech_label.text = "Механизм: %s" % mech.name_ru
	height_label.text = "Высота: %.2f" % game.lift_controller.current_height
	best_label.text = "Рекорд: %.2f" % float(game.progress.best_heights.get(cargo.id, 0.0))

	var effective_mech := game._effective_mechanism(mech)
	heat_bar.max_value = effective_mech.heat_max
	heat_bar.value = game.heat_system.current_heat
	var heat_ratio := game.heat_system.current_heat / max(effective_mech.overheat_threshold, 1.0)
	if heat_ratio < 0.6:
		heat_bar.modulate = Color(0.3, 0.95, 0.3)
	elif heat_ratio < 0.9:
		heat_bar.modulate = Color(0.95, 0.85, 0.3)
	else:
		heat_bar.modulate = Color(0.95, 0.3, 0.3)

	var effective_rig := game._effective_rig(rig)
	dur_bar.max_value = effective_rig.durability_max
	dur_bar.value = game.durability_system.current_durability
	end_button.disabled = not game.in_attempt

func _show_message(text: String) -> void:
	message_label.text = text
	_message_timer = 2.0

func _on_cargo_selected(index: int) -> void:
	game.select_cargo(str(cargo_select.get_item_metadata(index)))

func _on_rig_selected(index: int) -> void:
	game.buy_rig(str(rig_select.get_item_metadata(index)))

func _on_mech_selected(index: int) -> void:
	game.buy_mechanism(str(mech_select.get_item_metadata(index)))
