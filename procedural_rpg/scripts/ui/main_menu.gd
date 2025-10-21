extends Control

# Main Menu

@onready var seed_input = $VBoxContainer/SeedInput
@onready var stats_label = $Stats
@onready var continue_button = $VBoxContainer/ContinueButton

func _ready():
	update_stats()
	check_save_exists()

func update_stats():
	var text = "Total Runs: " + str(MemorySystem.get_total_runs()) + "\n"
	text += "Victories: " + str(MemorySystem.get_victories()) + "\n"
	text += "Highest Level: " + str(MemorySystem.get_highest_level())

	if MemorySystem.has_memories():
		text += "\n\n" + MemorySystem.get_narrator_comment()

	stats_label.text = text

func check_save_exists():
	var save_data = SaveSystem.load_game()
	continue_button.disabled = save_data.is_empty()

func _on_new_game_pressed():
	GameManager.start_new_game(0)
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_start_with_seed_pressed():
	var seed_text = seed_input.text
	var seed = 0

	if seed_text.is_empty():
		seed = randi()
	else:
		seed = seed_text.hash()

	GameManager.start_new_game(seed)
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_continue_pressed():
	var save_data = SaveSystem.load_game()
	if not save_data.is_empty():
		# Carrega estado do jogo
		GameManager.current_seed = save_data.seed
		GameManager.player_data = save_data.player
		GameManager.inventory = save_data.inventory
		GameManager.equipment = save_data.equipment
		GameManager.defeated_enemies = save_data.defeated_enemies
		GameManager.met_npcs = save_data.met_npcs
		GameManager.is_corrupted_world = save_data.corrupted

		# Regenera o mundo com a mesma seed
		WorldGenerator.generate_world(GameManager.current_seed, GameManager.is_corrupted_world)
		NarrativeGenerator.generate_narrative(GameManager.current_seed, GameManager.is_corrupted_world)

		get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_diary_pressed():
	# Mostra diário em popup
	print(MemorySystem.get_memories_text())
	# TODO: Criar popup de diário

func _on_exit_pressed():
	get_tree().quit()
