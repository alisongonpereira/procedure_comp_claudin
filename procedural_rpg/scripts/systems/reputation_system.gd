extends Node

# Reputation System - Sistema de reputação com NPCs (BONUS)

var npc_reputations: Dictionary = {}

enum ReputationLevel {
	HOSTILE = -2,
	UNFRIENDLY = -1,
	NEUTRAL = 0,
	FRIENDLY = 1,
	ALLIED = 2
}

func _ready():
	# Inicializa reputações
	for npc_name in ["The Wanderer", "The Elder", "The Merchant", "The Hermit", "The Oracle", "The Knight", "The Bard"]:
		npc_reputations[npc_name] = 0

func get_reputation(npc_name: String) -> int:
	return npc_reputations.get(npc_name, 0)

func modify_reputation(npc_name: String, amount: int):
	if npc_name in npc_reputations:
		npc_reputations[npc_name] = clamp(npc_reputations[npc_name] + amount, -100, 100)
		print(npc_name, " reputation: ", npc_reputations[npc_name])

func get_reputation_level(npc_name: String) -> ReputationLevel:
	var rep = get_reputation(npc_name)

	if rep >= 50:
		return ReputationLevel.ALLIED
	elif rep >= 20:
		return ReputationLevel.FRIENDLY
	elif rep <= -50:
		return ReputationLevel.HOSTILE
	elif rep <= -20:
		return ReputationLevel.UNFRIENDLY
	else:
		return ReputationLevel.NEUTRAL

func get_reputation_text(npc_name: String) -> String:
	var level = get_reputation_level(npc_name)

	match level:
		ReputationLevel.HOSTILE:
			return "Hostile"
		ReputationLevel.UNFRIENDLY:
			return "Unfriendly"
		ReputationLevel.NEUTRAL:
			return "Neutral"
		ReputationLevel.FRIENDLY:
			return "Friendly"
		ReputationLevel.ALLIED:
			return "Allied"
		_:
			return "Unknown"

func get_price_modifier(npc_name: String) -> float:
	"""NPCs amigáveis vendem mais barato"""
	var level = get_reputation_level(npc_name)

	match level:
		ReputationLevel.HOSTILE:
			return 2.0
		ReputationLevel.UNFRIENDLY:
			return 1.5
		ReputationLevel.NEUTRAL:
			return 1.0
		ReputationLevel.FRIENDLY:
			return 0.8
		ReputationLevel.ALLIED:
			return 0.6
		_:
			return 1.0

func get_special_dialogue(npc_name: String) -> String:
	"""NPCs com alta reputação dão dicas especiais"""
	var level = get_reputation_level(npc_name)

	if level == ReputationLevel.ALLIED:
		return "You've been a true friend. Here's something that might help..."
	elif level == ReputationLevel.FRIENDLY:
		return "I trust you. Let me share what I know..."
	elif level == ReputationLevel.HOSTILE:
		return "I have nothing to say to you."

	return ""
