extends CharacterBody2D

# Player - Controlado pelo jogador, se lembra de tudo

const SPEED = 200.0
const TILE_SIZE = 32

var grid_position: Vector2 = Vector2.ZERO
var is_moving = false
var movement_direction = Vector2.ZERO

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
	# Posiciona no spawn point
	grid_position = WorldGenerator.spawn_point
	position = grid_position * TILE_SIZE
	GameManager.player_data.position = grid_position

func _physics_process(delta):
	if GameManager.current_state != GameManager.GameState.EXPLORING:
		return

	if not is_moving:
		handle_input()

	if is_moving:
		move_smoothly(delta)

func handle_input():
	var input_direction = Vector2.ZERO

	if Input.is_action_just_pressed("move_up"):
		input_direction = Vector2.UP
	elif Input.is_action_just_pressed("move_down"):
		input_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("move_left"):
		input_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("move_right"):
		input_direction = Vector2.RIGHT

	if input_direction != Vector2.ZERO:
		try_move(input_direction)

	# Outras ações
	if Input.is_action_just_pressed("open_inventory"):
		open_inventory()

	if Input.is_action_just_pressed("open_diary"):
		open_diary()

func try_move(direction: Vector2):
	var target_grid = grid_position + direction

	# Verifica se pode andar
	if WorldGenerator.is_walkable(int(target_grid.x), int(target_grid.y)):
		movement_direction = direction
		is_moving = true
		grid_position = target_grid
		GameManager.player_data.position = grid_position

		# Atualiza orientação do sprite
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false

		# Verifica encontros aleatórios
		check_random_encounter()

func move_smoothly(delta):
	var target_position = grid_position * TILE_SIZE
	position = position.move_toward(target_position, SPEED * delta)

	if position.distance_to(target_position) < 1:
		position = target_position
		is_moving = false
		check_interactions()

func check_random_encounter():
	# 10% de chance de encontro aleatório em cada movimento
	if randf() < 0.1:
		trigger_combat()

func check_interactions():
	# Verifica NPCs próximos
	for npc_name in WorldGenerator.npc_positions:
		var npc_pos = WorldGenerator.npc_positions[npc_name]
		if grid_position.distance_to(npc_pos) < 2:
			# Mostra indicador de interação
			if Input.is_action_just_pressed("interact"):
				interact_with_npc(npc_name)

	# Verifica boss lair
	if grid_position.distance_to(WorldGenerator.boss_lair) < 3:
		if Input.is_action_just_pressed("interact"):
			trigger_boss_fight()

	# Verifica loja
	if grid_position.distance_to(WorldGenerator.shop_position) < 2:
		if Input.is_action_just_pressed("interact"):
			open_shop()

func interact_with_npc(npc_name: String):
	var has_met = npc_name in GameManager.met_npcs
	var dialogues = NarrativeGenerator.generate_npc_dialogue(npc_name, has_met)

	if not has_met:
		GameManager.met_npcs.append(npc_name)

	# Adiciona eco de runs anteriores
	if MemorySystem.has_memories() and randf() < 0.3:
		dialogues.append(MemorySystem.get_npc_recognition_dialogue())

	# TODO: Mostrar diálogo na UI
	print("=== ", npc_name, " ===")
	for dialogue in dialogues:
		print(dialogue)

func trigger_combat():
	# Gera inimigo aleatório
	var enemy_data = generate_random_enemy()
	GameManager.combat_started.emit(enemy_data)
	print("Combat started with: ", enemy_data.name)

func trigger_boss_fight():
	print("=== BOSS FIGHT ===")
	print(NarrativeGenerator.boss_data.name)
	print(NarrativeGenerator.boss_data.lore)
	GameManager.combat_started.emit(NarrativeGenerator.boss_data)

func open_shop():
	# TODO: Implementar UI de loja
	print("=== SHOP ===")
	print("Welcome, traveler!")

func open_inventory():
	GameManager.change_state(GameManager.GameState.INVENTORY)
	print("=== INVENTORY ===")
	print("Gold: ", GameManager.player_data.gold)
	print("Items: ", GameManager.inventory.size())

func open_diary():
	GameManager.change_state(GameManager.GameState.DIARY)
	print(MemorySystem.get_memories_text())
	print(MemorySystem.get_narrator_comment())

func generate_random_enemy() -> Dictionary:
	var enemy_types = ["Slime", "Goblin", "Skeleton", "Wolf", "Bandit"]
	var enemy_name = enemy_types[randi() % enemy_types.size()]

	var level_variance = randi_range(-1, 2)
	var enemy_level = max(1, GameManager.player_data.level + level_variance)

	return {
		"name": enemy_name,
		"level": enemy_level,
		"hp": 30 + (enemy_level * 10),
		"max_hp": 30 + (enemy_level * 10),
		"attack": 5 + (enemy_level * 2),
		"defense": 2 + enemy_level,
		"exp_reward": 20 + (enemy_level * 5),
		"gold_reward": 10 + (enemy_level * 3)
	}
