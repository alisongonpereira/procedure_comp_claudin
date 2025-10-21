extends Node

# Combat System - Sistema de combate por turnos

signal combat_log(message: String)
signal player_turn
signal enemy_turn
signal combat_ended(victory: bool)

var is_in_combat = false
var current_enemy: Dictionary = {}
var is_boss_fight = false
var turn_count = 0
var current_phase_index = 0

func start_combat(enemy_data: Dictionary, is_boss: bool = false):
	is_in_combat = true
	current_enemy = enemy_data.duplicate()
	is_boss_fight = is_boss
	turn_count = 0
	current_phase_index = 0

	combat_log.emit("=== COMBAT START ===")
	combat_log.emit("Enemy: " + current_enemy.name + " (Lv." + str(current_enemy.get("level", 1)) + ")")

	if is_boss:
		combat_log.emit(current_enemy.get("lore", ""))

	GameManager.change_state(GameManager.GameState.COMBAT)
	player_turn.emit()

func player_attack():
	if not is_in_combat:
		return

	var damage = calculate_damage(GameManager.player_data.attack, current_enemy.defense)

	# Crítico 10%
	if randf() < 0.1:
		damage = int(damage * 2)
		combat_log.emit("CRITICAL HIT!")

	current_enemy.hp -= damage
	current_enemy.hp = max(0, current_enemy.hp)

	combat_log.emit("You attack for " + str(damage) + " damage!")
	combat_log.emit(current_enemy.name + " HP: " + str(current_enemy.hp) + "/" + str(current_enemy.max_hp))

	# Checa fases do boss
	if is_boss_fight:
		check_boss_phase()

	if current_enemy.hp <= 0:
		on_enemy_defeated()
	else:
		enemy_turn.emit()
		await get_tree().create_timer(0.5).timeout
		enemy_attack()

func enemy_attack():
	if not is_in_combat:
		return

	var attack_power = current_enemy.attack

	# Boss em fases avançadas ataca mais forte
	if is_boss_fight and "phases" in current_enemy:
		var hp_percent = float(current_enemy.hp) / float(current_enemy.max_hp)
		for phase in current_enemy.phases:
			if hp_percent <= phase.threshold:
				attack_power = int(attack_power * phase.attack_multiplier)
				break

	var damage = calculate_damage(attack_power, GameManager.player_data.defense)

	# Crítico 5% para inimigos
	if randf() < 0.05:
		damage = int(damage * 1.5)
		combat_log.emit(current_enemy.name + " lands a critical hit!")

	GameManager.damage_player(damage)
	combat_log.emit(current_enemy.name + " attacks for " + str(damage) + " damage!")
	combat_log.emit("Your HP: " + str(GameManager.player_data.hp) + "/" + str(GameManager.player_data.max_hp))

	if GameManager.player_data.hp > 0:
		turn_count += 1
		player_turn.emit()

func player_defend():
	if not is_in_combat:
		return

	combat_log.emit("You brace for impact!")

	# Defesa temporária
	var original_defense = GameManager.player_data.defense
	GameManager.player_data.defense += 5

	enemy_turn.emit()
	await get_tree().create_timer(0.5).timeout
	enemy_attack()

	# Restaura defesa
	GameManager.player_data.defense = original_defense

func player_use_item(item: Dictionary):
	if not is_in_combat:
		return

	match item.type:
		"healing":
			var heal_amount = item.get("value", 30)
			GameManager.heal_player(heal_amount)
			combat_log.emit("You use " + item.name + " and heal " + str(heal_amount) + " HP!")
			GameManager.remove_item_from_inventory(item)

		"buff":
			# TODO: Implementar buffs temporários
			pass

	enemy_turn.emit()
	await get_tree().create_timer(0.5).timeout
	enemy_attack()

func player_flee():
	if is_boss_fight:
		combat_log.emit("You cannot flee from this fight!")
		return

	var flee_chance = 0.5
	if randf() < flee_chance:
		combat_log.emit("You fled successfully!")
		end_combat(false)
	else:
		combat_log.emit("Can't escape!")
		enemy_turn.emit()
		await get_tree().create_timer(0.5).timeout
		enemy_attack()

func calculate_damage(attack: int, defense: int) -> int:
	var base_damage = attack - (defense / 2)
	var variance = randf_range(0.9, 1.1)
	return max(1, int(base_damage * variance))

func check_boss_phase():
	if not "phases" in current_enemy:
		return

	var hp_percent = float(current_enemy.hp) / float(current_enemy.max_hp)

	for i in range(current_enemy.phases.size()):
		var phase = current_enemy.phases[i]
		if hp_percent <= phase.threshold and i > current_phase_index:
			current_phase_index = i
			combat_log.emit("=== " + current_enemy.name + " ===")
			combat_log.emit(phase.dialogue)
			combat_log.emit("The enemy grows stronger!")
			break

func on_enemy_defeated():
	combat_log.emit(current_enemy.name + " defeated!")

	# Recompensas
	if "exp_reward" in current_enemy:
		GameManager.add_exp(current_enemy.exp_reward)
		combat_log.emit("Gained " + str(current_enemy.exp_reward) + " EXP!")

	if "gold_reward" in current_enemy:
		GameManager.add_gold(current_enemy.gold_reward)
		combat_log.emit("Gained " + str(current_enemy.gold_reward) + " gold!")

	# Chance de drop de item
	if randf() < 0.3:
		var item = generate_random_item()
		GameManager.add_item_to_inventory(item)
		combat_log.emit("Found: " + item.name + "!")

	# Boss derrotado
	if is_boss_fight:
		GameManager.on_boss_defeated()

	end_combat(true)

func end_combat(victory: bool):
	is_in_combat = false
	combat_ended.emit(victory)
	GameManager.change_state(GameManager.GameState.EXPLORING)

func generate_random_item() -> Dictionary:
	var item_types = [
		{"name": "Health Potion", "type": "healing", "value": 30, "description": "Restores 30 HP"},
		{"name": "Greater Potion", "type": "healing", "value": 50, "description": "Restores 50 HP"},
		{"name": "Ancient Coin", "type": "treasure", "value": 20, "description": "Sell for gold"},
		{"name": "Strange Gem", "type": "treasure", "value": 50, "description": "A mysterious gemstone"}
	]

	return item_types[randi() % item_types.size()].duplicate()
