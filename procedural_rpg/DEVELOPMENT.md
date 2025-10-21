# 🛠️ Guia de Desenvolvimento - Echoes of Memory

Este documento é para desenvolvedores que querem entender, modificar ou expandir o jogo.

---

## 🏗️ Arquitetura

### Padrão: Autoload Singletons

O jogo usa o padrão de **Autoload (Singletons)** do Godot para sistemas globais:

```
GameManager      → Estado global do jogo
WorldGenerator   → Geração de mundos
NarrativeGenerator → Geração de narrativas
SaveSystem       → Persistência de dados
MemorySystem     → Memórias entre runs
```

**Vantagens:**
- Acesso global de qualquer script
- Estado persistente durante a sessão
- Fácil comunicação entre sistemas

### Fluxo de Dados

```
Menu Principal
    ↓
GameManager.start_new_game(seed)
    ↓
WorldGenerator.generate_world(seed)
    ↓
NarrativeGenerator.generate_narrative(seed)
    ↓
World Scene carregada
    ↓
Player spawna
    ↓
Loop de gameplay
```

---

## 📂 Estrutura de Scripts

### Sistemas (`scripts/systems/`)

**game_manager.gd**
- Gerencia estado global
- Player data
- Inventory
- Combat signals
- Game states (EXPLORING, COMBAT, etc.)

**world_generator.gd**
- Gera terreno com Perlin Noise
- Posiciona NPCs, enemies, boss
- Calcula locações especiais
- Fornece dados para renderização

**narrative_generator.gd**
- Escolhe motivação do boss
- Gera nome e lore procedural
- Cria diálogos contextuais
- Gera fases do boss

**save_system.gd**
- Save/Load de jogo
- Persistência entre sessões
- Export de world log (JSON)

**memory_system.gd**
- Registra runs
- Calcula estatísticas
- Gera texto de memórias
- Detecta padrões (bosses enfrentados, etc.)

**combat_system.gd**
- Lógica de combate por turnos
- Cálculo de dano
- Sistema de críticos
- Gerencia fases do boss

**weather_system.gd** (BONUS)
- Gera clima procedural
- Modifica encounter rate
- Modifica damage

**reputation_system.gd** (BONUS)
- Tracking de reputação por NPC
- Modificadores de preço
- Diálogos especiais

**narrator_system.gd** (BONUS)
- Comentários procedurais
- Detecção de padrões
- Mensagens contextuais

---

## 🔧 Como Adicionar...

### Nova Motivação de Boss

1. Abra `narrative_generator.gd`
2. Adicione à lista `motivations`:
```gdscript
var motivations = [
    "WAR",
    "LOVE",
    # ...
    "NOVA_MOTIVACAO"
]
```

3. Adicione diálogos:
```gdscript
var boss_dialogues = {
    "NOVA_MOTIVACAO": [
        "Diálogo 1...",
        "Diálogo 2...",
        "Diálogo 3..."
    ]
}
```

4. Adicione lore:
```gdscript
var lore_fragments = {
    "NOVA_MOTIVACAO": "História do boss com {boss_name}..."
}
```

---

### Novo Tipo de Terreno

1. Abra `world_generator.gd`
2. Adicione ao enum:
```gdscript
enum TileType {
    # ...
    NOVO_TERRENO
}
```

3. Adicione lógica em `get_tile_from_noise()`:
```gdscript
func get_tile_from_noise(value: float) -> TileType:
    # ...
    elif value < 0.7:
        return TileType.NOVO_TERRENO
    # ...
```

4. Adicione visual em `world.gd` → `generate_tilemap()`:
```gdscript
WorldGenerator.TileType.NOVO_TERRENO:
    tile_visual.color = Color(...)
```

---

### Novo NPC

1. Abra `world_generator.gd`
2. Adicione nome em `generate_npc_positions()`:
```gdscript
var npc_archetypes = [
    # ...
    "Novo NPC"
]
```

3. NPC será automaticamente posicionado proceduralmente
4. Diálogos são gerados em `narrative_generator.gd`

---

### Novo Item

1. Abra `data/item_database.json`
2. Adicione ao array apropriado:
```json
{
    "id": "novo_item",
    "name": "Nome do Item",
    "type": "healing|weapon|armor|treasure",
    "value": 10,
    "rarity": "common|uncommon|rare|legendary",
    "price": 50,
    "description": "Descrição..."
}
```

3. Se necessário, adicione lógica especial em `combat_system.gd` → `player_use_item()`

---

### Novo Tipo de Clima

1. Abra `weather_system.gd`
2. Adicione ao enum:
```gdscript
enum Weather {
    # ...
    NOVO_CLIMA
}
```

3. Adicione efeitos:
```gdscript
var weather_effects = {
    Weather.NOVO_CLIMA: {
        "encounter_rate": 1.5,
        "visibility": 0.8,
        "damage_mod": 1.1,
        "rare": false
    }
}
```

4. Adicione chance em `initialize()`:
```gdscript
elif weather_roll < 0.XX:
    current_weather = Weather.NOVO_CLIMA
```

---

## 🧪 Testing

### Testar Seed Específica

No menu principal:
1. Digite a seed no campo
2. Clique em "Start with Seed"
3. Mundo será sempre o mesmo

### Testar Mundo Corrompido

Para forçar mundo corrompido (debug):

Abra `game_manager.gd` → `start_new_game()`:
```gdscript
# Temporário: força mundo corrompido
is_corrupted_world = true  # ao invés de randf() < 0.05
```

### Testar Clima Raro

Abra `weather_system.gd` → `initialize()`:
```gdscript
# Temporário: força blood moon
current_weather = Weather.BLOODMOON
```

### Testar Boss Direto

No `player.gd`, adicione temporariamente no `_ready()`:
```gdscript
# Debug: teleporta para boss
grid_position = WorldGenerator.boss_lair
```

---

## 🎨 Adicionar Assets Reais

### Sprites

1. Crie sprites 32x32 pixels
2. Salve em `assets/sprites/`
3. Importe no Godot (auto)
4. Configure cenas:

**player.tscn:**
```
[node name="Sprite2D"]
texture = ExtResource("res://assets/sprites/player.png")
```

### Tileset

1. Crie tileset 32x32 (grass, water, etc.)
2. No Godot: Scene → TileMap → Create TileSet
3. Configure colisões
4. Substitua ColorRect por TileMap real em `world.gd`

### Música

1. Adicione .ogg ou .mp3 em `assets/audio/`
2. Crie AudioStreamPlayer em cena
3. Configure autoplay

---

## 🐛 Debug Tools

### Print de Debug

Ative verbose logging:
```gdscript
print("=== DEBUG ===")
print("Seed: ", GameManager.current_seed)
print("Boss: ", NarrativeGenerator.boss_data)
print("Player pos: ", player.grid_position)
```

### Godot Debugger

1. Run → Debug (F5)
2. Debugger tab → Output
3. Veja todos os prints
4. Breakpoints: clique na linha

### Export World Log

No jogo, chame:
```gdscript
var log = SaveSystem.export_world_log()
print(log)
```

Retorna JSON com todos os dados do mundo.

---

## 🚀 Performance

### Otimizações Implementadas

- ✅ Tiles como ColorRect (leve)
- ✅ Limite de inimigos visíveis (10)
- ✅ Auto-save throttled (30s)
- ✅ Rendering method: Mobile
- ✅ No physics desnecessário

### Se Performance Ficar Baixa

1. **Reduzir tamanho do mundo:**
```gdscript
# world_generator.gd
const WORLD_WIDTH = 50   # de 100
const WORLD_HEIGHT = 50  # de 100
```

2. **Reduzir inimigos spawn:**
```gdscript
# world_generator.gd → generate_enemy_positions()
var num_enemies = randi_range(10, 15)  # de 20-30
```

3. **Desabilitar clima:**
Remova WeatherSystem do autoload.

---

## 📱 Mobile Considerations

### Touch Controls (TODO)

Para adicionar controles touch:

1. Crie scene `touch_controls.tscn`
2. Adicione TextureButton para cada direção
3. Conecte sinais:
```gdscript
func _on_up_pressed():
    Input.action_press("move_up")
```

4. Adicione à CanvasLayer no `world.tscn`

### Screen Sizes

Jogo usa canvas_items stretch mode:
- Automaticamente adapta a diferentes resoluções
- UI escala proporcionalmente

### Battery Optimization

Considere adicionar:
- FPS cap (60 ou 30)
- Pause quando app em background
- Reduzir partículas/effects

---

## 🔐 Security

### Save File

Saves ficam em:
- **Android:** `/data/data/com.arenaia.echoesofmemory/files/`
- **Desktop:** `~/.local/share/godot/app_userdata/Echoes of Memory/`

Para criptografar:
```gdscript
# save_system.gd
# Usar FileAccess.open_encrypted() ao invés de open()
```

---

## 🌐 Multiplayer (Futuro)

### Seed Sharing

Já implementado! Seeds são reproduzíveis.

Para adicionar leaderboards:
1. Setup backend (Firebase, Supabase, etc.)
2. Enviar: seed, score, timestamp
3. Query top scores por seed

### Async Multiplayer

Ideias:
- Compartilhar ghost runs
- Ver onde outros players morreram
- Mensagens deixadas em locações

---

## 📊 Analytics (Opcional)

### Métricas Úteis

- Seeds mais jogadas
- Taxa de vitória por motivação
- Level médio alcançado
- Mundos corrompidos vs normal
- Taxa de uso de itens
- NPCs mais visitados

### Implementação

Use GodotFirebase ou similar:
```gdscript
# Ao morrer
Analytics.log_event("player_death", {
    "seed": GameManager.current_seed,
    "level": GameManager.player_data.level,
    "boss": NarrativeGenerator.boss_data.name
})
```

---

## 🎓 Recursos de Aprendizado

### Godot Docs
- https://docs.godotengine.org/en/stable/
- Especialmente: Autoloads, Signals, Scenes

### Procedural Generation
- "Procedural Generation in Game Design" (livro)
- GDC talks sobre proc-gen
- /r/proceduralgeneration

### Game Design
- "The Art of Game Design: A Book of Lenses"
- "Theory of Fun for Game Design"

---

## 🤝 Contribuindo

### Style Guide

- **Indentação:** Tabs (padrão Godot)
- **Nomenclatura:** snake_case para variáveis/funções
- **Classes:** PascalCase
- **Constantes:** UPPER_SNAKE_CASE
- **Comentários:** Em inglês, descritivos

### Pull Requests

1. Fork o projeto
2. Crie branch: `feature/nova-feature`
3. Commit: mensagens descritivas
4. Push e crie PR
5. Descreva mudanças

---

## 📞 Suporte

### Problemas Comuns

**"Autoload não encontrado"**
- Verifique Project → Project Settings → Autoload
- Paths devem estar corretos

**"Can't open file for writing"**
- Permissões do diretório
- Android: adicionar WRITE_EXTERNAL_STORAGE (se necessário)

**"Scene could not be loaded"**
- Verifique uid nos .tscn
- Re-import scenes

---

**Happy Coding! 🎮**

*"Code that remembers, like the player."*
