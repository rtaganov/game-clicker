extends RefCounted
class_name RewardSystem

func money_per_sec(cargo: CargoData, rig: RigData, mechanism: MechanismData, current_height: float, hold_income_bonus: float = 0.0) -> float:
	return cargo.reward_base * (1.0 + current_height / 10.0) * (1.0 + rig.hold_bonus + mechanism.hold_efficiency * 0.5 + hold_income_bonus)

func reputation_reward(cargo: CargoData, success: bool, new_record: bool, reputation_gain_bonus: float = 0.0) -> float:
	var success_multiplier := 1.0 if success else 0.4
	var new_record_bonus := 2.0 if new_record else 0.0
	return (cargo.reputation_base * success_multiplier + new_record_bonus) * (1.0 + reputation_gain_bonus)
