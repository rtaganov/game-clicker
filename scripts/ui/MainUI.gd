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
@onready var state_label: Label = %StateLabel
@onready var message_label: Label = %MessageLabel
@onready var debug_label: Label = %DebugLabel
@onready var lift_button: Button = %LiftButton
@onready var end_button: Button = %EndButton
@onready var cargo_rect: ColorRect = %CargoRect

const CARGO_BOTTOM_Y := 340.0
const CARGO_TOP_Y := 70.0
const HEIGHT_TO_VISUAL := 12.0

var _message_timer := 0.0

func _ready() -> void:
	if game == null:
		push_error("MainUI: GameManager node not found")
		return
	game.state_changed.connect(_refresh)
	game.message_emitted.connect(_show_message)
	lift_button.pressed.connect(game.click_lift)
	end_button.pressed.connect(game.end_attempt_button)
	_refresh()

func _process(delta: float) -> void:
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0:
			message_label.text = ""

func _refresh() -> void:
	var cargo := game.get_selected_cargo()
	var rig := game.get_selected_rig()
	var mech := game.get_selected_mechanism()
	if cargo == null or rig == null or mech == null:
		message_label.text = "Ошибка данных: проверьте ресурсы"
		return

	money_label.text = "Деньги: %.1f" % game.progress.money
	rep_label.text = "Репутация: %.1f" % game.progress.reputation
	cargo_label.text = "Груз: %s" % cargo.name_ru
	rig_label.text = "Оснастка: %s" % rig.name_ru
	mech_label.text = "Механизм: %s" % mech.name_ru
	height_label.text = "Высота: %.2f" % game.lift_controller.current_height
	best_label.text = "Рекорд: %.2f" % float(game.progress.best_heights.get(cargo.id, 0.0))
	state_label.text = "Состояние: %s" % game.get_state_name()
	debug_label.text = "DEBUG: %s" % game.debug_status

	heat_bar.max_value = mech.heat_max
	heat_bar.value = game.heat_system.current_heat
	dur_bar.max_value = rig.durability_max
	dur_bar.value = game.durability_system.current_durability

	var visual_y := CARGO_BOTTOM_Y - game.lift_controller.current_height * HEIGHT_TO_VISUAL
	cargo_rect.position.y = clampf(visual_y, CARGO_TOP_Y, CARGO_BOTTOM_Y)

	end_button.disabled = not game.in_attempt and game.attempt_state != GameManager.AttemptState.FAILED

func _show_message(text: String) -> void:
	message_label.text = text
	_message_timer = 2.5
