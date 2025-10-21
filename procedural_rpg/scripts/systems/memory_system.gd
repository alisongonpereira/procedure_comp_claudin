extends Node

# Memory System - O jogador é o único que se lembra das runs passadas

var memories: Array = []
const MAX_MEMORIES = 50

signal memory_added(memory)

func record_run(run_data: Dictionary):
	"""Registra uma run completa na memória"""
	var memory = {
		"seed": run_data.seed,
		"boss_name": run_data.boss.name,
		"boss_motivation": run_data.boss.motivation,
		"level_reached": run_data.level_reached,
		"corrupted": run_data.corrupted,
		"victory": run_data.get("victory", false),
		"timestamp": run_data.timestamp,
		"notable_events": []
	}

	memories.append(memory)
	memory_added.emit(memory)

	# Limita número de memórias
	if memories.size() > MAX_MEMORIES:
		memories.pop_front()

	print("Memory recorded: ", memory.boss_name, " (", memory.boss_motivation, ")")

func add_event_to_current_run(event: String):
	"""Adiciona um evento notável à run atual"""
	# Não há run atual em memória ainda, então guardamos para adicionar depois
	pass

func has_memories() -> bool:
	return memories.size() > 0

func get_total_runs() -> int:
	return memories.size()

func get_victories() -> int:
	return memories.filter(func(m): return m.get("victory", false)).size()

func get_defeats() -> int:
	return memories.filter(func(m): return not m.get("victory", false)).size()

func has_faced_boss(boss_name: String) -> bool:
	return memories.any(func(m): return m.boss_name == boss_name)

func has_seen_motivation(motivation: String) -> bool:
	return memories.any(func(m): return m.boss_motivation == motivation)

func get_highest_level() -> int:
	if memories.is_empty():
		return 1

	var max_level = 1
	for memory in memories:
		if memory.level_reached > max_level:
			max_level = memory.level_reached

	return max_level

func get_memories_text() -> String:
	"""Retorna um texto formatado com todas as memórias"""
	if memories.is_empty():
		return "No memories yet. This is your first journey."

	var text = "=== ECHOES OF MEMORY ===\n\n"
	text += "Total runs: " + str(get_total_runs()) + "\n"
	text += "Victories: " + str(get_victories()) + "\n"
	text += "Defeats: " + str(get_defeats()) + "\n"
	text += "Highest level: " + str(get_highest_level()) + "\n\n"

	text += "--- Recent Runs ---\n\n"

	# Mostra últimas 10 runs
	var recent = memories.slice(max(0, memories.size() - 10), memories.size())
	recent.reverse()

	for memory in recent:
		var status = "VICTORY" if memory.get("victory", false) else "DEFEAT"
		var corrupted_mark = " [CORRUPTED]" if memory.corrupted else ""

		text += "[" + status + "]" + corrupted_mark + "\n"
		text += "  Boss: " + memory.boss_name + "\n"
		text += "  Motivation: " + memory.boss_motivation + "\n"
		text += "  Level: " + str(memory.level_reached) + "\n"
		text += "  Seed: " + str(memory.seed) + "\n"
		text += "  Date: " + memory.timestamp + "\n\n"

	return text

func get_narrator_comment() -> String:
	"""Narrador procedural que comenta suas mortes"""
	if memories.is_empty():
		return "A new soul enters the cycle..."

	var last_memory = memories.back()

	if last_memory.get("victory", false):
		return "You triumphed before. Can you do it again?"

	# Comentários baseados em padrões
	var defeats = get_defeats()

	if defeats == 1:
		return "Death came swiftly. But you remember..."
	elif defeats < 5:
		return "Another fall. Another memory etched in your soul."
	elif defeats < 10:
		return "The cycle continues. How many times will you try?"
	elif defeats < 20:
		return "Persistence... or madness? You alone know the difference."
	else:
		return "You've died so many times... yet you return. Why?"

func get_npc_recognition_dialogue() -> String:
	"""NPCs sentem déjà vu do jogador"""
	if not has_memories():
		return ""

	var dialogues = [
		"Have we... met before? No, that's impossible.",
		"You seem familiar somehow. Strange.",
		"I dreamt of someone like you. How odd.",
		"Your eyes... they've seen things. Many things.",
		"There's an old soul behind those eyes."
	]

	return dialogues[randi() % dialogues.size()]
