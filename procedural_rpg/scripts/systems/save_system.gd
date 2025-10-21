extends Node

# Save System - Sistema de save/load baseado em SEED

const SAVE_PATH = "user://savegame.save"
const PERSISTENT_PATH = "user://persistent.save"

func save_game():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		print("Error saving game: ", FileAccess.get_open_error())
		return false

	var save_data = {
		"seed": GameManager.current_seed,
		"player": GameManager.player_data,
		"inventory": GameManager.inventory,
		"equipment": GameManager.equipment,
		"defeated_enemies": GameManager.defeated_enemies,
		"met_npcs": GameManager.met_npcs,
		"corrupted": GameManager.is_corrupted_world,
		"timestamp": Time.get_datetime_string_from_system()
	}

	save_file.store_var(save_data)
	save_file.close()
	print("Game saved successfully!")
	return true

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return {}

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		print("Error loading game: ", FileAccess.get_open_error())
		return {}

	var save_data = save_file.get_var()
	save_file.close()

	if save_data:
		print("Game loaded successfully!")
		return save_data
	else:
		print("Save data is corrupted")
		return {}

func save_persistent(data: Dictionary):
	var save_file = FileAccess.open(PERSISTENT_PATH, FileAccess.WRITE)
	if save_file == null:
		print("Error saving persistent data: ", FileAccess.get_open_error())
		return false

	save_file.store_var(data)
	save_file.close()
	return true

func load_persistent() -> Dictionary:
	if not FileAccess.file_exists(PERSISTENT_PATH):
		return {}

	var save_file = FileAccess.open(PERSISTENT_PATH, FileAccess.READ)
	if save_file == null:
		return {}

	var data = save_file.get_var()
	save_file.close()

	return data if data else {}

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save deleted")

func export_world_log() -> String:
	"""Exporta um log JSON do mundo atual"""
	var log = {
		"seed": GameManager.current_seed,
		"corrupted": GameManager.is_corrupted_world,
		"timestamp": Time.get_datetime_string_from_system(),
		"boss": {
			"name": NarrativeGenerator.boss_data.name,
			"motivation": NarrativeGenerator.boss_data.motivation,
			"lore": NarrativeGenerator.boss_data.lore,
			"stats": {
				"hp": NarrativeGenerator.boss_data.max_hp,
				"attack": NarrativeGenerator.boss_data.attack,
				"defense": NarrativeGenerator.boss_data.defense
			}
		},
		"world": {
			"spawn": str(WorldGenerator.spawn_point),
			"boss_lair": str(WorldGenerator.boss_lair),
			"villages": WorldGenerator.villages.size(),
			"dungeons": WorldGenerator.dungeons.size()
		},
		"npcs": WorldGenerator.npc_positions.keys(),
		"minibosses": WorldGenerator.miniboss_positions.map(func(mb): return mb.archetype)
	}

	return JSON.stringify(log, "\t")
