extends CharacterBody2D

# Enemy - Inimigos regulares e minibosses

var enemy_data: Dictionary = {}
var is_miniboss: bool = false
var grid_position: Vector2 = Vector2.ZERO

@onready var sprite = $Sprite2D
@onready var label = $Label

func setup(data: Dictionary, miniboss: bool = false):
	enemy_data = data
	is_miniboss = miniboss

	if "position" in data:
		grid_position = data.position
		position = grid_position * 32

	if label:
		label.text = data.get("name", "Enemy")

	# Minibosses são maiores
	if is_miniboss:
		scale = Vector2(1.5, 1.5)

func on_player_nearby(player_pos: Vector2):
	# Se jogador está perto, pode iniciar combate
	if grid_position.distance_to(player_pos) < 2:
		return true
	return false
