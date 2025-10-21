extends Node

# World Generator - Gera mundos procedurais usando Perlin Noise

const WORLD_WIDTH = 100
const WORLD_HEIGHT = 100
const TILE_SIZE = 32

enum TileType {
	VOID,
	GRASS,
	FOREST,
	MOUNTAIN,
	WATER,
	VILLAGE,
	DUNGEON,
	BOSS_LAIR
}

var world_data = {}
var world_seed: int = 0
var is_corrupted: bool = false
var noise: FastNoiseLite
var tiles: Array = []

# Locações importantes
var spawn_point: Vector2
var villages: Array = []
var dungeons: Array = []
var boss_lair: Vector2
var npc_positions: Dictionary = {}
var enemy_spawn_points: Array = []
var miniboss_positions: Array = []
var shop_position: Vector2

func generate_world(seed: int, corrupted: bool = false):
	world_seed = seed
	is_corrupted = corrupted
	seed(world_seed)

	# Configura o gerador de ruído
	noise = FastNoiseLite.new()
	noise.seed = world_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05

	# Gera o terreno
	generate_terrain()

	# Gera locações especiais
	generate_locations()

	# Gera NPCs
	generate_npc_positions()

	# Gera inimigos
	generate_enemy_positions()

	# Monta os dados do mundo
	world_data = {
		"seed": world_seed,
		"corrupted": is_corrupted,
		"spawn": spawn_point,
		"villages": villages,
		"dungeons": dungeons,
		"boss_lair": boss_lair,
		"shop": shop_position,
		"npcs": npc_positions,
		"enemies": enemy_spawn_points,
		"minibosses": miniboss_positions,
		"tiles": tiles
	}

func generate_terrain():
	tiles = []

	for y in range(WORLD_HEIGHT):
		var row = []
		for x in range(WORLD_WIDTH):
			var noise_value = noise.get_noise_2d(x, y)

			# Em mundo corrompido, inverte alguns valores
			if is_corrupted:
				noise_value = -noise_value if randf() < 0.3 else noise_value

			var tile = get_tile_from_noise(noise_value)
			row.append(tile)

		tiles.append(row)

func get_tile_from_noise(value: float) -> TileType:
	if value < -0.4:
		return TileType.WATER
	elif value < -0.1:
		return TileType.GRASS
	elif value < 0.2:
		return TileType.FOREST
	elif value < 0.5:
		return TileType.MOUNTAIN
	else:
		return TileType.GRASS

func generate_locations():
	# Ponto de spawn (centro-ish)
	spawn_point = Vector2(WORLD_WIDTH / 2, WORLD_HEIGHT / 2)
	spawn_point += Vector2(randi_range(-5, 5), randi_range(-5, 5))

	# Boss lair (longe do spawn)
	var angle = randf() * TAU
	var distance = WORLD_WIDTH * 0.4
	boss_lair = spawn_point + Vector2(cos(angle), sin(angle)) * distance
	boss_lair = boss_lair.clamp(Vector2(5, 5), Vector2(WORLD_WIDTH - 5, WORLD_HEIGHT - 5))

	# Villages (3-5)
	var num_villages = randi_range(3, 5)
	for i in range(num_villages):
		var village_pos = get_random_grass_position()
		villages.append(village_pos)

	# Shop (em uma das vilas)
	if villages.size() > 0:
		shop_position = villages[0]

	# Dungeons (2-4)
	var num_dungeons = randi_range(2, 4)
	for i in range(num_dungeons):
		var dungeon_pos = get_random_position_far_from(spawn_point, 20)
		dungeons.append(dungeon_pos)

func generate_npc_positions():
	# NPCs fixos mas em posições diferentes
	var npc_archetypes = [
		"The Wanderer",
		"The Elder",
		"The Merchant",
		"The Hermit",
		"The Oracle",
		"The Knight",
		"The Bard"
	]

	for npc_name in npc_archetypes:
		# Coloca NPCs em vilas ou perto delas
		if villages.size() > 0:
			var village = villages[randi() % villages.size()]
			var offset = Vector2(randi_range(-3, 3), randi_range(-3, 3))
			npc_positions[npc_name] = village + offset
		else:
			npc_positions[npc_name] = get_random_grass_position()

func generate_enemy_positions():
	# Gera 20-30 pontos de spawn de inimigos
	var num_enemies = randi_range(20, 30)
	for i in range(num_enemies):
		var pos = get_random_position_far_from(spawn_point, 10)
		enemy_spawn_points.append(pos)

	# Minibosses (3-4)
	var miniboss_archetypes = [
		"The Hunter",
		"The Daughter of Mist",
		"The Vigilante",
		"The Corrupted Knight"
	]

	var num_minibosses = randi_range(3, 4)
	for i in range(num_minibosses):
		var archetype = miniboss_archetypes[i % miniboss_archetypes.size()]
		var pos = get_random_position_far_from(spawn_point, 25)

		miniboss_positions.append({
			"archetype": archetype,
			"position": pos,
			"level": randi_range(3, 7),
			"defeated": false
		})

func get_random_grass_position() -> Vector2:
	for attempt in range(100):
		var x = randi_range(5, WORLD_WIDTH - 5)
		var y = randi_range(5, WORLD_HEIGHT - 5)
		if tiles[y][x] == TileType.GRASS:
			return Vector2(x, y)

	# Fallback
	return Vector2(randi_range(5, WORLD_WIDTH - 5), randi_range(5, WORLD_HEIGHT - 5))

func get_random_position_far_from(center: Vector2, min_distance: float) -> Vector2:
	for attempt in range(100):
		var pos = get_random_grass_position()
		if pos.distance_to(center) >= min_distance:
			return pos

	# Fallback
	return get_random_grass_position()

func get_tile_at(x: int, y: int) -> TileType:
	if x < 0 or x >= WORLD_WIDTH or y < 0 or y >= WORLD_HEIGHT:
		return TileType.VOID

	return tiles[y][x]

func is_walkable(x: int, y: int) -> bool:
	var tile = get_tile_at(x, y)
	return tile in [TileType.GRASS, TileType.FOREST, TileType.VILLAGE]
