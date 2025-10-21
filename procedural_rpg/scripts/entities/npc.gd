extends CharacterBody2D

# NPC - Personagens com nomes fixos mas localizações e diálogos diferentes

@export var npc_name: String = "Wanderer"
@export var has_shop: bool = false

var grid_position: Vector2 = Vector2.ZERO
var dialogues: Array = []
var has_met_player: bool = false

@onready var sprite = $Sprite2D
@onready var label = $Label

func _ready():
	if label:
		label.text = npc_name

func setup(name: String, position: Vector2, is_shop: bool = false):
	npc_name = name
	grid_position = position
	has_shop = is_shop
	position = grid_position * 32

	# Gera diálogos
	dialogues = NarrativeGenerator.generate_npc_dialogue(npc_name, has_met_player)

func interact():
	has_met_player = true

	# Adiciona à lista de NPCs conhecidos
	if not npc_name in GameManager.met_npcs:
		GameManager.met_npcs.append(npc_name)

	# Re-gera diálogos com memórias
	dialogues = NarrativeGenerator.generate_npc_dialogue(npc_name, has_met_player)

	return dialogues

func get_reputation_modifier() -> float:
	# Sistema de reputação (bônus)
	# TODO: Implementar sistema completo de reputação
	return 1.0
