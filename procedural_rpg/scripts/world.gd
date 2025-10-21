extends Node2D

# World - Gerencia o mundo procedural

const TILE_SIZE = 32

@onready var tilemap = $TileMap
@onready var npcs_container = $NPCs
@onready var enemies_container = $Enemies
@onready var player = $Player
@onready var combat_ui = $CanvasLayer/CombatUI
@onready var combat_log = $CanvasLayer/CombatUI/VBoxContainer/CombatLog
@onready var enemy_info_label = $CanvasLayer/CombatUI/VBoxContainer/EnemyInfo
@onready var player_info_label = $CanvasLayer/CombatUI/VBoxContainer/PlayerInfo

var combat_system: Node

func _ready():
	# Cria instância do sistema de combate
	combat_system = load("res://scripts/systems/combat_system.gd").new()
	add_child(combat_system)

	# Conecta sinais
	combat_system.combat_log.connect(_on_combat_log)
	combat_system.player_turn.connect(_on_player_turn)
	combat_system.combat_ended.connect(_on_combat_ended)
	GameManager.combat_started.connect(_on_combat_started)
	GameManager.game_state_changed.connect(_on_game_state_changed)

	# Gera o mundo visualmente
	generate_tilemap()
	spawn_npcs()
	spawn_enemies()

	print("=== WORLD LOADED ===")
	print("Seed: ", GameManager.current_seed)
	print("Corrupted: ", GameManager.is_corrupted_world)
	print("Boss: ", NarrativeGenerator.boss_data.name)

	# Auto-save a cada 30 segundos
	var save_timer = Timer.new()
	save_timer.wait_time = 30.0
	save_timer.autostart = true
	save_timer.timeout.connect(func(): SaveSystem.save_game())
	add_child(save_timer)

func generate_tilemap():
	# Gera tiles visuais baseado nos dados do WorldGenerator
	# Como não temos tileset real, vamos usar ColorRect como placeholder

	for y in range(WorldGenerator.WORLD_HEIGHT):
		for x in range(WorldGenerator.WORLD_WIDTH):
			var tile_type = WorldGenerator.get_tile_at(x, y)

			# Cria visual do tile (placeholder)
			var tile_visual = ColorRect.new()
			tile_visual.size = Vector2(TILE_SIZE, TILE_SIZE)
			tile_visual.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)

			match tile_type:
				WorldGenerator.TileType.GRASS:
					tile_visual.color = Color(0.3, 0.6, 0.3)
				WorldGenerator.TileType.FOREST:
					tile_visual.color = Color(0.2, 0.4, 0.2)
				WorldGenerator.TileType.MOUNTAIN:
					tile_visual.color = Color(0.5, 0.5, 0.5)
				WorldGenerator.TileType.WATER:
					tile_visual.color = Color(0.2, 0.4, 0.8)
				WorldGenerator.TileType.VILLAGE:
					tile_visual.color = Color(0.7, 0.6, 0.4)
				_:
					tile_visual.color = Color(0.1, 0.1, 0.1)

			tilemap.add_child(tile_visual)

	# Marca locações especiais
	mark_special_location(WorldGenerator.boss_lair, Color(0.8, 0.1, 0.1))
	for village in WorldGenerator.villages:
		mark_special_location(village, Color(0.8, 0.7, 0.4))

func mark_special_location(pos: Vector2, color: Color):
	var marker = ColorRect.new()
	marker.size = Vector2(TILE_SIZE, TILE_SIZE)
	marker.position = pos * TILE_SIZE
	marker.color = color
	tilemap.add_child(marker)

func spawn_npcs():
	for npc_name in WorldGenerator.npc_positions:
		var npc_pos = WorldGenerator.npc_positions[npc_name]
		var npc = create_npc_placeholder(npc_name, npc_pos)
		npcs_container.add_child(npc)

func spawn_enemies():
	# Spawn alguns inimigos visíveis
	for i in range(min(10, WorldGenerator.enemy_spawn_points.size())):
		var enemy_pos = WorldGenerator.enemy_spawn_points[i]
		var enemy = create_enemy_placeholder(enemy_pos)
		enemies_container.add_child(enemy)

	# Spawn minibosses
	for miniboss_data in WorldGenerator.miniboss_positions:
		var miniboss = create_miniboss_placeholder(miniboss_data)
		enemies_container.add_child(miniboss)

func create_npc_placeholder(npc_name: String, pos: Vector2) -> Node2D:
	var npc = Node2D.new()
	npc.position = pos * TILE_SIZE

	var visual = ColorRect.new()
	visual.size = Vector2(TILE_SIZE - 4, TILE_SIZE - 4)
	visual.position = Vector2(2, 2)
	visual.color = Color(0.2, 0.8, 0.9)
	npc.add_child(visual)

	var label = Label.new()
	label.text = npc_name[0]  # Primeira letra
	label.position = Vector2(8, 8)
	npc.add_child(label)

	return npc

func create_enemy_placeholder(pos: Vector2) -> Node2D:
	var enemy = Node2D.new()
	enemy.position = pos * TILE_SIZE

	var visual = ColorRect.new()
	visual.size = Vector2(TILE_SIZE - 4, TILE_SIZE - 4)
	visual.position = Vector2(2, 2)
	visual.color = Color(0.9, 0.3, 0.3)
	enemy.add_child(visual)

	return enemy

func create_miniboss_placeholder(data: Dictionary) -> Node2D:
	var miniboss = Node2D.new()
	miniboss.position = data.position * TILE_SIZE

	var visual = ColorRect.new()
	visual.size = Vector2(TILE_SIZE * 1.5, TILE_SIZE * 1.5)
	visual.color = Color(0.9, 0.1, 0.5)
	miniboss.add_child(visual)

	var label = Label.new()
	label.text = "MB"
	label.position = Vector2(8, 8)
	miniboss.add_child(label)

	return miniboss

func _on_combat_started(enemy_data: Dictionary):
	var is_boss = "lore" in enemy_data
	combat_system.start_combat(enemy_data, is_boss)
	combat_ui.visible = true
	update_combat_ui()

func _on_combat_log(message: String):
	combat_log.append_text(message + "\n")
	update_combat_ui()

func _on_player_turn():
	# Habilita botões de ação
	pass

func _on_combat_ended(victory: bool):
	combat_ui.visible = false
	combat_log.clear()

func _on_game_state_changed(new_state):
	match new_state:
		GameManager.GameState.COMBAT:
			combat_ui.visible = true
		GameManager.GameState.EXPLORING:
			combat_ui.visible = false

func update_combat_ui():
	if combat_system.is_in_combat:
		var enemy = combat_system.current_enemy
		enemy_info_label.text = enemy.name + "\nHP: " + str(enemy.hp) + "/" + str(enemy.max_hp)

	player_info_label.text = "You (Lv." + str(GameManager.player_data.level) + ")\n"
	player_info_label.text += "HP: " + str(GameManager.player_data.hp) + "/" + str(GameManager.player_data.max_hp)

func _on_attack_button_pressed():
	combat_system.player_attack()

func _on_defend_button_pressed():
	combat_system.player_defend()

func _on_item_button_pressed():
	# TODO: Abrir menu de itens
	pass

func _on_flee_button_pressed():
	combat_system.player_flee()
