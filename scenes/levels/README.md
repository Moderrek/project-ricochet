# Levels (Mapy gry)

Wszystkie poziomy w grze. Każdy poziom jest osobną sceną, którą gracz przechodzi kolei.

## Jak funkcjonuje system poziomów

### BaseLevel - szablon dla wszystkich poziomów
Plik: `base_level.tscn` i `base_level.gd`

BaseLevel to szablon, na którym opierają się wszystkie poziomy. Zawiera:
- **Punkt spawnu gracza** (PlayerSpawnMarker)
- **Kamerę** (LevelCamera)
- **HUD** (wyświetlacz czasu, monet, boosta)
- **Logikę wspólną** - spawn gracza, wczytanie ustawień, timer

**Ważne**: Każdy nowy poziom **musi dziedziczyć z BaseLevel**. To oznacza że każdy poziom automatycznie dostaje te komponenty.

### Virtual functions (funkcje przeznaczone do nadpisania)
W GDScript "virtual functions" to funkcje zdefiniowane w klasie bazowej, które mogą być nadpisane w klasach pochodnych.

BaseLevel ma 5 takich funkcji - każdy level może je nadpisać aby mieć własne zachowanie:

1. **`_on_level_loaded()`** - Wywoływana gdy scena się załaduje
2. **`_on_before_level_start()`** - Wywoływana przed startem rozgrywki
3. **`_on_level_started()`** - Wywoływana gdy gra zaczyna się po raz pierwszy
4. **`_on_player_spawned(player)`** - Wywoływana gdy gracz pojawia się na mapie
5. **`_on_player_shot()`** - Wywoływana za każdym razem gdy gracz strzeli

Każdy level może robić coś innego w tych momentach.

## Istniejące poziomy

### Level 0 - Tutorial (level_0.tscn)
**Plik skryptu**: `level_0.gd`

Pierwszy poziom gry - bez żadnego timera, aby gracz mógł się nauczyć.

Co robi:
- Po pierwszym strzale gracza ukrywa ekran instrukcji (tutorial_ui znika)
- Brak timera (aby gracz miał czas)

Kod:
```gdscript
extends BaseLevel

func _on_player_shot() -> void:
    # Ukrywa tutorial UI gdy gracz pierwszy raz strzeli
    tutorial_ui fade out i się usuwa
```

### Level 1 - Pierwszy poziom główny (level_1.tscn)
**Plik skryptu**: `level_1.gd`

Pierwszy "normalny" poziom z timerem, ale z przychylnością dla gracza.

Co robi:
- Timer **nie startuje od razu** - gracz ma chwilę na przygotowanie
- Timer zaczyna się dopiero **po pierwszym strzale**

Kod:
```gdscript
extends BaseLevel

func _on_level_started() -> void:
    # Timer jest wyłączony na starcie
    GameManager.is_timer_active = false

func _on_player_shot() -> void:
    # Timer włącza się po pierwszym strzale
    GameManager.is_timer_active = true
```

### Level 2 - Drugi poziom główny (level_2.tscn)
Pełny poziom z timerem od samego początku (3 minuty).

## Jak utworzyć nowy poziom

### Krok 1: Skopiuj BaseLevel
1. Otwórz `base_level.tscn` w edytorze Godot
2. Plik → Zapisz kopię jako...
3. Nazwa: `level_3.tscn`

### Krok 2: Ustaw skrypt
1. Zaznacz root scene (Node2D)
2. Dodaj nowy skrypt (prawy przycisk → Attach Script)
3. Nazwa: `level_3.gd`
4. Kod główny:
```gdscript
extends BaseLevel

# Tutaj możesz nadpisać virtual functions do własnych celów

func _on_level_started() -> void:
    # Jeśli chcesz inny timer na start
    GameManager.is_timer_active = false
```

### Krok 3: Zbuduj mapę
1. Dodaj tilemapę (sciana, przeszkody) - dziedziczy się ze scenariusza
2. Dodaj obiekty interaktywne:
   - Drzwi (Door) - do przejścia do następnego levela
   - Automat do kawy (VendingMachine) - boost
   - Monety (CezCoin) - do zbierania
   - Hazardy (Area2D) - strefy śmiertelne
3. Ustaw punkt spawnu gracza na PlayerSpawnMarker

### Krok 4: Dodaj do GameManager
1. Otwórz `autoloads/game_manager.gd`
2. Dodaj nowy level do tablicy poziomów w konfiguracji
3. Ustaw kolejność: `[level_0, level_1, level_2, level_3]`

## Testowanie poziomu

W edytorze Godot:
- Naciśnij F6 żeby zagrać wybrany poziom
- Albo F5 żeby zagrać od menu głównego

## Struktura sceny baseLevel

```
BaseLevel (Node2D)
├── PlayerSpawnMarker      - Miejsce gdzie pojawia się gracz
├── LevelCamera (Camera2D) - Kamera śledząca gracza
├── HUD (CanvasLayer)      - Interfejs (timer, monety)
├── Entities (Node)        - Pojemnik na dynamiczne obiekty (gracz, monety)
├── TileMap                - Ściana i terenu mapy
└── [Inne obiekty]         - Drzwi, automaty, hazardy itp.
```

Gdy tworzysz nowy level, wszystko automatycznie się dziedziczy z BaseLevel!
