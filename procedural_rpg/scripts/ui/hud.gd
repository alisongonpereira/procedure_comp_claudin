extends Control

# HUD - Heads-Up Display

@onready var hp_bar = $TopBar/VBoxContainer/HPBar
@onready var hp_label = $TopBar/VBoxContainer/HPLabel
@onready var level_label = $TopBar/VBoxContainer/LevelLabel
@onready var gold_label = $TopBar/VBoxContainer/GoldLabel
@onready var world_info = $WorldInfo

func _ready():
	GameManager.player_stats_changed.connect(update_stats)
	update_stats()
	update_world_info()

func update_stats():
	var player = GameManager.player_data

	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp
	hp_label.text = "HP: " + str(player.hp) + "/" + str(player.max_hp)

	var exp_needed = player.level * 100
	level_label.text = "Level " + str(player.level) + " | EXP: " + str(player.exp) + "/" + str(exp_needed)

	gold_label.text = "Gold: " + str(player.gold)

func update_world_info():
	var text = "Seed: " + str(GameManager.current_seed) + "\n"

	if GameManager.is_corrupted_world:
		text += "World: CORRUPTED"
	else:
		text += "World: Normal"

	world_info.text = text
