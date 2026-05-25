# UI (Interfejs użytkownika)

Warstwa interfejsu nałożona na grę (HUD - Heads Up Display). Pokazuje informacje gracza w trakcie rozgrywki. Wszystkie elementy są renderowane na osobnej CanvasLayer, ponad grą.

---

## Główne komponenty

### HUD (hud.tscn + hud.gd)

Główny interfejs gry - all-in-one dashboard dla gracza. Zawiera trzy główne sekcje:

#### 1. **Timer (licznik czasu)**

Wyświetla pozostały czas w formacie **MM:SS** (np. 02:45).

**Kolory:**
- Normalnie: Biały (bezpieczny)
- Poniżej 30 sekund: **Migocze na żółto** (efekt pulsacji - alert!)

**Kod pulsacji:**
```gdscript
# Ostatnie 30 sekund
if remaining_seconds <= 30:
    var pulse_alpha = sin(time * frequency) * 0.5 + 0.5
    timer_label.modulate.a = pulse_alpha
    timer_label.add_theme_color_override("font_color", Color.YELLOW)
```

**Połączenie z GameManager:**
```gdscript
# HUD._ready()
GameManager.time_ticked.connect(_on_time_ticked)

func _on_time_ticked(current, remaining):
    timer_label.text = format_time(remaining)
```

#### 2. **Licznik monet (Coin Counter)**

Wyświetla ile CezCoinów zebrałeś podczas tej rozgrywki.

**Animacje:**
- **Jump animation**: Licznik przeskakuje o +1 (pozycja Y zmienia się)
- **Color flash**: Licznik mignie na żółto (Color.YELLOW)
- **Duration**: 0.3 sekundy

**Kod animacji:**
```gdscript
func _on_coins_changed(new_count):
    # Tween: Y + 20px, potem powrót
    tween.tween_property(coin_counter, "position:y", old_y + 20, 0.1)
    tween.tween_property(coin_counter, "position:y", old_y, 0.2)
    
    # Color flash
    coin_counter.add_theme_color_override("font_color", Color.YELLOW)
    await get_tree().create_timer(0.2).timeout
    coin_counter.add_theme_color_override("font_color", Color.WHITE)
    
    coin_counter.text = str(new_count)
```

**Połączenie z GameManager:**
```gdscript
GameManager.coins_changed.connect(_on_coins_changed)
```

#### 3. **Pasek boosta (Boost Bar)**

Wizualny pasek pokazujący aktualny poziom boosta.

**Zachowanie:**
- Pojawia się tylko gdy `current_boost_level > 0`
- Wartość: 0-100%
- Szybko się zmniejsza (3% na sekundę drain)
- Znika (fade out) gdy osiąga 0%

**Wizualne:**
- Kolor: Gradient (zimny → gorący)
- Shape: Horizontalny pasek
- Pozycja: Prawy dolny róg HUD

---

### Boost Bar (boost_bar_v_2.gd)

Specjalizowany komponent do wyświetlania boosta.

**Parametry:**
```gdscript
@export var max_boost: float = 100.0
@export var drain_rate: float = 3.0
@export var bar_color_cold: Color = Color.BLUE
@export var bar_color_hot: Color = Color.RED
```

**Aktualizacja:**
```gdscript
func _on_boost_changed(new_level: float) -> void:
    var percentage = (new_level / max_boost) * 100
    
    # Ustaw szerokość paska
    bar.size.x = percentage * max_width / 100
    
    # Interpoluj kolory
    var t = new_level / max_boost
    bar.modulate = bar_color_cold.lerp(bar_color_hot, t)
    
    # Pokaż/ukryj pasek
    visible = new_level > 0
```

**Połączenie:**
```gdscript
GameManager.boost_changed.connect(_on_boost_changed)
```

---

### Photo Popup (photo_popup/)

Popup wyświetlający się gdy gracz zbiera zdjęcie - dekoratywne i edukacyjne.

**Wygląd:**
- Animacja fade-in (0.3s)
- Miniatura zdjęcia (200x150px)
- Tytuł zdjęcia (tekst)
- Opis: Kilka zdań o evencie szkolnym CKZiU
- Przyciski: OK (zamknięcie)

**Parametry:**
```gdscript
@export var fade_duration: float = 0.3
@export var display_duration: float = 3.0  # Jak długo widoczne
@export var thumbnail_size: Vector2 = Vector2(200, 150)
```

**Kod wyzwolenia:**
```gdscript
# PhotoManager.gd
signal photo_unlocked(photo: PhotoData)

func unlock_photo(photo: PhotoData) -> void:
    photo_popup.show_photo(photo)
    photo_unlocked.emit(photo)
```

**Połączenie z PhotoManager:**
```gdscript
# HUD._ready()
PhotoManager.photo_unlocked.connect(_on_photo_unlocked)

func _on_photo_unlocked(photo: PhotoData) -> void:
    photo_popup.display_photo(photo)
```

---

## Struktura sceny HUD

```
HUD (CanvasLayer)  # Nad wszystkim!
├── TimerLabel (Label)
├── CoinCounter (Label)
├── BoostBar (Control)
│   └── FluidRect (Panel)  # Animowany pasek
├── PhotoPopup (Panel)
│   ├── PhotoThumbnail (TextureRect)
│   ├── PhotoTitle (Label)
│   ├── PhotoDescription (Label)
│   └── CloseButton (Button)
└── [Inne UI elementy]
```

---

## Jak to wszystko się łączy

```
Gra się uruchamia
    ↓
HUD._ready() się wywoła
    ├─ Połącz GameManager.time_ticked → _on_time_ticked
    ├─ Połącz GameManager.coins_changed → _on_coins_changed
    ├─ Połącz GameManager.boost_changed → _on_boost_changed
    └─ Połącz PhotoManager.photo_unlocked → _on_photo_unlocked
    ↓
Gracz gra
    ├─ Każdą sekundę: time_ticked(sec, remaining)
    │  └─ TimerLabel.text = format(remaining)
    │     └─ Jeśli < 30s: migaj na żółto
    │
    ├─ Gracz zbiera monetę
    │  └─ coins_changed(new_count)
    │     └─ Animacja: jump + flash
    │
    ├─ Gracz zbiera kawę
    │  └─ boost_changed(new_level)
    │     └─ BoostBar.size = percentage
    │
    └─ Gracz zbiera zdjęcie
       └─ photo_unlocked(photo)
          └─ PhotoPopup fade-in z informacją
```

---

## Tips

- **CanvasLayer**: UI zawsze renderuje się na wierzchu gry (z wartością `layer`)
- **Sygnały**: HUD się sam aktualizuje - nie pyta o stan, nasłuchuje zmian
- **Tweeny**: Do wszystkich animacji używamy `Tween` - elegancko i gładko
- **Responsive design**: UI się automatycznie przeskalowuje jeśli zmienisz rozmiar okna
