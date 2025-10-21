extends Node

# Game Manager - Gerencia o estado global do jogo

signal game_state_changed(new_state)
signal player_stats_changed
signal combat_started(enemy)
signal combat_ended(victory: bool)

enum GameState {
	MAIN_MENU,
	EXPLORING,
	COMBAT,
	DIALOGUE,
	INVENTORY,
	DIARY,
	PAUSED
}

var current_state: GameState = GameState.MAIN_MENU
var current_seed: int = 0
var is_corrupted_world: bool = false
var runs_completed: int = 0

# Player stats
var player_data = {
	"hp": 100,
	"max_hp": 100,
	"attack": 10,
	"defense": 5,
	"level": 1,
	"exp": 0,
	"gold": 0,
	"position": Vector2(0, 0)
}

# Inventory
var inventory: Array = []
var equipment = {
	"weapon": null,
	"armor": null,
	"accessory": null
}

# Current world data
var current_world_data = {}
var current_boss_data = {}
var defeated_enemies: Array = []
var met_npcs: Array = []

func _ready():
	randomize()
	load_persistent_data()

func start_new_game(seed: int = 0):
	if seed == 0:
		current_seed = randi()
	else:
		current_seed = seed

	# 5% chance de mundo corrompido
	is_corrupted_world = randf() < 0.05

	# Reset player
	reset_player_stats()

	# Gera novo mundo
	WorldGenerator.generate_world(current_seed, is_corrupted_world)
	current_world_data = WorldGenerator.world_data

	# Gera narrativa
	NarrativeGenerator.generate_narrative(current_seed, is_corrupted_world)
	current_boss_data = NarrativeGenerator.boss_data

	print("=== NEW WORLD GENERATED ===")
	print("Seed: ", current_seed)
	print("Corrupted: ", is_corrupted_world)
	print("Boss: ", current_boss_data.name)
	print("Motivation: ", current_boss_data.motivation)
	print("===========================")

	change_state(GameState.EXPLORING)

func reset_player_stats():
	player_data = {
		"hp": 100,
		"max_hp": 100,
		"attack": 10,
		"defense": 5,
		"level": 1,
		"exp": 0,
		"gold": 50,
		"position": Vector2(0, 0)
	}
	inventory = []
	defeated_enemies = []
	met_npcs = []
	player_stats_changed.emit()

func change_state(new_state: GameState):
	current_state = new_state
	game_state_changed.emit(new_state)

func damage_player(amount: int):
	var actual_damage = max(1, amount - player_data.defense)
	player_data.hp -= actual_damage
	player_data.hp = max(0, player_data.hp)
	player_stats_changed.emit()

	if player_data.hp <= 0:
		on_player_death()

	return actual_damage

func heal_player(amount: int):
	player_data.hp = min(player_data.max_hp, player_data.hp + amount)
	player_stats_changed.emit()

func add_exp(amount: int):
	player_data.exp += amount
	check_level_up()
	player_stats_changed.emit()

func check_level_up():
	var exp_needed = player_data.level * 100
	if player_data.exp >= exp_needed:
		player_data.level += 1
		player_data.exp -= exp_needed
		player_data.max_hp += 10
		player_data.hp = player_data.max_hp
		player_data.attack += 2
		player_data.defense += 1
		print("LEVEL UP! Now level ", player_data.level)

func add_gold(amount: int):
	player_data.gold += amount
	player_stats_changed.emit()

func add_item_to_inventory(item: Dictionary):
	inventory.append(item)

func remove_item_from_inventory(item: Dictionary):
	inventory.erase(item)

func on_player_death():
	print("Player died!")
	# Registra a run no sistema de memória
	MemorySystem.record_run({
		"seed": current_seed,
		"boss": current_boss_data,
		"level_reached": player_data.level,
		"corrupted": is_corrupted_world,
		"timestamp": Time.get_datetime_string_from_system()
	})
	runs_completed += 1
	save_persistent_data()

	# Volta ao menu
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func on_boss_defeated():
	print("BOSS DEFEATED! World conquered!")
	# Registra a run vitoriosa
	MemorySystem.record_run({
		"seed": current_seed,
		"boss": current_boss_data,
		"level_reached": player_data.level,
		"corrupted": is_corrupted_world,
		"victory": true,
		"timestamp": Time.get_datetime_string_from_system()
	})
	runs_completed += 1
	save_persistent_data()

	# Volta ao menu
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func save_persistent_data():
	var data = {
		"runs_completed": runs_completed,
		"memories": MemorySystem.memories
	}
	SaveSystem.save_persistent(data)

func load_persistent_data():
	var data = SaveSystem.load_persistent()
	if data:
		runs_completed = data.get("runs_completed", 0)
		MemorySystem.memories = data.get("memories", [])
