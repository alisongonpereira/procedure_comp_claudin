extends Node

# Narrator System - Narrador procedural que comenta suas ações (BONUS)

var last_death_count: int = 0
var consecutive_deaths: int = 0
var current_run_kills: int = 0

# Comentários baseados em eventos
var death_comments = [
	"Another soul claimed by the void...",
	"Death is but a doorway. You know this well.",
	"How many times now? Do you even remember?",
	"The cycle continues, endless and cruel.",
	"Yet you persist. Admirable... or foolish?",
	"Your determination borders on madness.",
	"Even death cannot erase your memories.",
	"You carry the weight of many lifetimes.",
	"Some would call this hell. You call it purpose.",
	"The boss remembers you not. But you remember them."
]

var victory_comments = [
	"Victory! But at what cost?",
	"The boss falls... this time.",
	"You've broken the cycle. For now.",
	"Freedom, at last. Until the next world calls.",
	"The memories you carry grow heavier with each triumph.",
	"You alone remember this victory. Treasure it.",
	"Another world saved. Another memory etched in your soul.",
	"The boss is defeated, but their story echoes in your mind."
]

var level_up_comments = [
	"Stronger than before. But is it enough?",
	"Power grows, but so does the challenge ahead.",
	"Each level brings you closer... or so you hope.",
	"You evolve, as you must."
]

var boss_encounter_comments = [
	"Here, at last. The heart of it all.",
	"They don't know you. But you know them.",
	"Face to face with destiny, once more.",
	"This has happened before. It will happen again.",
	"The final test begins anew."
]

var rare_event_comments = [
	"The world itself feels... different this time.",
	"Something stirs in the fabric of reality.",
	"This is no ordinary cycle.",
	"Pay attention. This moment is unique."
]

func on_player_death():
	consecutive_deaths += 1
	var comment = death_comments[randi() % death_comments.size()]

	# Comentários especiais baseados em padrões
	if consecutive_deaths >= 5:
		comment = "Five times you've fallen. Will you rise a sixth?"
	elif consecutive_deaths >= 10:
		comment = "Ten deaths... and still you refuse to give up."

	print("\n[NARRATOR] ", comment, "\n")
	return comment

func on_victory():
	consecutive_deaths = 0
	var comment = victory_comments[randi() % victory_comments.size()]
	print("\n[NARRATOR] ", comment, "\n")
	return comment

func on_level_up():
	var comment = level_up_comments[randi() % level_up_comments.size()]
	print("\n[NARRATOR] ", comment, "\n")
	return comment

func on_boss_encounter():
	var comment = boss_encounter_comments[randi() % boss_encounter_comments.size()]

	# Comentário especial se já derrotou esse boss antes
	if MemorySystem.has_faced_boss(NarrativeGenerator.boss_data.name):
		comment = "You've faced " + NarrativeGenerator.boss_data.name + " before. Do they remember?"

	print("\n[NARRATOR] ", comment, "\n")
	return comment

func on_rare_event():
	var comment = rare_event_comments[randi() % rare_event_comments.size()]
	print("\n[NARRATOR] ", comment, "\n")
	return comment

func on_corrupted_world():
	print("\n[NARRATOR] The world is wrong. Twisted. Corrupted. Proceed with caution.\n")
	return "The world is wrong. Twisted. Corrupted."

func on_kill_enemy():
	current_run_kills += 1

func get_run_summary() -> String:
	var summary = "\n=== END OF RUN ===\n"
	summary += "Enemies defeated: " + str(current_run_kills) + "\n"
	summary += "Level reached: " + str(GameManager.player_data.level) + "\n"
	summary += "Gold earned: " + str(GameManager.player_data.gold) + "\n"
	summary += "\n[NARRATOR] " + death_comments[randi() % death_comments.size()] + "\n"

	current_run_kills = 0

	return summary
