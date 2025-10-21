extends Node

# Narrative Generator - Gera narrativas procedurais baseadas em motivações

var boss_data = {}
var world_motivation: String = ""
var narrative_seed: int = 0

# Motivações possíveis
var motivations = [
	"WAR",      # Guerra antiga
	"LOVE",     # Amor perdido
	"PLAGUE",   # Praga/doença
	"OBSESSION", # Obsessão por poder
	"GRIEF",    # Luto profundo
	"REVENGE",  # Vingança
	"MADNESS",  # Loucura
	"AMBITION"  # Ambição desmedida
]

# Nomes de bosses procedurais
var boss_name_prefixes = [
	"Lord", "Lady", "The Fallen", "The Cursed", "The Eternal",
	"The Forgotten", "The Last", "The First", "The Doomed"
]

var boss_name_suffixes = [
	"Shadow", "Light", "Void", "Dawn", "Dusk",
	"Sorrow", "Wrath", "Memory", "Echo", "Silence"
]

# Diálogos por motivação
var boss_dialogues = {
	"WAR": [
		"This war... it never truly ended. Not in my heart.",
		"They took everything from me. Now I take from them.",
		"Peace is a lie. Only conflict reveals truth."
	],
	"LOVE": [
		"I would burn this world to bring them back...",
		"You don't understand what loss truly means.",
		"Love is the cruelest curse of all."
	],
	"PLAGUE": [
		"The sickness spreads... and I am its herald.",
		"Why should I be the only one to suffer?",
		"This plague is mercy compared to what awaits."
	],
	"OBSESSION": [
		"Power... absolute power... so close now...",
		"Nothing will stand between me and godhood.",
		"You cannot comprehend my vision!"
	],
	"GRIEF": [
		"The pain... it never fades... never...",
		"I cannot move forward. I will not.",
		"Join me in this eternal mourning."
	],
	"REVENGE": [
		"They will all pay. Every. Single. One.",
		"Vengeance is all I have left.",
		"Your world will burn as mine did."
	],
	"MADNESS": [
		"Do you hear them too? The voices?",
		"Reality is just a suggestion... hehehehe...",
		"Sanity is overrated, don't you think?"
	],
	"AMBITION": [
		"I will reshape this world in my image!",
		"Destiny chose me. Who are you to deny it?",
		"Greatness demands sacrifice. Yours."
	]
}

# Fragmentos de história por motivação
var lore_fragments = {
	"WAR": "Long ago, a great war tore this land apart. Kingdoms fell, heroes died, and {boss_name} lost everything.",
	"LOVE": "{boss_name} once loved deeply. But death claimed their beloved, and grief consumed what remained.",
	"PLAGUE": "A terrible plague swept the land. {boss_name} survived, but was forever changed by the affliction.",
	"OBSESSION": "The pursuit of forbidden knowledge drove {boss_name} to madness and power beyond mortal ken.",
	"GRIEF": "Unable to accept their loss, {boss_name} sought to halt time itself, freezing the world in endless sorrow.",
	"REVENGE": "Betrayed by those they trusted most, {boss_name} swore an oath of vengeance that transcends death.",
	"MADNESS": "The whispers from beyond broke {boss_name}'s mind, transforming them into something... other.",
	"AMBITION": "{boss_name} believed themselves chosen by fate to rule all. None could convince them otherwise."
}

func generate_narrative(seed: int, is_corrupted: bool = false):
	narrative_seed = seed
	seed(narrative_seed)

	# Escolhe motivação baseada na seed
	var motivation_index = narrative_seed % motivations.size()
	world_motivation = motivations[motivation_index]

	# Em mundo corrompido, pode escolher motivação aleatória
	if is_corrupted:
		world_motivation = motivations[randi() % motivations.size()]

	# Gera nome do boss
	var boss_name = generate_boss_name()

	# Gera stats do boss
	var boss_stats = generate_boss_stats(is_corrupted)

	# Monta dados do boss
	boss_data = {
		"name": boss_name,
		"motivation": world_motivation,
		"hp": boss_stats.hp,
		"max_hp": boss_stats.hp,
		"attack": boss_stats.attack,
		"defense": boss_stats.defense,
		"dialogues": boss_dialogues[world_motivation].duplicate(),
		"lore": lore_fragments[world_motivation].replace("{boss_name}", boss_name),
		"corrupted": is_corrupted,
		"phases": generate_boss_phases(is_corrupted)
	}

func generate_boss_name() -> String:
	var prefix = boss_name_prefixes[randi() % boss_name_prefixes.size()]
	var suffix = boss_name_suffixes[randi() % boss_name_suffixes.size()]

	# Às vezes só usa o sufixo
	if randf() < 0.3:
		return suffix

	return prefix + " " + suffix

func generate_boss_stats(is_corrupted: bool) -> Dictionary:
	var base_hp = 200
	var base_attack = 20
	var base_defense = 10

	if is_corrupted:
		base_hp = int(base_hp * 1.5)
		base_attack = int(base_attack * 1.3)
		base_defense = int(base_defense * 1.2)

	return {
		"hp": base_hp + randi_range(-20, 20),
		"attack": base_attack + randi_range(-3, 3),
		"defense": base_defense + randi_range(-2, 2)
	}

func generate_boss_phases(is_corrupted: bool) -> Array:
	# Boss tem fases diferentes baseadas na vida
	var phases = []

	phases.append({
		"threshold": 1.0,
		"dialogue": "So... you've come to challenge me.",
		"attack_multiplier": 1.0
	})

	phases.append({
		"threshold": 0.66,
		"dialogue": boss_dialogues[world_motivation][0],
		"attack_multiplier": 1.2
	})

	phases.append({
		"threshold": 0.33,
		"dialogue": boss_dialogues[world_motivation][1],
		"attack_multiplier": 1.5
	})

	if is_corrupted:
		phases.append({
			"threshold": 0.1,
			"dialogue": "THIS WORLD IS MINE TO CORRUPT!",
			"attack_multiplier": 2.0
		})

	return phases

func get_boss_dialogue_for_hp_percent(hp_percent: float) -> String:
	for phase in boss_data.phases:
		if hp_percent <= phase.threshold:
			return phase.dialogue

	return ""

func generate_npc_dialogue(npc_name: String, has_met_before: bool = false) -> Array:
	var dialogues = []

	# Diálogos sobre o mundo atual
	match world_motivation:
		"WAR":
			dialogues.append("These are dark times... war's shadow still looms.")
		"LOVE":
			dialogues.append("Love can be beautiful... or devastating.")
		"PLAGUE":
			dialogues.append("The sickness spread far. Many were lost.")
		"OBSESSION":
			dialogues.append("Beware those who seek power at any cost.")
		"GRIEF":
			dialogues.append("Some cannot let go of the past...")
		"REVENGE":
			dialogues.append("Hatred breeds only more hatred.")
		"MADNESS":
			dialogues.append("I hear whispers sometimes... do you?")
		"AMBITION":
			dialogues.append("Ambition without wisdom leads to ruin.")

	# Se já conheceu o jogador em runs anteriores
	if has_met_before and MemorySystem.has_memories():
		dialogues.append("You... I feel I've seen you before. But when?")
		dialogues.append("There's something familiar about you...")

	# Diálogo sobre o boss
	dialogues.append("They say " + boss_data.name + " guards the heart of this realm.")
	dialogues.append(boss_data.lore)

	return dialogues
