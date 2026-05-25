# Autoloads (Singletony)

Autoloads to **globalne obiekty** ładujące się na start gry. Mogą być dostępne z każdego miejsca w kodzie bez importu.

Analogia: Jak globalne zmienne w C - dostępne wszędzie, ale trzeba je konfigurować w `project.godot`.

To **serce gry** - tu siedzi cała logika zarządzania.

---

## GameManager - Kontroler gry

**Plik**: `game_manager.gd`

Główny menedżer - kontroluje WSZYSTKO: czas, poziomy, monety, boost, statystyki.

### Główne funkcje

#### 1. **Timer i game loop**

```gdscript
var game_time: float = 180.0      # 3 minuty
var is_timer_active: bool = false
var timer_seconds: float = 0.0    # Upłynęło ile sekund

signal time_ticked(current_seconds, remaining_seconds)
signal time_out  # Gdy czas się skończy
```

**Co robi**:
- Śledzenia upływu czasu
- Emituje `time_ticked` co sekundę (HUD się updatuje)
- Gdy czas = 0 → emituje `time_out` → koniec poziomu (porażka)

#### 2. **Monety i boost**

```gdscript
var current_collected_coins: int = 0
var current_boost_level: float = 0.0
var max_boost: float = 100.0
var boost_drain_rate: float = 3.0  # % na sekundę

signal coins_changed(total_coins)
signal boost_changed(current_boost_level)
```

**Funkcje**:
```gdscript
add_coins(amount)      # +1, +5, itd.
add_boost(amount)      # +50%, +100%, itd.
```

**Boost drain**: Co sekundę gry boost się naturalnie zmniejsza o 3% (jeśli gracz go nie zużył).

#### 3. **Zarządzanie poziomami**

```gdscript
var current_level_index: int = 0
var levels_data: Array[LevelData] = []  # Konfiguracja levelów

func start_game()           # Rozpocznij grę od poziomu 0
func load_next_level()      # Przejdź do następnego
func restart_current_level()# Restart (hazard)
```

#### 4. **Tworzenie gracza**

```gdscript
var player_scene: PackedScene = preload("res://scenes/entities/player/player.tscn")

func create_player() -> Node2D:
    return player_scene.instantiate()
```

Gdy level się załaduje, GameManager tworzy gracza.

#### 5. **Statystyki**

```gdscript
var total_shoot_count: int = 0
var total_wall_bounce_count: int = 0
var total_death_count: int = 0
```

Śledzi licznik:
- Ile razy gracz strzelił
- Ile razy odbił się od ścian
- Ile razy umarł

**Ekran końcowy** pokazuje te statystyki.

#### 6. **Camera shake**

```gdscript
signal camera_shake_request(strength: float)
```

Player emituje ten sygnał gdy uderzy w ścianę - siła zależy od prędkości.

### Jak to wszystko się łączy

```
GameManager (_process co klatkę)
├── Jeśli timer aktywny → timer_seconds += delta
│   └── Każdą sekundę: emit time_ticked
│
├── Boost drain → current_boost_level -= boost_drain_rate * delta
│   └── emit boost_changed
│
└── Nasłuchuj zdarzeń z poziomów
    ├── Player zbiera monetę → add_coins()
    ├── Player zbiera kawę → add_boost()
    └── Player uderza w ścianę → camera_shake_request emitted
```

---

## SceneChanger - Przejścia między scenami

**Plik**: `scene_changer.gd`

Obsługuje **płynne przejścia** fade in/out między scenami.

### Funkcje

```gdscript
change_scene_smooth(path)       # Fade to black, zmień scenę, fade in
change_scene_immediate(path)    # Bez animacji (szybkie)
change_scene_to_menu()          # Przejście do menu
change_scene_to_end_screen()    # Przejście do ekranu końcowego
```

### Jak wygląda fade

1. Czarny rect (ColorRect) fade in (0.3s)
2. Scena się zmienia w tle
3. ColorRect fade out (0.3s) → nowa scena widoczna

**Kod**:
```gdscript
const FADE_DURATION := 0.3

tween property(background, "color", Color.BLACK, FADE_DURATION)
change_scene_to_file(path)      # Zmiana w tle
tween property(background, "color", Color.TRANSPARENT, FADE_DURATION)
```

Wszystko działa przez `await` (czeka aż tween się skończy).

### Blokowanie inputu

Podczas fade:
```gdscript
background.mouse_filter = Control.MOUSE_FILTER_STOP  # Blokuj kliknięcia
```

Gracz nie może nic klikać podczas przejścia (ładna UX).

---

## SaveManager - Zapis postępu

**Plik**: `save_manager.gd`

Zapisuje i wczytuje postęp gracza.

### Struktura save'a (JSON)

```json
{
    "total_coins": 150,
    "unlocked_skins": ["default_skin", "skin_2"],
    "high_scores": {}
}
```

### Gdzie się zapisuje

- **Desktop (Windows/Linux)**: `user://save.json` (~/.godot/save.json)
- **HTML5 (Web)**: IndexedDB (local storage przeglądarki)
- **Edytor**: `user://` (zależy od Godota)

### Funkcje

```gdscript
save_game()                 # Zapisz JSON na dysk
load_game()                 # Wczytaj JSON z dysku

add_coins(amount)           # +monety + emit signal + save
get_coins() -> int          # Zwróć total coins

unlock_skin(skin_id)        # Odblokowali skin
is_skin_unlocked() -> bool  # Sprawdzenie
```

### Sygnały

```gdscript
signal total_coins_changed(new_amount)
```

Menu główne nasłuchuje tego sygnału - wyświetla ile masz monet.

### Persystencja

Każda zmiana (zbierz monetę, odblokowani skin) od razu się zapisuje:

```gdscript
func add_coins(amount: int) -> void:
    save_data["total_coins"] += amount
    total_coins_changed.emit(save_data["total_coins"])
    save_game()  # Zapisz OD RAZU
```

Tzn. jeśli gracz gaszę grę - monety są bezpieczne.

---

## PhotoManager - Galeria zdjęć

**Plik**: `photo_manager.gd`

Zarządza zbieraniem i odblokowywaniem zdjęć z eventów szkoły.

### Funkcje

```gdscript
var _photo_db: PhotoDatabase       # Baza wszystkich zdjęć

get_random_locked_photo() -> PhotoData     # Losowe nieodblokowane
get_all_unlocked_photos() -> Array        # Moje zdjęcia
get_all_locked_photos() -> Array          # Pozostałe do zbierania

unlock_photo(photo: PhotoData)    # Odblokowani zdjęcie
```

### Sygnały

```gdscript
signal photo_unlocked(photo: PhotoData)
```

Interfejs nasłuchuje - pokazuje popup gdy zbierzesz zdjęcie.

### Jak działa zbieranie

1. Gracz zbiera Photo collectible
2. Photo się usuwa
3. PhotoManager.unlock_photo() się wywoła
4. Sygnał `photo_unlocked` → popup na ekranie
5. Zdjęcie pojawia się w galerii

### Baza zdjęć

```gdscript
var _photo_db: PhotoDatabase = preload("res://resources/photos/photo_database.tres")
```

Wszystkie zdjęcia (Boże Narodzenie, dyrektorzy, Walentyna Tierieszkowa) są tam.

---

## NetworkManager - Komunikacja z API

**Plik**: `network_manager.gd`

Pobiera dane z serwera (news, updaty).

### Funkcje

```gdscript
fetch_news(on_success: Callable, on_error: Callable)
```

Asynchronicznie pobiera wiadomości z API `/api/news`.

### Detect środowiska

```gdscript
if OS.has_feature("editor"):
    base_url = "http://127.0.0.1:8080"  # Dev
elif OS.has_feature("web"):
    base_url = JavaScriptBridge.eval("window.location.origin")  # Web
else:
    base_url = fallback_url  # Fallback
```

Automatycznie detektuje czy grasz w edytorze, na Web czy desktopie.

### Użycie

```gdscript
# Z main_menu.gd
NetworkManager.fetch_news(_on_news_loaded, _on_news_error)

func _on_news_loaded(data):
    # Pokaż wiadomości
    pass
```

---

## Konfiguracja autoloads w projekcie

Aby autoload był dostępny wszędzie, trzeba go zarejestrować w `project.godot`:

```ini
[autoload]
SceneChanger="*uid://ia0j0cqwi45u"
SaveManager="*uid://dxsfwh1sluerl"
GameManager="*uid://bclc6d6j5v14s"
PauseMenu="*uid://b3ktuj0msl7n2"
NetworkManager="*uid://chaqjkwb4sor0"
PhotoManager="*uid://c4ct68wsbksn3"
```

Teraz mogą być dostępne z każdego miejsca:

```gdscript
GameManager.add_coins(10)          # ✓ Działa
SaveManager.save_game()            # ✓ Działa
SceneChanger.change_scene_smooth() # ✓ Działa
```

---

## Jak to wszystko działa razem

```
Gra rozpoczyna się
    ↓
Autoloads załadowują się (_ready)
    ├─ GameManager: inicjalizacja stanu
    ├─ SceneChanger: przygotowanie fade
    ├─ SaveManager: wczytaj save.json
    └─ PhotoManager: wczytaj zdjęcia z bazy
    ↓
Gracz klika Play w menu
    ↓
GameManager.start_game()
    ├─ Zresetuj liczniki
    ├─ Wczytaj Level 0
    ├─ Utwórz gracza
    └─ Emit sygnały
    ↓
Gracz gra na Level 0
    ├─ Player.hit() → GameManager.total_wall_bounce_count++
    ├─ CezCoin.collect() → GameManager.add_coins(1)
    ├─ Coffee.collect() → GameManager.add_boost(50)
    ├─ Timer tickuje → emit time_ticked → HUD się updatuje
    └─ Gracz dotknie Level End Area
    ↓
GameManager.load_next_level()
    ├─ SceneChanger.change_scene_smooth()
    └─ Fade do Level 1
    ↓
... (powtórz dla Level 1, Level 2)
    ↓
Koniec wszystkich levelów
    ↓
Gracz widzi End Screen (statystyki)
    ↓
SaveManager.add_coins(collected_coins)  # Dodaj do globalnego totala
    ↓
Gracz klika Menu
    ↓
Powrót do menu głównego
```

---

## Tips dla programistów

- **Nigdy nie twoórz duplikatu autoload** - je tylko jeden na grę
- **Autoloads są dostępne wszędzie** - ale pamiętaj o zależnościach
- **Sygnały** zamiast bezpośrednich wywołań - komponenty są niezależne
- **_ready vs _process** - autoloads se załadowują w _ready, potem działają
- Jeśli dodasz nowy autoload - rejestruj go w `project.godot`
