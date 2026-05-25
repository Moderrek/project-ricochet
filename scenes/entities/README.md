# Entities (Byty dynamiczne)

Ruchome obiekty z fizyką - głównie gracz. Tutaj jest serce mechaniki gry.

## Player (gracz)

### Jak działa gracz

Gracz to **kula** (RigidBody2D) którą kontrolujesz myszką.

**Kontrola**:
1. Kliknij na gracza (w zasięgu click_radius = 120px)
2. Przeciągnij myszę - system pokazuje trajektorię (AimLine)
3. Puść przycisk - gracz leci!

**Parametry do tuning'u** (edytor → Player.tscn → Skrypt):
```
max_force: 2400.0          - Maksymalna siła strzału
power_multiplier: 5.0      - Mnożnik (drag * multiplier = siła)
click_radius: 120.0        - Radius w pikselen aby kliknąć gracza
```

### Mechanika strzału

1. **Drag calculation**: Odległość myszy od gracza → siła
   - Maksymalny drag = `max_force / power_multiplier` (~480px)
   - Jeśli przeciągniesz dalej, ograniczy się do max

2. **Force calculation**:
   ```gdscript
   var final_force = drag_vector * power_multiplier
   if final_force.length() > max_force:
       final_force.limit_length(max_force)
   ```

3. **Boost**:
   - Jeśli `GameManager.current_boost_level > 0`
   - Siła = `final_force * 1.5` (50% bonusa)

4. **Apply impulse**:
   ```gdscript
   apply_central_impulse(final_force)
   ```

### Odbicia od ścian

Gdy gracz uderzy w ścianę:
- Fizyka Godot automatycznie odbija go
- `_on_body_entered()` się wywoła
- **Licznik odbić** + 1
- **Sound**: Dźwięk bounce (pitch zależy od siły)
- **Particles**: Animacja cząstek
- **Camera shake**: Wstrząs kamery (siła = szybkość * 0.01, max 30)

### Śmierć i respawn

Gdy gracz wpadnie w hazard:
- `GameManager.restart_current_level()` się wywoła
- Gracz ma animację rozpadu (death_particles)
- Dźwięk śmierci
- Camera shake na maksymalnie (30)
- Po 1.2 sekundy: respawn na PlayerSpawnMarker

**Kod respawnu**:
```gdscript
func shatter_and_respawn(spawn_position: Vector2):
    death_particles.restart()
    death_sound.play()
    await tween.tween_interval(1.2)
    global_position = spawn_position
    _is_dead = false
```

### Statystyki

Player emituje sygnały do GameManager:
- `player_shot.emit()` - za każdym strzałem
- `GameManager.total_shoot_count` - licznik strzałów
- `GameManager.total_wall_bounce_count` - licznik odbić
- `GameManager.total_death_count` - licznik śmierci

---

## AimLine (system celowania)

### Jak działa wizualizacja trajektorii

Gdy gracz się aiming'uje (przeciąga myszę):

1. **Linia celowania**: Pokazuje gdzie poleci gracz
2. **Odbicia**: Liczy do 2 odbicia od ścian (symulacja)
3. **Strzałka**: Kierunek i siła (większy kąt = silniejszy strzał)

### Kolory

- **Bez boosta**: Niebieski (zimny) → Pomarańczowy (gorący)
- **Z bootem**: Czerwony (zimny) → Żółty (gorący)

Intensywność koloru = intensywność strzału

### Parametry** (edytor → AimLine.tscn):

```
max_bounces: 2                    - Ile odbić symulować
cold_color: 0.3, 0.7, 1.0        - Niebieski (bez siły)
hot_color: 1.0, 0.5, 0.2         - Pomarańczowy (maksymalna siła)
boost_cold_color: 1.0, 0.2, 0.2  - Czerwony (boost - bez siły)
boost_hot_color: 1.0, 0.8, 0.0   - Żółty (boost - maksymalna siła)
```

### Jak AimLine oblicza trajektorię

Używa **raycast** (Physics raycast) aby znaleźć odbicia:

```gdscript
func _calculate_reflections(start_pos, dir, dist):
    # Dla każdego odbicia:
    # 1. Wyślij raycast w kierunku
    # 2. Znajdź punkt uderzenia
    # 3. Odbij kierunek (reflect)
    # 4. Powtórz maksymalnie max_bounces razy
```

**Ograniczenia**:
- Maksymalnie 2 odbicia
- Maksymalna wizualizowana odległość: 600px
- Wygląda realistycznie dzięki Physics2D

### Co zawiera AimLine

```
AimLine (Node2D)
├── Line2D          - Linia trajektorii
└── ArrowPolygon    - Strzałka kierunku i siły
```

---

## Dodawanie nowego gracza / entity

### Jeśli chcesz inny gracz

1. Skopiuj `player/player.tscn`
2. Zmień sprite (Sprite2D)
3. Ustaw parametry: `max_force`, `power_multiplier`
4. W `game_manager.gd` zmień `player_scene` na nowy player

### Jeśli chcesz inny system celowania

Zamiast AimLine możesz zrobić:
- Kliknięcie bez dragging
- Kierunkową kontrolę (strzałkami)
- Różne symulacje (AI)

Wystarczy extends Node2D i zaimplemntować logikę.

### Template nowegoEntity

```gdscript
@icon("res://assets/icons/icon.png")
extends RigidBody2D
class_name MyEntity

func _ready():
    # Wczytaj komponenty
    pass

func _on_collision(body):
    # Obsługuj kolizje
    pass

func die():
    # Umieraj
    pass
```

---

## Struktura Player sceny

```
Player (RigidBody2D)
├── Sprite2D             - Grafika (kula)
├── CollisionShape2D     - Fizykę
├── HitParticles         - Cząstki przy uderzeniu
├── DeathParticles       - Cząstki rozpadu
├── BounceSound          - Dźwięk odbicia
├── DeathSound           - Dźwięk śmierci
├── ShootSound           - Dźwięk strzału
└── AimLine (Node2D)     - System celowania
    ├── Line2D           - Linia trajektorii
    └── ArrowPolygon     - Strzałka
```

Każdy komponent jest niezależny - mogą pracować razem bez kopiowania.
